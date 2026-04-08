#!/usr/bin/env bash
set -euo pipefail

DIST=${1:-dist}
mkdir -p "$DIST"

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    echo "=== macOS detected: building with Metal ==="
    cmake -DBUILD_SHARED_LIBS=off -B build-mac
    cmake --build build-mac -j --config Release
    cp build-mac/bin/whisper-cli "$DIST/transcribe"
    echo "=== Done: $DIST/transcribe ==="

elif [ "$OS" = "Linux" ]; then
    echo "=== Linux detected: building GPU and CPU binaries ==="

    echo "--- Configuring GPU build ---"
    cmake -DBUILD_SHARED_LIBS=off -DGGML_CUDA=1 -DGGML_NATIVE=OFF -B build-gpu
    echo "--- Building GPU binary ---"
    cmake --build build-gpu -j --config Release

    echo "--- Configuring CPU build ---"
    cmake -DBUILD_SHARED_LIBS=off -B build-cpu
    echo "--- Building CPU binary ---"
    cmake --build build-cpu -j --config Release

    cp build-gpu/bin/whisper-cli "$DIST/transcribe"
    cp build-cpu/bin/whisper-cli "$DIST/transcribe_cpu"
    echo "=== Done: $DIST/transcribe and $DIST/transcribe_cpu ==="

else
    echo "Unsupported OS: $OS" >&2
    exit 1
fi
