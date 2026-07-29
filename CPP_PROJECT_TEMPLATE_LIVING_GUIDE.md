# Modern C++ Proof-of-Concept Template — Living Project Guide

## Document purpose

This is the long-lived design and evolution guide for the C++ project template.

Use it to answer four questions:

1. What is already part of the template?
2. What should every project do?
3. What may a project add when a concrete condition is met?
4. How should the template itself evolve without accumulating unnecessary complexity?

This document is broader than the initial setup specification. It should be updated whenever the template gains, removes, or materially changes a capability.

---

## Status vocabulary

Use these markers throughout this document:

- **[REQUIRED]** — part of the baseline template or mandatory project convention.
- **[DEFAULT]** — enabled or recommended for ordinary projects, but adjustable.
- **[OPTIONAL]** — supported pattern that should be added only when useful.
- **[CONDITIONAL]** — add when the stated condition becomes true.
- **[DOCUMENT-ONLY]** — explain the path, but do not implement it in the base template.
- **[DEFERRED]** — intentionally not part of the current template.
- **[PROJECT-SPECIFIC]** — belongs in a concrete project rather than the shared template.
- **[DONE]** — implemented and verified in the template.
- **[TODO]** — approved work that has not yet been completed.
- **[REVIEW]** — implemented or proposed, but should be reconsidered after practical use.

When the initial Codex setup is completed, replace appropriate `[TODO]` markers with `[DONE]` and record the verification date.

---

# 1. Project philosophy

## 1.1 Research first, implementation second

**[REQUIRED]** The intended workflow is:

1. Investigate the domain.
2. Develop simulations, notebooks, scripts, and visualizations.
3. Validate assumptions and understand failure modes.
4. Stabilize the conceptual and experimental pipeline.
5. Design the C++ system.
6. Implement reusable C++ components.
7. Build applications on top of those components.
8. Add deeper optimization, profiling, bindings, or packaging only after evidence justifies them.

Research code is allowed to be exploratory. Production C++ code is expected to become explicit, tested, modular, and maintainable.

**[DEFAULT]** The research implementation and C++ implementation do not need direct interoperability.

**[DOCUMENT-ONLY]** Keep a documented path for future file exchange, subprocess orchestration, or language bindings.

## 1.2 Broad, not bloated

**[REQUIRED]** The template must provide extension points without pre-installing every possible subsystem.

A capability belongs in the baseline only when it satisfies most of these:

- useful across many numerical, systems, computer-vision, simulation, or robotics projects,
- inexpensive to understand,
- inexpensive during the ordinary build,
- maintainable on Linux,
- does not force a project-specific architecture,
- composes cleanly with CMake targets and presets.

A capability should remain optional when it introduces a substantial dependency, platform assumption, runtime, or maintenance burden.

## 1.3 Linux-first portability

**[REQUIRED]** Linux is the reference development and CI platform.

**[REQUIRED]** GCC and Clang are first-class compilers.

**[REQUIRED]** Project code should use standard C++ and target-based CMake unless platform-specific behavior is genuinely required.

**[CONDITIONAL]** Add MSVC support when a real project needs Windows or when a maintained Windows CI lane is introduced.

**[CONDITIONAL]** Add AppleClang support when a real project needs macOS or when a maintained macOS CI lane is introduced.

**[REQUIRED]** Do not advertise a platform as supported merely because the code might compile there.

---

# 2. Baseline repository state

## 2.1 Core layout

**[TODO]** Establish:

```text
include/       public C++ headers
src/           reusable C++ implementation
apps/          executable applications
tests/         unit and integration tests
benchmarks/    microbenchmarks
examples/      small usage examples
research/      notebooks, scripts, reports, and data conventions
docs/          architecture, ADRs, and API-documentation scaffolding
cmake/         focused CMake modules
scripts/       thin automation wrappers
tools/         project-local development tools when justified
.github/       CI and collaboration metadata
```

## 2.2 Empty directories

**[REQUIRED]** Use a README when a directory's purpose or rules need explanation.

**[REQUIRED]** Use `.gitkeep` for intentionally empty leaf directories that should exist immediately.

**[DEFAULT]** Do not place both in the same directory unless the README preserves the parent while `.gitkeep` preserves empty child directories.

**[CONDITIONAL]** Remove unused optional directories from a concrete project when their absence makes the project clearer.

