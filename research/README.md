# Research workspace

Use this area to understand and validate a problem before C++ architecture is
fixed. Keep notebooks in `notebooks/`, reusable exploratory code in `scripts/`,
and Quarto-compatible narratives in `reports/`.

`data/raw/` and `data/processed/` are intentionally ignored apart from their
placeholder files. Record provenance and regeneration steps in reports or
project-specific documentation; do not commit large/generated data by default.

## Research roadmap

The restoration approaches are explored incrementally, with each notebook
advancing only after the previous experiment has been reviewed:

1. [`notebooks/01_linear_cellular_sheaf.ipynb`](notebooks/01_linear_cellular_sheaf.ipynb)
   — linear cellular sheaves, local-to-global consistency, and overlapping
   vector stalks with fixed multi-scanline fusion and a Gaussian observation
   model, including a seeded robustness/resource sweep and bounded matrix-free
   solver.
2. `notebooks/02_discrete_sheaf_constraints.ipynb` — planned discrete
   compatibility and message passing experiments.
3. `notebooks/03_bayesian_hmm_restoration.ipynb` — planned Bayesian/HMM
   restoration experiments.

Decisions, results, limitations, and gate status are recorded in
[`reports/research-log.md`](reports/research-log.md).

The proposed end-to-end direction-changing decoder is documented separately in
[`reports/adaptive-local-decoder-design.md`](reports/adaptive-local-decoder-design.md).
It is a research hypothesis to be tested after its linear-fusion and discrete-
traversal foundations work independently.
