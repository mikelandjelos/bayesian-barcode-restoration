#!/usr/bin/env bash
set -euo pipefail

preset="${1:-clang-tidy}"
./scripts/configure.sh "$preset"
cmake --build --preset "$preset"
