# ADR 0002: Use Conan 2

## Decision

Conan 2 is the active dependency manager.

## Rationale

It supports compiler/build profiles and reproducible package graphs while CMake
targets remain independent of Conan by using `find_package` and imported targets.
