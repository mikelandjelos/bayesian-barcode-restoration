#!/usr/bin/env bash
set -euo pipefail

./scripts/configure.sh release
cmake --build --preset release
perf record --call-graph dwarf ./build/release/apps/project_cli/project_cli
printf 'Profile captured in perf.data; inspect it with: perf report\n'
