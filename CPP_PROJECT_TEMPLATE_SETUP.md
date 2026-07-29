# Modern C++ Proof-of-Concept Project Template — Setup Specification

## Purpose

Configure `git@github.com:mikelandjelos/proj-template-cpppoc.git` as a reusable, Linux-first modern C++ project template.

The template must support a research-first workflow:

1. Explore and understand the problem using notebooks, scripts, simulations, and visualizations.
2. Stabilize the problem formulation and experiment pipeline.
3. Design the C++ architecture.
4. Implement reusable C++ library targets.
5. Build one or more applications on top of those libraries.
6. Add tests, benchmarks, profiling, documentation, and packaging only where they provide value.

The template must be broad and extensible, but its default generated state must remain small and understandable.

---

## Required technology choices

- C++20
- CMake using target-based modern CMake practices
- CMake Presets as the canonical build interface
- Ninja as the preferred generator
- GCC and Clang as first-class Linux compilers
- Conan 2 for dependency management
- GoogleTest integrated through CTest
- Google Benchmark as an optional benchmark target
- `clang-format`
- `clang-tidy`
- curated compiler warnings
- pre-commit hooks
- sanitizers through separate presets
- optional coverage support
- GitHub Actions CI
- Quarto-compatible research and reporting area
- optional `justfile` as a convenience interface

Do not add mandatory GUI, CUDA, OpenMP, Python bindings, Docker, package publishing, or platform installers.

---

## Repository structure

Create the following structure:

```text
.
├── CMakeLists.txt
├── CMakePresets.json
├── CMakeUserPresets.example.json
├── conanfile.py
├── justfile
│
├── cmake/
│   ├── ProjectOptions.cmake
│   ├── CompilerWarnings.cmake
│   ├── Sanitizers.cmake
│   ├── StaticAnalyzers.cmake
│   ├── Coverage.cmake
│   ├── Dependencies.cmake
│   └── Packaging.cmake
│
├── include/
│   └── project_name/
│       └── README.md
│
├── src/
│   ├── CMakeLists.txt
│   └── README.md
│
├── apps/
│   ├── CMakeLists.txt
│   └── project_cli/
│       ├── CMakeLists.txt
│       └── main.cpp
│
├── tests/
│   ├── CMakeLists.txt
│   ├── unit/
│   ├── integration/
│   └── test_data/
│       └── README.md
│
├── benchmarks/
│   ├── CMakeLists.txt
│   └── README.md
│
├── examples/
│   ├── CMakeLists.txt
│   └── README.md
│
├── research/
│   ├── README.md
│   ├── notebooks/
│   │   └── .gitkeep
│   ├── scripts/
│   │   └── .gitkeep
│   ├── reports/
│   │   └── .gitkeep
│   └── data/
│       ├── raw/
│       │   └── .gitkeep
│       ├── processed/
│       │   └── .gitkeep
│       └── README.md
│
├── docs/
│   ├── architecture/
│   │   └── README.md
│   ├── decisions/
│   │   ├── README.md
│   │   ├── 0001-use-cpp20.md
│   │   ├── 0002-use-conan.md
│   │   └── 0003-library-first-architecture.md
│   ├── images/
│   │   └── .gitkeep
│   └── Doxyfile.in
│
├── scripts/
│   ├── bootstrap.sh
│   ├── format.sh
│   ├── check-format.sh
│   ├── lint.sh
│   ├── test.sh
│   ├── coverage.sh
│   ├── benchmark.sh
│   └── profile-perf.sh
│
├── tools/
│   └── README.md
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── code-quality.yml
│   ├── ISSUE_TEMPLATE/
│   └── pull_request_template.md
│
├── .clang-format
├── .clang-tidy
├── .cmake-format.yaml
├── .editorconfig
├── .pre-commit-config.yaml
├── .gitignore
├── .gitattributes
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md
```

### Empty-directory policy

- Use a short `README.md` when a directory has a purpose or convention that needs explanation.
- Use `.gitkeep` only for intentionally empty directories whose existence is useful immediately.
- Do not add both unless the README does not itself preserve all required child directories.
- Remove optional directories from concrete projects when they are clearly unnecessary.

---

## C++ target architecture

The source tree must be library-first.

