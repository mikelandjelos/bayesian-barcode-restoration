#!/usr/bin/env bash
set -euo pipefail

preset="${1:-dev-gcc}"
build_dir="build/${preset}"
build_type="Debug"
compiler_args=()
conan_command=(conan)

if ! conan profile path default >/dev/null 2>&1; then
  printf 'Creating Conan default profile from the detected compiler environment.\n'
  conan profile detect --force
fi

case "$preset" in
  release|benchmarks) build_type="Release" ;;
esac
case "$preset" in
  *clang*|asan|ubsan|tsan)
    compiler_args=(-s compiler=clang -s compiler.version=18 -s compiler.libcxx=libstdc++11)
    conan_command=(env CC=clang CXX=clang++ conan)
    ;;
esac

"${conan_command[@]}" install . --build=missing --output-folder="$build_dir" -s build_type="$build_type" \
  -s compiler.cppstd=20 "${compiler_args[@]}"
cmake --preset "$preset" -DCMAKE_TOOLCHAIN_FILE="${build_dir}/conan/conan_toolchain.cmake"
