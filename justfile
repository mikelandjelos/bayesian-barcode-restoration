default:
    @just --list

bootstrap:
    ./scripts/bootstrap.sh

configure preset="dev-gcc":
    ./scripts/configure.sh {{preset}}

build preset="dev-gcc":
    cmake --build --preset {{preset}}

test preset="dev-gcc":
    ./scripts/test.sh {{preset}}

check:
    ./scripts/check-format.sh

format:
    ./scripts/format.sh

lint:
    ./scripts/lint.sh

asan:
    ./scripts/test.sh asan

ubsan:
    ./scripts/test.sh ubsan

tsan:
    ./scripts/test.sh tsan

coverage:
    ./scripts/coverage.sh

benchmark:
    ./scripts/benchmark.sh

docs:
    cmake -S . -B build/docs -G Ninja -DPROJECT_BUILD_DOCS=ON -DPROJECT_BUILD_TESTS=OFF
    cmake --build build/docs --target docs

clean:
    cmake -E rm -rf build