Create a reusable core target from `src/` and public headers from `include/`:

```cmake
add_library(project_core)
add_library(project::core ALIAS project_core)
```

Applications under `apps/` must link against the library:

```cmake
target_link_libraries(project_cli PRIVATE project::core)
```

Tests and benchmarks must also link against the same core target.

The library must be capable of being built as either static or shared through normal CMake behavior. Respect `BUILD_SHARED_LIBS`; do not hardcode `STATIC` or `SHARED` unless a specific future project requires it.

Requirements:

- Public headers live under `include/project_name/`.
- Private implementation files live under `src/`.
- Applications contain orchestration, input/output, configuration, and presentation logic—not core algorithms.
- Use namespaced aliases such as `project::core`.
- Use `target_compile_features(... PUBLIC cxx_std_20)`.
- Avoid global compiler flags and include directories.
- Avoid source globbing.
- Keep the root `CMakeLists.txt` small.

---

## CMake options

Provide project-prefixed options equivalent to:

```text
PROJECT_BUILD_TESTS
PROJECT_BUILD_BENCHMARKS
PROJECT_BUILD_EXAMPLES
PROJECT_BUILD_DOCS
PROJECT_BUILD_PYTHON_BINDINGS

PROJECT_ENABLE_WARNINGS
PROJECT_WARNINGS_AS_ERRORS
PROJECT_ENABLE_CLANG_TIDY
PROJECT_ENABLE_CPPCHECK
PROJECT_ENABLE_IPO

PROJECT_ENABLE_ASAN
PROJECT_ENABLE_UBSAN
PROJECT_ENABLE_TSAN
PROJECT_ENABLE_MSAN
PROJECT_ENABLE_COVERAGE
```

Rules:

- Expensive checks must be disabled in the ordinary development preset.
- Invalid sanitizer combinations must be rejected or documented.
- `PROJECT_BUILD_PYTHON_BINDINGS` is an extension point only; do not implement bindings now.
- `Packaging.cmake` may initially contain documented scaffolding rather than a complete packaging system.

---

## CMake presets

Create coherent configure, build, and test presets for:

```text
dev-gcc
dev-clang
debug
release
asan
ubsan
tsan
coverage
clang-tidy
benchmarks
ci-gcc
ci-clang
```

Required behavior:

- Development presets use Ninja and export `compile_commands.json`.
- Build directories live under `build/<preset-name>/`.
- Sanitizers are isolated in their own presets.
- Coverage is isolated in its own preset.
- Benchmarks are disabled unless the benchmark preset is selected.
- CI presets may enable warnings as errors.
- Local machine overrides belong in ignored `CMakeUserPresets.json`.
- Commit `CMakeUserPresets.example.json` as documentation.

Do not add Windows and macOS presets until they are actually tested. Document how they can be added.

---

## Conan 2

Use `conanfile.py`.

Initial dependencies:

- GoogleTest
- Google Benchmark

Provide easy extension points for:

- Eigen
- fmt
- spdlog
- CLI11
- nlohmann/json
- pybind11

Requirements:

- Use Conan's CMake toolchain and dependency generators.
- Keep target usage package-manager-neutral: use `find_package` and imported targets.
- Do not reference Conan-specific variables throughout application targets.
- Support Debug and Release configurations.
- Document the normal install/configure workflow.
- Do not commit generated Conan build output.

Add documentation describing how dependency acquisition could later be migrated to vcpkg or `FetchContent` without rewriting target definitions. Do not implement multiple dependency managers simultaneously.

---

## Formatting and static analysis

### `clang-format`

Commit a customizable `.clang-format` based initially on LLVM with:

```text
IndentWidth: 4
ColumnLimit: 100
BreakBeforeBraces: Attach
PointerAlignment: Left
```

Keep the file easy to edit. Document the most relevant style switches in `CONTRIBUTING.md`.

### `clang-tidy`

Use a curated configuration based on:

```text
bugprone-*
performance-*
portability-*
modernize-*
readability-*
cppcoreguidelines-*
```

Do not enable every check blindly. Disable checks that conflict with the chosen style or create excessive noise.

Run `clang-tidy` through an explicit preset or script and in code-quality CI. Do not make it part of every normal incremental compile.

