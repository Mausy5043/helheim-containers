#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_FILE="${1:-${SCRIPT_DIR}/prompts.txt}"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-30}"
WARM_UP_PROMPT="introduce yourself"

# Discover installed models with size, sorted descending
# Skip embedding models but print a message for each skipped one
RAW_MODELS=$(ollama list 2>/dev/null | awk 'NR>1 {print $1, $2}')

if [[ -z "$RAW_MODELS" ]]; then
  echo "Error: No models found via 'ollama list'" >&2
  exit 1
fi

MODEL_LIST=""
while read -r NAME SIZE; do
  [[ -z "$NAME" ]] && continue

  if [[ "$NAME" == *":embed"* ]] || [[ "$NAME" == *"-embed"* ]] || [[ "$NAME" == *"embed"* ]]; then
    echo "Skipping embedding model: $NAME"
    continue
  fi

  MODEL_LIST+="$NAME $SIZE"$'\n'
done <<< "$RAW_MODELS"

if [[ -z "$MODEL_LIST" ]]; then
  echo "Error: No non-embedding models available" >&2
  exit 1
fi

# Sort by size (column 2, numeric, ascending)
MODEL_LIST=$(echo "$MODEL_LIST" | sort -k2,2n | awk '{print $1}')

if [[ ! -f "$PROMPTS_FILE" ]]; then
  echo "Error: Prompts file not found: $PROMPTS_FILE" >&2
  exit 1
fi

mapfile -t PROMPTS < <(awk -v RS= '{gsub(/\n+$/, "", $0); print}' "$PROMPTS_FILE")

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

  for idx in "${!PROMPTS[@]}"; do
    PROMPT="${PROMPTS[$idx]}"
    echo "--- Prompt $((idx+1)) ---"

    WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
      -d "$(jq -nc --arg model "$MODEL" --arg prompt "$WARM_UP_PROMPT" \
        '{model:$model, prompt:$prompt, stream:false}')" 2>/dev/null || echo "000")
    WARMUP_HTTP="${WARMUP##*$'\n'}"
    if [[ "$WARMUP_HTTP" != "200" ]]; then
      echo "  Error:        Warm-up failed with HTTP $WARMUP_HTTP"
      echo "  Response was: $WARMUP"
      echo
      continue
    fi

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
