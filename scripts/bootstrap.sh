#!/usr/bin/env bash
set -euo pipefail

required=(cmake ninja conan)
missing=()
for command in "${required[@]}"; do
  command -v "$command" >/dev/null 2>&1 || missing+=("$command")
done

if ((${#missing[@]})); then
  printf 'Missing required tools: %s\n' "${missing[*]}" >&2
  printf 'Install CMake (>= 3.28), Ninja, and Conan 2, then retry.\n' >&2
  exit 1
fi

printf 'Required build tools are available.\n'
if ! conan profile path default >/dev/null 2>&1; then
  printf 'Creating Conan default profile from the detected compiler environment.\n'
  conan profile detect --force
fi
printf 'Next: ./scripts/configure.sh dev-gcc\n'
