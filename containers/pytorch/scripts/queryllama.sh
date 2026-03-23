#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT=$(<"${SCRIPT_DIR}/prompt.txt")
# "Write a Python function that takes a list of integers and returns all prime numbers. Include docstrings and unittests."
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


echo "Querying installed models with:"
echo "$PROMPT"
echo

while IFS= read -r MODEL; do
  [[ -z "$MODEL" ]] && continue

  # reset the GPU
  rocm-smi --gpureset -d 0 >/dev/null || echo "GPU reset failed!"
  # reclaim buffered RAM
  sync; sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

  echo
  echo "=== $MODEL ==="

  RESPONSE=$(curl -s \
    --max-time "$TIMEOUT" \
    "$API_URL" \
    -d "$(jq -nc \
      --arg model "$MODEL" \
      --arg prompt "$PROMPT" \
      '{model:$model, prompt:$prompt, stream:false}')")

  if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
    echo "  Error: Invalid JSON response"
    echo "$RESPONSE"
    continue
  fi

  # Print only the generated text
  echo "$RESPONSE" | jq -r '.response'
done <<< "$MODEL_LIST"
