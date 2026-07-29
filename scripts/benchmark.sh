#!/usr/bin/env bash
set -euo pipefail

./scripts/configure.sh benchmarks
cmake --build --preset benchmarks
./build/benchmarks/benchmarks/project_core_benchmarks
