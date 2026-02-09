#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_FILE="${1:-${SCRIPT_DIR}/models.txt}"
PROMPTS_FILE="${2:-${SCRIPT_DIR}/prompts.txt}"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-30}"
WARM_UP_PROMPT="Hello."

if [[ ! -f "$MODELS_FILE" ]]; then
  echo "Error: Models file not found: $MODELS_FILE" >&2
  exit 1
fi

if [[ ! -f "$PROMPTS_FILE" ]]; then
  echo "Error: Prompts file not found: $PROMPTS_FILE" >&2
  exit 1
fi

# Read prompts separated by blank lines
mapfile -t PROMPTS < <(awk -v RS= '{gsub(/\n+$/, "", $0); print}' "$PROMPTS_FILE")

if [[ ${#PROMPTS[@]} -eq 0 ]]; then
  echo "Error: No prompts found in $PROMPTS_FILE" >&2
  exit 1
fi

# Count actual models (excluding blank lines)
MODEL_COUNT=$(grep -cv '^\s*$' "$MODELS_FILE" || echo 0)

echo "Benchmarking $MODEL_COUNT models across ${#PROMPTS[@]} prompts"
echo

while IFS= read -r MODEL; do
  [[ -z "$MODEL" ]] && continue

  echo "==============================="
  echo "MODEL: $MODEL"
  echo "==============================="

  for idx in "${!PROMPTS[@]}"; do
    PROMPT="${PROMPTS[$idx]}"
    echo "--- Prompt $((idx+1)) ---"

    # Warm-up run (not measured)
    WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
      -d "$(jq -nc --arg model "$MODEL" --arg prompt "$WARM_UP_PROMPT" \
        '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
    WARMUP_HTTP="${WARMUP##*$'\n'}"
    if [[ "$WARMUP_HTTP" != "200" ]]; then
      echo "  Error: Warm-up failed with HTTP $WARMUP_HTTP" >&2
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
  done

  echo
done < "$MODELS_FILE"
