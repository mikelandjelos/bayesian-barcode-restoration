# Architecture

The template starts with one reusable library target, `project_core`, exposed to
consumers as `project::core`. Public headers reside in `include/project_name/`;
private implementation resides in `src/`. Applications, tests, benchmarks, and
examples link to the library instead of compiling its source files directly.

Split the core only when components have different dependencies, stability
boundaries, reuse needs, or meaningful compile-time/platform separation.
