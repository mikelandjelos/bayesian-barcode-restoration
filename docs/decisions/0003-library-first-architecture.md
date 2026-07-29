# ADR 0003: Use a library-first architecture

## Decision

Core behavior is implemented in reusable library targets; executables are thin
consumers of those targets.

## Rationale

This keeps algorithms testable, reusable, and independent of presentation or
process orchestration.