## 2.3 Naming

**[REQUIRED]** Replace generic placeholders such as:

```text
project_name
PROJECT_
project_core
project::core
project_cli
```

when creating a concrete repository from the template.

**[DEFAULT]** Use lowercase snake_case for target implementation names and `project::component` aliases for consumer-facing CMake targets.

---

# 3. C++ architecture

## 3.1 Library-first design

**[REQUIRED]** Code under `src/` must be buildable as one or more reusable library targets.

**[REQUIRED]** Applications under `apps/` must link to libraries rather than compile core implementation files directly.

**[REQUIRED]** Tests and benchmarks must exercise the same library targets used by applications.

**[DEFAULT]** Begin with one core target:

```text
project_core
project::core
```

**[CONDITIONAL]** Split the core into multiple targets when at least one condition holds:

- components have genuinely different dependency sets,
- components have different stability or ownership boundaries,
- one component should be reusable without the rest,
- compile time has become meaningfully problematic,
- platform-specific implementations need separation,
- a plugin or backend architecture has emerged.

Do not split targets merely to mirror every source-code directory.

## 3.2 Static and shared libraries

**[REQUIRED]** Do not hardcode `STATIC` or `SHARED` for ordinary reusable targets.

**[REQUIRED]** Respect `BUILD_SHARED_LIBS` so a project can choose static or shared output later.

**[CONDITIONAL]** Add symbol-visibility and export-header handling when shared-library distribution becomes a real requirement.

**[CONDITIONAL]** Hardcode a library type only when the target's semantics require it, such as a plugin module or an internal object library.

## 3.3 Public and private API

**[REQUIRED]** Public headers live under:

```text
include/<project_name>/
```

**[REQUIRED]** Implementation details live under `src/` and are not added to public include paths.

**[DEFAULT]** Keep the public API smaller than the implementation surface.

**[CONDITIONAL]** Add an `internal/` or `detail/` namespace when implementation helpers must appear in headers but are not supported API.

## 3.4 Applications

**[DEFAULT]** A CLI application is the smallest reference consumer.

**[CONDITIONAL]** Add additional applications when they represent different user-facing entry points, for example:

- simulator,
- visualizer,
- dataset converter,
- benchmark driver,
- service,
- desktop GUI.

**[REQUIRED]** Keep argument parsing, filesystem orchestration, configuration loading, and presentation at the application boundary where practical.

---

# 4. CMake policy

## 4.1 General rules

**[REQUIRED]** Use modern target-based CMake.

**[REQUIRED]** Avoid global `include_directories`, `link_libraries`, definitions, and compiler flags.

**[REQUIRED]** Avoid source globbing in the baseline template.

**[REQUIRED]** Keep the root `CMakeLists.txt` focused on project declaration, options, dependency setup, and subdirectories.

**[REQUIRED]** Use imported dependency targets and project aliases.

**[DEFAULT]** Require C++20 through target compile features.

**[CONDITIONAL]** Move to C++23 only after the compiler support requirements of actual projects are clear.

## 4.2 Options

**[TODO]** Provide prefixed build and analysis options.

**[REQUIRED]** Options must not conflict silently.

**[DEFAULT]** Normal development enables warnings, tests, and compile-command export.

**[DEFAULT]** Normal development disables benchmarks, coverage, documentation, and expensive static analysis.

**[CONDITIONAL]** Add a new option only when a real optional subsystem exists. Avoid speculative switches with no implementation.

## 4.3 Presets

**[TODO]** Add development, release, sanitizer, coverage, benchmark, static-analysis, and CI presets.

**[REQUIRED]** Presets are the canonical local and CI interface.

**[REQUIRED]** Use separate build directories per preset.

**[REQUIRED]** Keep user-local overrides in ignored `CMakeUserPresets.json`.

**[CONDITIONAL]** Add platform presets only after they are tested.

**[REVIEW]** Revisit preset names after several concrete projects use the template. Names should describe intent, not implementation accidents.

---

# 5. Dependencies

## 5.1 Conan 2

**[REQUIRED]** Conan 2 is the active dependency manager.

**[TODO]** Implement `conanfile.py` and documented profiles/workflows.

**[REQUIRED]** CMake targets consume packages through `find_package` and imported targets.

