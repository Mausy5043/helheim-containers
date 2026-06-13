#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT="Write a Python function that takes a list of integers and returns all prime numbers. Include docstrings and unittests."
WARM_UP_PROMPT="introduce yourself"
API_URL="${API_URL:-http://127.0.0.1:11434/api/generate}"
TIMEOUT="${TIMEOUT:-120}"

# Discover installed models
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


echo "Benchmarking installed models"
echo

for MODEL in $MODEL_LIST; do
  [[ -z "$MODEL" ]] && continue

  echo "=== $MODEL ==="
  
  # reset the GPU
  if command -v rocm-smi &> /dev/null; then
    rocm-smi --gpureset -d 0 >/dev/null || echo "GPU reset failed!"
  fi
  # reclaim buffered RAM
  if [[ -e /proc/sys/vm/drop_caches ]]; then
    sync; sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
  fi
  # Warm-up run (not measured)
  WARMUP=$(curl -s --max-time "$TIMEOUT" -w "\n%{http_code}" "$API_URL" \
    -d "$(jq -nc --arg model "$MODEL" --arg prompt "$PROMPT" \
      '{model:$model, prompt:$prompt, stream:false}')" || echo "000")
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
      '{model:$model, prompt:$prompt, stream:false}')" || echo "000")
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