### Compiler warnings

Implement warnings through an interface target, for example:

```cmake
add_library(project_warnings INTERFACE)
add_library(project::warnings ALIAS project_warnings)
```

Use a curated GCC/Clang warning set. Handle `-Wconversion` and `-Wsign-conversion` deliberately so numerical projects can adjust their strictness.

### Additional repository checks

Configure appropriate tools for:

- CMake formatting
- Markdown linting
- YAML/JSON/TOML validation
- Python formatting/linting through Ruff when Python files exist
- ShellCheck
- optional `shfmt`
- notebook output stripping

---

## Pre-commit

Configure fast hooks for:

- trailing whitespace
- final newline normalization
- merge-conflict markers
- YAML, JSON, and TOML validation
- accidentally committed large files
- `clang-format`
- CMake formatting
- Markdown linting
- Ruff when applicable
- ShellCheck for changed shell scripts
- Jupyter notebook output stripping

Do not run full builds, complete tests, coverage, benchmarks, Valgrind, or full-project `clang-tidy` as normal pre-commit hooks.

Document:

```bash
pre-commit install
pre-commit run --all-files
```

---

## Testing

Use GoogleTest with CTest as the top-level runner.

Required organization:

```text
tests/unit/
tests/integration/
tests/test_data/
```

Requirements:

- Build tests only when `PROJECT_BUILD_TESTS` is enabled.
- Use `gtest_discover_tests`.
- Tests link to `project::core`.
- Provide one minimal unit test and one minimal integration-test example.
- Document deterministic random seeds.
- Document absolute, relative, and combined numerical tolerances.
- Prefer invariants and behavioral properties over brittle exact-value tests for stochastic algorithms.

Canonical command:

```bash
ctest --preset dev-gcc
```

Adjust the exact test preset name if needed, but keep the workflow consistent.

---

## Benchmarks and profiling

Use Google Benchmark behind `PROJECT_BUILD_BENCHMARKS`.

Provide:

- one minimal benchmark example,
- a benchmark preset,
- `scripts/benchmark.sh`,
- `scripts/profile-perf.sh` for Linux `perf`.

CI must build benchmark targets when appropriate, but must not enforce unstable timing thresholds on shared runners.

Provide sanitizer presets for:

- ASan
- UBSan
- TSan

Coverage support must work through a dedicated preset and script. Prefer a toolchain-appropriate backend such as `gcovr` for GCC or `llvm-cov` for Clang. It is acceptable for the initial template to support one documented coverage path cleanly rather than both poorly.

Do not add Heaptrack, Tracy, VTune, flamegraph tooling, or extensive Valgrind wrappers by default. Document them as optional future additions.

---

## Research workspace

The research workspace is language-neutral:

```text
research/
├── notebooks/
├── scripts/
├── reports/
└── data/
    ├── raw/
    └── processed/
```

Do not split it into Python, Julia, or R directories by default. Language-specific organization can emerge when a project needs it.

`research/README.md` must define this workflow:

1. Start with research, simulation, notebooks, scripts, and visualizations.
2. Make random seeds explicit.
3. Keep notebooks executable from top to bottom where practical.
4. Clear large notebook outputs before committing.
5. Move reusable logic out of notebooks into scripts/modules.
6. Keep large or generated datasets out of Git.
7. Use small committed fixtures only when they are needed for examples or tests.
8. Move stable findings into reports or project documentation.
9. Begin C++ design only after the problem and experimental pipeline are sufficiently understood.

Do not force a Python, Julia, or R environment on every project.

Support Quarto by documenting that `.qmd` reports may live in `research/reports/`. Do not require Quarto for building the C++ project.

---

## C++ and research-code interoperability

Do not implement interoperability now.

Document optional future approaches in `docs/architecture/research-interoperability.md`:

1. Exchange CSV, JSON, JSON Lines, or domain-specific result files.
2. Launch the C++ application from research scripts as a subprocess.
3. Add optional `pybind11` bindings when interactive C++ access becomes justified.

State clearly that these are opt-in patterns, not template defaults.

---

## Reproducible experiments

Document a recommended, optional experiment-output convention:

```text
artifacts/<run-name>/
├── config.toml
├── metadata.json
├── results.*
└── metrics.json
```