**[REQUIRED]** Keep Conan-specific setup at the dependency/toolchain boundary rather than throughout target definitions.

**[DEFAULT]** Baseline dependencies:

- GoogleTest,
- Google Benchmark.

**[CONDITIONAL]** Add common packages only when used by the concrete project:

- Eigen for linear algebra,
- fmt for formatting,
- spdlog for logging,
- CLI11 for command-line parsing,
- nlohmann/json for JSON,
- pybind11 for Python bindings.

**[REQUIRED]** Pin dependency versions deliberately.

**[CONDITIONAL]** Introduce Conan lockfiles when reproducible dependency graphs across machines or releases become important.

## 5.2 Possible migration to vcpkg

**[DOCUMENT-ONLY]** Document a future migration path to vcpkg.

A migration should ideally affect:

- dependency manifest,
- toolchain configuration,
- presets,
- bootstrap documentation.

It should not require rewriting ordinary target declarations that already use imported targets.

**[DEFERRED]** Do not support Conan and vcpkg simultaneously in the baseline template.

## 5.3 Possible migration to FetchContent

**[DOCUMENT-ONLY]** Document `FetchContent` or CPM.cmake as a simpler alternative for small standalone projects.

**[CONDITIONAL]** Consider it when:

- the dependency set is very small,
- external package-manager installation is undesirable,
- all dependencies build cleanly from source,
- binary-package caching is unimportant.

**[DEFERRED]** Do not add parallel dependency acquisition paths to the same baseline build.

---

# 6. Formatting, warnings, and analysis

## 6.1 Formatting

**[TODO]** Commit `.clang-format`.

**[DEFAULT]** Initial style:

- LLVM base,
- four-space indentation,
- 100-column limit,
- attached braces,
- left-aligned pointers.

**[REQUIRED]** Formatting rules are project policy and may be changed intentionally.

**[REQUIRED]** Provide both:

- a command that applies formatting,
- a command that only verifies formatting.

**[CONDITIONAL]** Change the style only through an explicit repository decision; avoid style drift file by file.

## 6.2 Compiler warnings

**[TODO]** Implement a warnings interface target.

**[REQUIRED]** Warnings are compiler-specific and target-scoped.

**[DEFAULT]** Enable strong GCC/Clang warnings.

**[REVIEW]** Evaluate `-Wconversion` and `-Wsign-conversion` on numerical projects. They may be:

- always enabled,
- enabled only in strict CI,
- enabled with narrow local suppressions.

**[DEFAULT]** Treat warnings as errors in CI for project-owned code.

**[CONDITIONAL]** Do not propagate project warning policy to external consumers when the core becomes an installable library.

## 6.3 `clang-tidy`

**[TODO]** Add a curated `.clang-tidy`.

**[REQUIRED]** Do not enable all checks.

**[DEFAULT]** Draw from bug-prone, performance, portability, modernization, readability, and selected C++ Core Guidelines checks.

**[REQUIRED]** Run it explicitly and in code-quality CI, not on every ordinary compile.

**[CONDITIONAL]** Add naming rules only after the repository has settled on a consistent naming convention.

**[CONDITIONAL]** Tighten checks gradually after evaluating false positives in real projects.

## 6.4 Other analysis tools

**[OPTIONAL]** Cppcheck may be added as an additional static-analysis lane.

**[CONDITIONAL]** Add it when it produces distinct, useful findings rather than duplicating compiler and clang-tidy diagnostics.

**[OPTIONAL]** Include-what-you-use may be added later.

**[CONDITIONAL]** Add it when include hygiene or compile times become a demonstrated issue.

---

# 7. Pre-commit and local checks

## 7.1 Fast hook policy

**[REQUIRED]** Pre-commit checks must remain fast enough for normal use.

**[TODO]** Add hooks for:

- whitespace and final newlines,
- merge-conflict markers,
- structured-file validation,
- large-file prevention,
- C++ formatting,
- CMake formatting,
- Markdown linting,
- Ruff when Python exists,
- ShellCheck,
- notebook output stripping.

**[REQUIRED]** Do not run full builds, full tests, coverage, benchmarks, Valgrind, or whole-project clang-tidy on each commit.

## 7.2 Escalation model

**[DEFAULT]** Use this cost hierarchy:

