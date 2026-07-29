# Contributing

## Everyday workflow

CMake Presets are canonical. The `justfile` is only a convenient wrapper.

```bash
./scripts/bootstrap.sh
./scripts/configure.sh dev-gcc
cmake --build --preset dev-gcc
ctest --preset dev-gcc
```

Install local checks with `pre-commit install`. Before opening a change, run
`just check` and `just test` (or the equivalent scripts).

## Code and build rules

- Format C++ with `just format`; verify it with `just check`.
- Use target-based CMake. Do not add global include paths, compiler flags, or
  source globbing.
- Put public headers in `include/project_name/` and implementation in `src/`.
- Add reusable behavior to a library target; applications only orchestrate it.
- Add dependencies in `conanfile.py`, consume them with `find_package`, and
  link their imported targets.
- Add a preset by inheriting existing presets rather than copying configuration.

## Tests and performance

Add focused unit tests under `tests/unit/` and integration scenarios under
`tests/integration/`. Keep test fixtures compact and committed. Benchmarks are
opt-in and are for local measurement, not shared-runner regression gates.

Use `just asan`, `just ubsan`, or `just tsan` when the affected behavior merits
sanitizer coverage. Profile before optimizing.

## Research work

Keep exploratory notebooks, scripts, reports, and data conventions in
`research/`. Do not commit large raw/generated datasets or run artifacts.
Record decisions that constrain future architecture as ADRs in `docs/decisions/`.