Recommended metadata:

- random seed,
- Git commit,
- compiler and version,
- build type,
- relevant system information,
- configuration,
- timing and metrics.

Ignore `artifacts/` by default. Projects may commit selected small representative results intentionally.

Do not introduce a configuration library or experiment framework in the template unless a concrete project needs one.

---

## Documentation

Create:

- a root `README.md` with the shortest successful setup/build/test workflow,
- `CONTRIBUTING.md` with formatting, checks, presets, and extension guidance,
- `docs/architecture/README.md`,
- lightweight ADRs under `docs/decisions/`,
- optional Doxygen scaffolding.

Required ADRs:

- C++20
- Conan 2
- library-first architecture

Document that Quarto is intended for research narratives and experiment reports, while Doxygen is intended for C++ API documentation.

---

## Convenience commands

CMake Presets are the canonical implementation interface.

Add a `justfile` as a thin convenience layer with recipes equivalent to:

```text
bootstrap
configure
build
test
check
format
lint
asan
ubsan
tsan
coverage
benchmark
docs
clean
```

Rules:

- Recipes must delegate to CMake presets and scripts.
- Do not duplicate build logic in `justfile`.
- The project must remain usable without `just`.

---

## GitHub Actions

Create an intentionally small initial CI configuration.

### Pull-request CI

- Ubuntu + GCC: configure, build, and test.
- Ubuntu + Clang: configure, build, and test.
- Clang sanitizer lane: ASan + UBSan, if the configuration supports a clean combined lane; otherwise separate them.
- Code-quality lane: formatting and curated static checks.

Requirements:

- Use the same CMake presets used locally.
- Cache dependency downloads carefully.
- Upload useful logs when tests fail.
- Do not run benchmark regressions on shared runners.
- Use warnings as errors in CI where practical.
- Do not claim Windows/macOS support until those jobs exist and pass.

---

## Git ignore policy

Ignore at least:

```text
build/
CMakeUserPresets.json
compile_commands.json
.conan*/
__pycache__/
.ipynb_checkpoints/
artifacts/
coverage output
profiling output
editor-local files
OS-local files
large/generated research data
```

Do not ignore small test fixtures or intentionally committed example data.

---

## Bootstrap workflow

The final README must make this workflow obvious:

```bash
git clone <repository>
cd <repository>

./scripts/bootstrap.sh
conan install . --build=missing <documented arguments>
cmake --preset dev-gcc
cmake --build --preset dev-gcc
ctest --preset dev-gcc
```

It is acceptable for `bootstrap.sh` to verify dependencies and print installation guidance rather than modifying the host aggressively.

---

## Acceptance criteria

The setup is complete when all of the following are true:

- A clean Linux clone has a documented path to configure, build, and test.
- GCC and Clang development presets work.
- `project_core` builds and is linkable by applications, tests, and benchmarks.
- `BUILD_SHARED_LIBS=OFF` and `BUILD_SHARED_LIBS=ON` are both supported by the core target where the platform allows it.
- The sample CLI links against `project::core`.
- GoogleTest tests are discovered by CTest.
- Google Benchmark builds only when enabled.
- Formatting can be checked without rewriting files.
- Formatting can be applied explicitly.
- `clang-tidy` can be run explicitly.
- Pre-commit hooks can be installed and pass on the clean repository.
- ASan, UBSan, and TSan have distinct documented workflows.
- Coverage has one functioning documented workflow.
- CI uses repository presets rather than separate undocumented commands.
- The research workspace has documented conventions but no mandatory language environment.
- Research interoperability is documented but not implemented.
- Conan is the only active dependency manager.
- Migration principles for vcpkg or `FetchContent` are documented.
- Optional features do not complicate the normal development path.
- No generated build output is committed.

---

## Non-goals

Do not implement the following as part of the initial template:

- project-specific Lost Drone algorithms,
- GUI frameworks,
- CUDA,
- mandatory OpenMP,
- Python bindings,
- Julia or R environments,
- container orchestration,
- release automation,
- package registries,
- installers,
- deployment infrastructure,
- benchmark databases,
- multiple dependency managers,
- exhaustive platform matrices.

The result must be a clean foundation, not a demonstration of every available tool.