```text
pre-commit         very fast repository hygiene
local check        build + tests + selected analysis
CI                 complete supported compiler matrix
manual/nightly     expensive profiling and deep analysis
```

**[CONDITIONAL]** Add a pre-push hook only if the team consistently benefits from it. Do not make it the only way to run important checks.

---

# 8. Testing strategy

## 8.1 Framework

**[REQUIRED]** GoogleTest is the C++ testing framework.

**[REQUIRED]** CTest is the top-level runner.

**[TODO]** Provide unit and integration examples.

## 8.2 Test types

**[REQUIRED]** Unit tests cover focused behavior and invariants.

**[REQUIRED]** Integration tests cover meaningful component flows and application boundaries.

**[OPTIONAL]** Regression tests capture previously fixed failures.

**[CONDITIONAL]** Add regression fixtures whenever a real bug can be represented compactly and deterministically.

**[OPTIONAL]** Property-based testing may be introduced.

**[CONDITIONAL]** Add it when algorithms have strong invariants across large input spaces and example-based tests are insufficient.

## 8.3 Numerical and stochastic tests

**[REQUIRED]** Document and use appropriate tolerance strategies.

**[REQUIRED]** Explicitly seed pseudo-random generators in tests.

**[DEFAULT]** Prefer properties such as conservation, normalization, valid ranges, reproducibility, convergence tendencies, and monotonicity over exact stochastic traces.

**[CONDITIONAL]** Use statistical assertions only when their expected false-positive rate and sample cost are understood.

## 8.4 Test data

**[REQUIRED]** Commit only small, intentional test fixtures.

**[CONDITIONAL]** Add download or generation scripts for large datasets.

**[REQUIRED]** Explain fixture provenance and licensing when external data is included.

---

# 9. Benchmarks and performance work

## 9.1 Google Benchmark

**[TODO]** Add optional Google Benchmark support.

**[REQUIRED]** Benchmarks are separate from correctness tests.

**[REQUIRED]** Benchmarks link against production library targets.

**[DEFAULT]** CI may compile or smoke-run benchmarks but must not enforce noisy timing thresholds on shared runners.

**[CONDITIONAL]** Introduce benchmark baselines only when runs occur on controlled hardware or a sufficiently stable environment.

## 9.2 Profiling

**[TODO]** Add a small Linux `perf` wrapper.

**[OPTIONAL]** Valgrind Memcheck.

**[CONDITIONAL]** Add when sanitizer coverage is insufficient, platform constraints require it, or leak diagnostics need an independent tool.

**[OPTIONAL]** Cachegrind/Callgrind.

**[CONDITIONAL]** Add when cache behavior or call-level cost is a demonstrated bottleneck.

**[OPTIONAL]** Heaptrack or Massif.

**[CONDITIONAL]** Add when allocation volume or peak memory becomes a real concern.

**[OPTIONAL]** Tracy, VTune, or similar tooling.

**[CONDITIONAL]** Add when interactive tracing, multithreaded timing, or hardware-specific performance analysis is justified.

## 9.3 Parallelism and accelerators

**[DEFERRED]** OpenMP is not mandatory.

**[CONDITIONAL]** Add OpenMP when profiling demonstrates suitable data or loop parallelism and the dependency is acceptable.

**[DEFERRED]** CUDA is not part of the base template.

**[CONDITIONAL]** Add CUDA as a project-specific language/toolchain extension when GPU computation is central rather than speculative.

**[CONDITIONAL]** Add SIMD-specific modules only when supported by benchmarks and isolated behind portable interfaces where practical.

---

# 10. Sanitizers and coverage

## 10.1 Sanitizers

**[TODO]** Add separate ASan, UBSan, and TSan presets.

**[REQUIRED]** Reject or avoid unsupported combinations.

**[DEFAULT]** ASan and UBSan may share a lane if the compiler/platform configuration is verified.

**[REQUIRED]** TSan runs separately.

**[OPTIONAL]** MSan.

**[CONDITIONAL]** Add only in a controlled Clang environment where all relevant dependencies are compatible or instrumented appropriately.

## 10.2 Coverage

**[TODO]** Provide one complete, reliable coverage workflow.

**[DEFAULT]** Prefer simplicity over supporting every compiler immediately.

**[CONDITIONAL]** Add a second compiler-specific coverage backend only when users need it and CI can maintain it.

