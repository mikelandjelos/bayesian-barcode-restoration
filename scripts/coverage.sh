#!/usr/bin/env bash
set -euo pipefail

./scripts/test.sh coverage
if command -v gcovr >/dev/null 2>&1; then
  gcovr --root . --filter '^(include|src|apps)/' --html-details coverage/index.html
else
  printf 'Tests completed; install gcovr to generate HTML coverage output.\n'
fi
