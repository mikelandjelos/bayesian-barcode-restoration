#!/usr/bin/env bash
set -euo pipefail

preset="${1:-dev-gcc}"
./scripts/configure.sh "$preset"
cmake --build --preset "$preset"
ctest --preset "$preset"