**[REQUIRED]** Coverage output is generated and ignored, not committed.

**[REQUIRED]** Coverage percentage is context, not a substitute for meaningful tests.

---

# 11. Research workspace

## 11.1 Structure

**[TODO]** Establish a language-neutral research area:

```text
research/
├── notebooks/
├── scripts/
├── reports/
└── data/
    ├── raw/
    └── processed/
```

**[REQUIRED]** Do not pre-split the workspace by programming language.

**[CONDITIONAL]** Introduce language-specific subdirectories when multiple ecosystems create naming, environment, or packaging conflicts.

## 11.2 Research rules

**[REQUIRED]** Every notebook or script should have a clear experiment or question.

**[REQUIRED]** Random seeds should be explicit where reproducibility matters.

**[DEFAULT]** Notebooks should execute top-to-bottom.

**[REQUIRED]** Clear large or irrelevant outputs before commit.

**[REQUIRED]** Move reusable code out of notebooks when it becomes stable.

**[REQUIRED]** Keep generated and large datasets outside Git.

**[DEFAULT]** Preserve stable findings in a report, ADR, architecture note, or project README.

## 11.3 Environment management

**[DEFERRED]** Do not require Python, Julia, or R in every project.

**[CONDITIONAL]** Add a Python environment when Python scripts or notebooks become part of the project's reproducible workflow.

Possible choices:

- `uv` with `pyproject.toml`,
- Poetry,
- Conda/Mamba when complex native scientific dependencies justify it.

**[CONDITIONAL]** Add Julia's project environment when Julia code becomes reproducible project material.

**[CONDITIONAL]** Add an R project/lockfile when R code becomes reproducible project material.

**[REQUIRED]** Keep research-environment setup independent from the core C++ build unless integration becomes intentional.

## 11.4 Quarto

**[DEFAULT]** Quarto is the preferred report format when a project needs executable or publication-oriented technical reports.

**[REQUIRED]** Quarto is not required to configure or build the C++ project.

**[CONDITIONAL]** Add CI rendering only when reports are stable deliverables and their environments are reproducible.

---

# 12. Research and C++ interoperability

## 12.1 Baseline policy

**[DOCUMENT-ONLY]** The base template documents interoperability but does not implement it.

No project should add bindings or data bridges merely because they may be useful someday.

## 12.2 File exchange

**[CONDITIONAL]** Use file exchange when research tools need to analyze C++ results and loose coupling is sufficient.

Possible formats:

- CSV for simple tables,
- JSON or JSON Lines for structured records,
- images for visual outputs,
- domain-specific binary formats when scale requires them.

Use this first because it is simple, inspectable, and language-neutral.

## 12.3 Subprocess orchestration

**[CONDITIONAL]** Launch a C++ executable from a research script when experiments need automated parameter sweeps but bindings are unnecessary.

The C++ executable should expose stable configuration and output conventions before this is adopted.

## 12.4 Python bindings

**[CONDITIONAL]** Add pybind11 only when interactive use of C++ objects or zero-copy/high-frequency calls materially improve the workflow.

Before adding bindings, confirm:

- the public C++ API is stable enough,
- ownership and lifetime semantics are clear,
- packaging the extension is worth the maintenance cost,
- file or subprocess integration is insufficient.

**[DEFERRED]** Julia and R native bindings are outside the baseline. Add project-specific bridges only when demanded by a real workflow.

---

# 13. Experiment reproducibility

## 13.1 Configuration

**[DEFAULT]** Use human-readable configuration for repeatable experiments, with TOML as the preferred starting point.

**[CONDITIONAL]** Add a configuration parsing dependency only when application configuration becomes real.

**[PROJECT-SPECIFIC]** Configuration schemas, validation, and defaults belong to the concrete project.

## 13.2 Run artifacts

**[DEFAULT]** A project may use:

```text
artifacts/<run-name>/
├── config.toml
├── metadata.json
├── results.*
└── metrics.json
```

**[REQUIRED]** Ignore generated artifacts by default.

**[CONDITIONAL]** Commit selected representative results only when small, stable, and useful for documentation or regression analysis.

## 13.3 Metadata

**[DEFAULT]** Preserve:

- random seed,
- Git commit,
- compiler and version,
- build type,
- system information relevant to results,
- experiment configuration,
- runtime and metrics.

