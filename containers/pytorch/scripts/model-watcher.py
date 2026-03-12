#!/usr/bin/env python3
import json
import os
import urllib.request
from collections import defaultdict
from pathlib import Path

# ------------------------------------------------------------
# CONFIGURATION (explicit, tweakable)
# ------------------------------------------------------------
OLLAMA_INDEX_URL = "https://ollama.com/library.json"

# Path to the host-mounted Ollama model store
OLLAMA_STORE = Path(os.path.join(
    "/srv",
    "containers",
    "pytorch",
    "models",
    "manifests",
))

# Cache file to track previously-seen models
CACHE_FILE = Path(os.path.join(
    os.path.expanduser("~"),
    ".cache",
    "ollama-model-watcher.json",
))

# Output file for candidate list
CANDIDATE_FILE = Path(os.path.join(
    os.path.expanduser("~"),
    ".cache",
    "ollama-model-candidates.json",
))

# Optional: integrate with your benchmarking harness
BENCHMARK_SCRIPT = None

# Explicit family mapping (extend as needed)
FAMILY_MAP = {
    "llama": "Llama",
    "llama3": "Llama",
    "llama3.1": "Llama",
    "mistral": "Mistral",
    "mixtral": "Mistral",
    "qwen": "Qwen",
    "qwen2": "Qwen",
    "qwen2.5": "Qwen",
    "deepseek": "DeepSeek",
    "gemma": "Gemma",
    "phi": "Phi",
}


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
def fetch_remote_index():
    with urllib.request.urlopen(OLLAMA_INDEX_URL) as r:
        return json.loads(r.read().decode())


def fetch_local_models():
    if not OLLAMA_STORE.exists():
        print(f"Local model store not found: {OLLAMA_STORE}")
        return set()
    return {p.name for p in OLLAMA_STORE.iterdir() if p.is_file()}


def load_cache():
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text())
    return {"known_models": []}


def save_cache(cache):
    CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
    CACHE_FILE.write_text(json.dumps(cache, indent=2))


def detect_family(model_name):
    prefix = model_name.split(":")[0].lower()
    for key, family in FAMILY_MAP.items():
        if prefix.startswith(key):
            return family
    return "Other"


def detect_quantization(model_name):
    if ":" not in model_name:
        return "unknown"
    suffix = model_name.split(":")[1]
    return suffix


# ------------------------------------------------------------
# Main logic
# ------------------------------------------------------------
def main():
    print("Fetching remote model index…")
    remote = fetch_remote_index()
    remote_models = {m["name"] for m in remote.get("models", [])}

    print(f"Reading local models from {OLLAMA_STORE} …")
    local_models = fetch_local_models()

    cache = load_cache()
    known = set(cache.get("known_models", []))

    # New models = in remote index but not in cache
    new_models = sorted(remote_models - known)

    # Locally installed but not yet benchmarked
    updated_local = sorted(local_models - known)

    # Build candidate list
    candidates = defaultdict(lambda: defaultdict(list))

    for m in new_models + updated_local:
        family = detect_family(m)
        quant = detect_quantization(m)
        candidates[family][quant].append(m)

    # Output candidate list
    CANDIDATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    CANDIDATE_FILE.write_text(json.dumps(candidates, indent=2))

    # Print summary
    if not new_models and not updated_local:
        print("No new or updated models detected.")
    else:
        print("\nNew models available:")
        for m in new_models:
            print(f"  + {m}")

        print("\nLocally installed models not yet benchmarked:")
        for m in updated_local:
            print(f"  * {m}")

        print(f"\nCandidate list written to: {CANDIDATE_FILE}")

    # Optional: trigger benchmarking
    if BENCHMARK_SCRIPT:
        import subprocess

        for m in new_models + updated_local:
            print(f"\n▶ Benchmarking {m}…")
            subprocess.run([BENCHMARK_SCRIPT, m])

    # Update cache
    cache["known_models"] = sorted(remote_models | local_models)
    save_cache(cache)

    print("\nCache updated.")
    print("Done.")


if __name__ == "__main__":
    main()
