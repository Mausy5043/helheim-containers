#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT="Explain strong vs weak consistency in distributed systems in about 300 words."
WARM_UP_PROMPT="introduce yourself"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-30}"

# Discover installed models
MODEL_LIST=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

if [[ -z "$MODEL_LIST" ]]; then
  echo "Error: No models found via 'ollama list'" >&2
  exit 1
fi

# Sort by size (column 2, numeric, ascending)
MODEL_LIST=$(echo "$MODEL_LIST" | sort -k2,2n | awk '{print $1}')

echo "Benchmarking installed models"
echo

for MODEL in $MODEL_LIST; do
  [[ -z "$MODEL" ]] && continue

  echo "=== $MODEL ==="

  # Warm-up run (not measured)
  WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
    -d "$(jq -nc --arg model "$MODEL" --arg prompt "$WARM_UP_PROMPT" \
      '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
  HTTP_CODE="${WARMUP##*$'\n'}"
  if [[ "$HTTP_CODE" != "200" ]]; then
    echo "  Error:        Warm-up failed with HTTP $HTTP_CODE" >&2
    echo "  Response was: $WARMUP"
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
    echo "  Error:        Request failed with HTTP $HTTP_CODE" >&2
    echo "  Response was: $RESPONSE"
    echo
    continue
  fi

  if ! echo "$RESULT" | jq empty 2>/dev/null; then
    echo "  Error:        Invalid JSON response" >&2
    echo "  Response was: $RESPONSE"
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
done