**[CONDITIONAL]** Add dependency-lock or environment metadata when research results must be reproduced over long periods.

---

# 14. Documentation system

## 14.1 Root README

**[REQUIRED]** Explain:

- project purpose,
- prerequisite summary,
- shortest configure/build/test path,
- repository map,
- common presets and `just` commands,
- where research work belongs,
- where deeper documentation lives.

## 14.2 Contributing guide

**[REQUIRED]** Explain:

- formatting,
- warnings and static analysis,
- pre-commit installation,
- tests,
- benchmark policy,
- branch/commit expectations if any,
- how to add dependencies,
- how to add a target,
- how to add a preset without duplicating logic.

## 14.3 Architecture documentation

**[DEFAULT]** Keep architecture notes concise and current.

**[CONDITIONAL]** Add diagrams when they clarify component boundaries or data flow better than text.

## 14.4 ADRs

**[TODO]** Add initial ADRs for:

- C++20,
- Conan 2,
- library-first design.

**[CONDITIONAL]** Add an ADR when a decision:

- affects multiple modules,
- constrains future options,
- selects among meaningful alternatives,
- is likely to be questioned later.

Do not create ADRs for trivial implementation details.

## 14.5 API documentation

**[OPTIONAL]** Doxygen scaffolding belongs in the template.

**[CONDITIONAL]** Generate and publish Doxygen output when the public C++ API is substantial or consumed by others.

**[REQUIRED]** Do not use generated API docs as a substitute for architecture and usage documentation.

---

# 15. Developer interface

## 15.1 Canonical commands

**[REQUIRED]** CMake Presets are canonical.

A contributor must be able to work without `just`.

## 15.2 `justfile`

**[TODO]** Add a thin `justfile` for memorable commands.

**[REQUIRED]** Recipes delegate to presets and scripts.

**[REQUIRED]** Do not duplicate dependency, build, or test logic in recipes.

**[REVIEW]** Remove or simplify recipes that are not used in real projects.

## 15.3 Shell scripts

**[REQUIRED]** Scripts should:

- use strict shell behavior where appropriate,
- resolve paths robustly,
- print the command intent,
- return nonzero on failure,
- delegate to canonical tools,
- avoid modifying the machine unexpectedly.

**[DEFAULT]** `bootstrap.sh` verifies tools and provides guidance rather than installing large system dependencies automatically.

---

# 16. Continuous integration

## 16.1 Baseline matrix

**[TODO]** Add:

- Ubuntu GCC build/test,
- Ubuntu Clang build/test,
- sanitizer lane,
- formatting/static-analysis lane.

**[REQUIRED]** CI invokes repository presets.

**[REQUIRED]** CI should remain understandable from the workflow files.

**[REQUIRED]** Avoid a large speculative matrix.

## 16.2 Additional platforms

**[CONDITIONAL]** Add Windows when:

- a project has Windows users,
- MSVC compatibility matters,
- or multiplatform distribution is planned.

**[CONDITIONAL]** Add macOS when:

- a project has macOS users,
- Apple platform development is planned,
- or portability validation is valuable enough to maintain.

**[REQUIRED]** Platform support claims follow passing CI and documented limitations.

## 16.3 CI quality policy

**[DEFAULT]** Treat warnings as errors for project-owned code.

**[DEFAULT]** Upload test logs or reports on failure.

**[DEFAULT]** Cache Conan downloads where safe.

**[REQUIRED]** Do not enforce benchmark timing on shared hosted runners.

**[CONDITIONAL]** Add coverage reporting when the project benefits from visible trends and the workflow remains reliable.

**[CONDITIONAL]** Add scheduled/nightly analysis only when expensive checks routinely find useful issues.

---

# 17. Packaging and distribution

## 17.1 Baseline

**[DOCUMENT-ONLY]** Keep packaging scaffolding and extension guidance.

**[DEFERRED]** Do not implement release packaging in the initial template.

## 17.2 Installable C++ library

**[CONDITIONAL]** Add proper install/export/package-config support when another project needs to consume the C++ library.

At that point, address:

- install interface include paths,
- exported targets,
- package config files,
- semantic versioning,
- ABI policy,
- symbol visibility,
- public dependency propagation.

## 17.3 Application packaging

**[CONDITIONAL]** Add CPack or platform packaging when users need distributable applications.

