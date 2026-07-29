# Modern C++ Proof-of-Concept Template

A reusable, Linux-first C++20 foundation for projects that begin with research
PoCs (often handled through interactive Python/R/Julia notebooks)
and mature into C++ software. The template is designed for
simulations, numerical work, systems experiments, computer vision, and similar
proofs of concept - without forcing every project to carry unnecessary tooling.

## Status

The initial template scaffold is in place. Its design contract is defined by
two companion documents:

- [Setup specification](CPP_PROJECT_TEMPLATE_SETUP.md) is the concrete build
  checklist: repository layout, CMake targets and presets, Conan, checks, CI,
  and acceptance criteria.
- [Living project guide](CPP_PROJECT_TEMPLATE_LIVING_GUIDE.md) is the evolving
  policy: what is required, optional, conditional, deferred, or still to do.

The living guide tracks the remaining optional and follow-up work.

## Baseline

- C++20, modern target-based CMake, CMake Presets, and Ninja.
- GCC and Clang as first-class Linux compilers.
- Conan 2 for dependencies, while CMake targets remain package-manager-neutral
  through `find_package` and imported targets.
- A library-first architecture: public headers in `include/`, implementation
  in `src/`, and applications, tests, and benchmarks linked to the same core
  library.
- GoogleTest with CTest; Google Benchmark only when explicitly enabled.
- `clang-format`, curated `clang-tidy`, compiler warnings, pre-commit hooks,
  isolated sanitizer presets, and optional coverage.
- A language-neutral research workspace with Quarto-compatible reports.
- A `justfile` from the initial setup for memorable everyday commands.
- Small GitHub Actions checks using the same presets as local development.

Windows and macOS are not claimed as supported until their CI lanes are added
and maintained. GUI frameworks, CUDA, OpenMP, Python bindings, containers,
packaging, and release automation are intentionally outside the initial
baseline.

## Quick start

A clean Linux checkout needs CMake 3.28+, Ninja, a GCC or Clang compiler, and
Conan 2. The bootstrap script checks these prerequisites without installing
anything on the host.

```bash
git clone <repository>
cd <repository>

./scripts/bootstrap.sh
./scripts/configure.sh dev-gcc
cmake --build --preset dev-gcc
ctest --preset dev-gcc
```

CMake Presets are canonical. The included `justfile` offers shortcuts such as
`just test`, `just format`, and `just asan`; its recipes only delegate to the
canonical CMake and script commands. The project remains fully usable without
`just`.

## Repository map

```text
include/      Public C++ headers
src/          Reusable C++ implementation and core library target
apps/         Executable entry points
tests/        Unit tests, integration tests, and small test fixtures
benchmarks/   Opt-in microbenchmarks
examples/     Small consumer examples
research/     Notebooks, scripts, reports, and data conventions
docs/         Architecture notes, ADRs, and API-documentation scaffolding
cmake/        Focused CMake modules
scripts/      Thin, explicit automation wrappers
tools/        Project-local development tools when justified
```

Use a directory README when a convention needs explanation and `.gitkeep` only
for intentionally empty directories whose presence matters. Concrete projects
should remove optional areas that do not serve them.

## Project approach - additional context

1. Explore the problem with notebooks, scripts, simulations, and
   visualizations.
2. Validate assumptions and stabilize the experimental pipeline.
3. Design reusable C++ library boundaries.
4. Implement applications, tests, and benchmarks on those same libraries.
5. Add specialized tooling only when evidence shows it is useful.

Research and C++ code are intentionally separate by default. If integration is
needed later, prefer documented file exchange first, subprocess orchestration
second, and language bindings only when they are justified by a stable API and
workflow.

## Where to look next

- Start implementation from the ordered acceptance criteria in the
  [setup specification](CPP_PROJECT_TEMPLATE_SETUP.md#acceptance-criteria).
- Use the [initial implementation tracker](CPP_PROJECT_TEMPLATE_LIVING_GUIDE.md#21-initial-implementation-tracker)
  to record completed work and verification dates.
- Revisit the [open questions](CPP_PROJECT_TEMPLATE_LIVING_GUIDE.md#24-open-questions-to-revisit-after-practical-use)
  only after practical use exposes real friction.
