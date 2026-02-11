#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_FILE="${1:-${SCRIPT_DIR}/prompts.txt}"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-30}"
WARM_UP_PROMPT="introduce yourself"

# Discover installed models with size, sorted descending
# Skip embedding models but print a message for each skipped one
MODEL_LIST=$(curl -s http://127.0.0.1:11434/api/tags \
  | jq -r '.models[] | "\(.name) \(.size)"' \
  | while read -r NAME SIZE; do
      case "$NAME" in
        *embed*|*:embed*) echo "Skipping embedding model: $NAME" >&2 ;;
        *) echo "$NAME $SIZE" ;;
      esac
    done \
  | sort -k2,2n \
  | awk '{print $1}')

if [[ -z "$MODEL_LIST" ]]; then
  echo "Error: No models found via 'ollama list'" >&2
  exit 1
fi

if [[ -z "$MODEL_LIST" ]]; then
  echo "Error: No non-embedding models available" >&2
  exit 1
fi

if [[ ! -f "$PROMPTS_FILE" ]]; then
  echo "Error: Prompts file not found: $PROMPTS_FILE" >&2
  exit 1
fi

# mapfile -t PROMPTS < <(awk -v RS= '{gsub(/\n+$/, "", $0); print}' "$PROMPTS_FILE")
mapfile -t PROMPTS < <(
  awk '
    BEGIN { RS="===PROMPT==="; ORS="" }
    NF { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", $0); print $0 "\n---END---\n" }
  ' "$PROMPTS_FILE" |
  awk -v RS="---END---" 'NF {print}'
)


if [[ ${#PROMPTS[@]} -eq 0 ]]; then
  echo "Error: No prompts found in $PROMPTS_FILE" >&2
  exit 1
fi

MODEL_COUNT=$(echo "$MODEL_LIST" | wc -w | tr -d ' ')

echo "Benchmarking $MODEL_COUNT models across ${#PROMPTS[@]} prompts"
echo

for MODEL in $MODEL_LIST; do
  echo "==============================="
  echo "MODEL: $MODEL"
  echo "==============================="

    echo "Warming up..."
    WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
        -d "$(jq -nc --arg model "$MODEL" --arg prompt "$WARM_UP_PROMPT" \
        '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
    echo "$WARMUP"
    echo
    WARMUP_HTTP="${WARMUP##*$'\n'}"
    if [[ "$WARMUP_HTTP" != "200" ]]; then
        echo "  Error:        Warm-up failed with HTTP $WARMUP_HTTP"
        echo
        continue
    fi

  for idx in "${!PROMPTS[@]}"; do
    PROMPT="${PROMPTS[$idx]}"
    echo "--- Prompt $((idx+1)) ---"


    RESPONSE=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
      -d "$(jq -nc --arg model "$MODEL" --arg prompt "$PROMPT" \
        '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
    HTTP_CODE="${RESPONSE##*$'\n'}"
    RESULT="${RESPONSE%$'\n'*}"

    if [[ "$HTTP_CODE" != "200" ]]; then
      echo "  Error:        Request failed with HTTP $HTTP_CODE"
      echo "  Response was: $RESPONSE"
      echo
      continue
    fi

    if ! echo "$RESULT" | jq empty 2>/dev/null; then
      echo "  Error:        Invalid JSON response"
      echo "  Response was: $RESPONSE"
      echo
      continue
    fi

    TOKENS=$(echo "$RESULT" | jq '.eval_count // empty')
    DURATION_NS=$(echo "$RESULT" | jq '.eval_duration // empty')

    if [[ -z "$TOKENS" || -z "$DURATION_NS" ]]; then
      echo "  Error: model did not return timing data"
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
done