Do not add installers for proof-of-concept repositories without a distribution requirement.

## 17.4 Releases

**[CONDITIONAL]** Add tagged release automation when the project has external users, versioned artifacts, or a stable delivery process.

**[DEFERRED]** Automatic semantic-release tooling is not a baseline concern.

---

# 18. Containers and development environments

**[DEFERRED]** Docker is not the primary C++ build interface.

**[CONDITIONAL]** Add a development container when:

- onboarding across machines is difficult,
- system dependencies are complex,
- CI parity is valuable,
- reproducible research environments justify it.

**[CONDITIONAL]** Add Docker images for deployment only when the application is actually deployed as a container.

**[REQUIRED]** Container support must wrap, not replace, the ordinary documented CMake/Conan workflow unless the project explicitly chooses otherwise.

---

# 19. Security and repository hygiene

**[TODO]** Add `SECURITY.md` with an appropriate lightweight policy.

**[REQUIRED]** Never commit secrets, tokens, private datasets, or machine-local configuration.

**[REQUIRED]** Prevent accidental large-file commits through hooks and `.gitignore` policy.

**[CONDITIONAL]** Add dependency vulnerability scanning when the dependency surface or project exposure justifies it.

**[CONDITIONAL]** Add CodeQL or similar analysis when it provides value beyond compiler and static-analysis checks.

**[REQUIRED]** Pin or deliberately version CI actions according to the repository's security/maintenance policy.

---

# 20. Template evolution rules

## 20.1 Adding a capability

Before adding a baseline capability, record:

1. Which real project requires it?
2. Is it cross-project or project-specific?
3. What is its maintenance cost?
4. Does it slow the ordinary workflow?
5. Can it be an optional preset/module instead?
6. What documentation and CI does it require?
7. How will it be removed if unused?

## 20.2 Avoiding template accumulation

**[REQUIRED]** A tool is not justified merely because it is modern or popular.

**[REQUIRED]** Prefer one reliable tool per responsibility over overlapping tools.

Examples:

- one active dependency manager,
- one canonical build interface,
- one default formatter,
- one top-level test runner,
- one clearly documented coverage path.

## 20.3 Reviewing the template

**[DEFAULT]** Review the template after every two or three concrete projects.

Questions:

- Which files are always deleted?
- Which optional modules are never used?
- Which setup steps remain confusing?
- Which checks are habitually bypassed?
- Which scripts duplicate preset behavior?
- Which project-specific patterns have become genuinely reusable?
- Are Linux, compiler, Conan, and CI assumptions still current?

Remove dead scaffolding rather than preserving it indefinitely.

---

# 21. Initial implementation tracker

Update this section during the first Codex setup.

## Foundation

- [TODO] Root CMake project and C++20 policy
- [TODO] Core reusable library target
- [TODO] CLI target linked to the core library
- [TODO] Static/shared behavior through `BUILD_SHARED_LIBS`
- [TODO] Repository directory structure
- [TODO] Root README
- [TODO] Contributing guide
- [TODO] Git ignore and attributes

## Build and dependencies

- [TODO] Conan 2 recipe
- [TODO] GoogleTest dependency
- [TODO] Google Benchmark dependency
- [TODO] CMake dependency module
- [TODO] GCC development preset
- [TODO] Clang development preset
- [TODO] Debug and Release presets
- [TODO] Example user presets file
- [TODO] Bootstrap script

## Quality

- [TODO] `.clang-format`
- [TODO] format/apply command
- [TODO] format/check command
- [TODO] compiler-warning target
- [TODO] `.clang-tidy`
- [TODO] explicit clang-tidy workflow
- [TODO] CMake formatting configuration
- [TODO] Markdown and structured-file checks
- [TODO] ShellCheck
- [TODO] pre-commit configuration

## Tests and performance

- [TODO] GoogleTest integration through CTest
- [TODO] sample unit test
- [TODO] sample integration test
- [TODO] Google Benchmark target
- [TODO] sample benchmark
- [TODO] ASan preset
- [TODO] UBSan preset
- [TODO] TSan preset
- [TODO] one functioning coverage workflow
- [TODO] Linux `perf` wrapper

## Research and documentation

