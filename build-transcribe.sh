#!/usr/bin/env bash
set -euo pipefail

DIST=${1:-dist}
mkdir -p "$DIST"

echo "=== Configuring GPU build ==="
cmake -DBUILD_SHARED_LIBS=off -DGGML_CUDA=1 -B build-gpu

echo "=== Building GPU binary ==="
cmake --build build-gpu -j --config Release

echo "=== Configuring CPU build ==="
cmake -DBUILD_SHARED_LIBS=off -B build-cpu

echo "=== Building CPU binary ==="
cmake --build build-cpu -j --config Release

echo "=== Packaging ==="
cp build-gpu/bin/whisper-cli "$DIST/transcribe"
cp build-cpu/bin/whisper-cli "$DIST/transcribe_cpu"

echo "=== Done: $DIST/transcribe and $DIST/transcribe_cpu ==="
