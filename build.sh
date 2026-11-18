#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TOOLCHAIN=${TOOLCHAIN:?Set TOOLCHAIN to ARM64 musl toolchain directory}
SOURCE_ARCHIVE=${SOURCE_ARCHIVE:?Set SOURCE_ARCHIVE to upstream 3x-ui v3.11.0 tar.gz}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
trap 'exit 1' HUP INT TERM

mkdir -p "$ROOT/release"

echo "=== EXTRACT SOURCE ==="
tar -xzf "$SOURCE_ARCHIVE" -C "$WORK" --strip-components=1

echo "=== APPLY PATCHES ==="
docker run --rm \
  -v "$WORK:/src" \
  -v "$ROOT/patches:/patches:ro" \
  -w /src \
  --entrypoint sh alpine/git -c '
    set -eu
    git apply /patches/keenetic-disk.patch
    git apply /patches/xray-restart.patch
  '

echo "=== BUILD FRONTEND ==="
docker run --rm \
  -v "$WORK:/input:ro" \
  -v "$WORK/internal/web:/output" \
  --entrypoint sh node:26-bookworm -c '
    set -eu

    mkdir -p /build
    cp -a /input/frontend /build/frontend
    cp -a /input/internal /build/internal

    cd /build/frontend
    npm ci --ignore-scripts
    node scripts/build-openapi.mjs
    node node_modules/vite/bin/vite.js build

    test -f /build/internal/web/dist/index.html

    cp -a /build/internal/web/dist /output/
  '

echo "=== BUILD ARM64 STATIC BINARY ==="
docker run --rm \
  -v "$WORK:/src" \
  -v "$TOOLCHAIN:/toolchain:ro" \
  -v "$ROOT/release:/out" \
  -w /src \
  --entrypoint sh golang:1.27.3-bookworm -c '
    set -eu

    export PATH=/toolchain/bin:$PATH
    export CC=aarch64-buildroot-linux-musl-gcc
    export CGO_ENABLED=1
    export CGO_CFLAGS=-D_LARGEFILE64_SOURCE
    export GOOS=linux
    export GOARCH=arm64
    export GOARM64=v8.0

    go build \
      -ldflags="-w -s -linkmode external -extldflags=-static" \
      -o /out/xui-linux-arm64-rebuilt .
  '

echo "=== RESULT ==="
sha256sum "$ROOT/release/xui-linux-arm64-rebuilt"