- [TODO] language-neutral research workspace
- [TODO] research workflow documentation
- [TODO] data policy
- [TODO] Quarto report convention
- [TODO] interoperability options document
- [TODO] architecture documentation index
- [TODO] ADR 0001: C++20
- [TODO] ADR 0002: Conan 2
- [TODO] ADR 0003: library-first architecture
- [TODO] Doxygen scaffolding

## Automation

- [TODO] `justfile`
- [TODO] GCC CI lane
- [TODO] Clang CI lane
- [TODO] sanitizer CI lane
- [TODO] code-quality CI lane
- [TODO] pull-request template

---

# 22. Project-specific activation checklist

When creating a project from the template, decide each item explicitly.

## Identity and scope

- [ ] Rename project placeholders and CMake targets.
- [ ] Replace template README content with the real problem statement.
- [ ] Choose the license.
- [ ] Delete unused optional directories.

## Research phase

- [ ] State the research question.
- [ ] Choose notebook/script tools only as needed.
- [ ] Define data provenance and storage policy.
- [ ] Define reproducibility expectations.
- [ ] Create visualizations and validate the conceptual pipeline.
- [ ] Record stable findings before beginning C++ design.

## C++ design phase

- [ ] Identify reusable library boundaries.
- [ ] Identify application entry points.
- [ ] Define public versus private APIs.
- [ ] Select project dependencies.
- [ ] Decide whether configuration files are needed.
- [ ] Define error-handling and logging policy.

## Verification phase

- [ ] Define unit-test invariants.
- [ ] Define integration scenarios.
- [ ] Define stochastic/numerical tolerance policy.
- [ ] Add compact regression fixtures for discovered failures.
- [ ] Select sanitizer lanes.

## Performance phase

- [ ] Establish correctness before optimization.
- [ ] Add benchmarks only for important operations.
- [ ] Profile before selecting an optimization.
- [ ] Add OpenMP, SIMD, CUDA, or specialized allocators only with evidence.
- [ ] Preserve benchmark environment metadata when results matter.

## Integration phase

- [ ] Keep research and C++ separate unless integration provides concrete value.
- [ ] Prefer file exchange first.
- [ ] Prefer subprocess automation second.
- [ ] Add bindings only after API and workflow justification.

## Distribution phase

- [ ] Determine whether the project is source-only, an application, or a reusable package.
- [ ] Add install/export rules only for reusable consumers.
- [ ] Add Windows/macOS CI before claiming support.
- [ ] Add packaging/release automation only when artifacts are distributed.

---

# 23. Decisions currently fixed

The following decisions are accepted for the initial template:

- **[REQUIRED]** C++20.
- **[REQUIRED]** CMake.
- **[REQUIRED]** CMake Presets.
- **[DEFAULT]** Ninja.
- **[REQUIRED]** Linux-first development.
- **[REQUIRED]** GCC and Clang support.
- **[REQUIRED]** Conan 2.
- **[REQUIRED]** GoogleTest with CTest.
- **[OPTIONAL]** Google Benchmark.
- **[REQUIRED]** clang-format with project-controlled style.
- **[REQUIRED]** curated clang-tidy.
- **[REQUIRED]** pre-commit.
- **[REQUIRED]** library-first C++ architecture.
- **[REQUIRED]** language-neutral research workspace.
- **[DOCUMENT-ONLY]** research/C++ interoperability.
- **[DEFAULT]** Quarto-compatible reporting.
- **[DEFAULT]** optional `justfile` convenience interface.
- **[REQUIRED]** no speculative subsystem bloat.

---

# 24. Open questions to revisit after practical use

These are not blockers for initial setup:

- **[REVIEW]** Should the template keep `cppcheck`, or is clang-tidy sufficient?
- **[REVIEW]** Should strict conversion warnings be default or CI-only?
- **[REVIEW]** Should coverage standardize on GCC/gcovr or Clang/llvm-cov?
- **[REVIEW]** Is `just` used enough to remain in every project?
- **[REVIEW]** Should Doxygen scaffolding remain when most proof-of-concepts do not publish API docs?
- **[REVIEW]** Should a later template version include an opt-in dev container?
- **[REVIEW]** After several projects, would vcpkg improve the workflow enough to replace Conan?
- **[REVIEW]** Which research-environment manager is most common in practice: uv, Poetry, or Conda/Mamba?

Resolve these based on observed friction, not preference alone.
