#!/usr/bin/env bash
set -euo pipefail

find include src apps tests benchmarks examples -type f \( -name '*.cpp' -o -name '*.hpp' \) -print0 |
  xargs -0 -r clang-format -i
