#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_FILE="${1:-${SCRIPT_DIR}/models.txt}"
PROMPT="Explain strong vs weak consistency in distributed systems in about 300 words."
WARM_UP_PROMPT="introduce yourself"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-30}"

if [[ ! -f "$MODELS_FILE" ]]; then
  echo "Error: Models file not found: $MODELS_FILE" >&2
  exit 1
fi

echo "Benchmarking models from $MODELS_FILE"
echo

while IFS= read -r MODEL; do
  [[ -z "$MODEL" ]] && continue

  echo "=== $MODEL ==="

  # Warm-up run (not measured)
  WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
    -d "$(jq -nc --arg model "$MODEL" --arg prompt "$WARM_UP_PROMPT" \
      '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
  HTTP_CODE="${WARMUP##*$'\n'}"
  if [[ "$HTTP_CODE" != "200" ]]; then
    echo "  Error: Warm-up failed with HTTP $HTTP_CODE" >&2
    echo
    continue
  fi

  # Measured run
  RESPONSE=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
    -d "$(jq -nc --arg model "$MODEL" --arg prompt "$PROMPT" \
      '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
  HTTP_CODE="${RESPONSE##*$'\n'}"
  RESULT="${RESPONSE%$'\n'*}"

  if [[ "$HTTP_CODE" != "200" ]]; then
    echo "  Error: Request failed with HTTP $HTTP_CODE" >&2
    echo
    continue
  fi

  # Validate JSON response
  if ! echo "$RESULT" | jq empty 2>/dev/null; then
    echo "  Error: Invalid JSON response" >&2
    echo
    continue
  fi

  TOKENS=$(echo "$RESULT" | jq '.eval_count // empty' 2>/dev/null || echo "")
  DURATION_NS=$(echo "$RESULT" | jq '.eval_duration // empty' 2>/dev/null || echo "")

  if [[ -z "$TOKENS" || -z "$DURATION_NS" ]]; then
    echo "  Error: model did not return timing data" >&2
    echo
    continue
  fi

  awk -v t="$TOKENS" -v d="$DURATION_NS" '
    BEGIN {
      if (t <= 0 || d <= 0) {
        print "  Error: Invalid timing data (tokens=" t ", duration=" d ")" > "/dev/stderr"
        exit 1
      }
      secs = d / 1e9
      if (secs == 0) {
        print "  Error: Duration is zero" > "/dev/stderr"
        exit 1
      }
      speed = t / secs
      printf "  Tokens: %d\n  Time: %.3fs\n  Speed: %.2f tokens/s\n\n", t, secs, speed
    }' || true
done < "$MODELS_FILE"
