# Barcode restoration research log

This log records the decisions, evidence, limitations, and next steps for the
research notebooks. A gate is advanced only after explicit review.

## Roadmap

| Notebook | Approach | Status |
| --- | --- | --- |
| `01_linear_cellular_sheaf.ipynb` | Linear cellular sheaf | Gate 2 implemented |
| `02_discrete_sheaf_constraints.ipynb` | Discrete compatibility/message passing | Planned |
| `03_bayesian_hmm_restoration.ipynb` | Bayesian/HMM restoration | Planned |
| Adaptive local decoder | Direction-changing joint inference | Design hypothesis documented |
| Final comparison | Individual and hybrid methods | Planned |

## 2026-08-08 — Linear cellular sheaf, Gate 1

### Objective

Understand the smallest executable cellular sheaf before introducing barcode
windows. The example must make stalks, restriction maps, the coboundary, the
sheaf Laplacian, global sections, diffusion, and confidence-weighted recovery
concrete.

### Decisions

- Use a three-vertex path with scalar vertex and edge stalks.
- Use identity restriction maps, so compatibility means neighboring scalars
  agree.
- Represent the coboundary as
  `delta = [[-1, 1, 0], [0, -1, 1]]` and compute
  `L = delta.T @ delta`.
- Compare pure diffusion with a data-fidelity problem that downweights one
  deliberately corrupted observation.
- Use only NumPy and Matplotlib in this gate; no sheaf-specific dependency is
  needed.
- Keep this example symbology-neutral. Symbology generation and validation are
  later adapters rather than part of the linear sheaf core.

### Verification criteria

- The notebook executes from a clean kernel.
- The Laplacian is symmetric positive semidefinite.
- Its kernel is one-dimensional and contains the constant global section.
- Pure diffusion reduces disagreement.
- Confidence-weighted regularization reduces disagreement while retaining a
  measurement-fidelity term.

### Important limitation

This identity-restriction scalar example is a consensus model, not yet a
barcode restoration model. Applying it across barcode modules would smooth
away genuine black/white transitions. The next gate, if approved, will replace
scalar stalks with overlapping module-vector stalks and restriction maps that
compare only shared module coordinates.

### Reference

- Jakob Hansen and Robert Ghrist, [Toward a Spectral Theory of Cellular
  Sheaves](https://arxiv.org/abs/1808.01513).

### Gate result

Completed successfully. The notebook was executed in place from a clean kernel
with:

```text
JUPYTER_CONFIG_DIR=/tmp/bbr-jupyter-config \
JUPYTER_DATA_DIR=/tmp/bbr-jupyter-data \
JUPYTER_RUNTIME_DIR=/tmp/bbr-jupyter-runtime \
IPYTHONDIR=/tmp/bbr-ipython \
MPLCONFIGDIR=/tmp/bbr-matplotlib \
jupyter nbconvert --to notebook --execute --inplace \
  research/notebooks/01_linear_cellular_sheaf.ipynb \
  --ExecutePreprocessor.timeout=120
```

Runtime versions recorded by the kernel:

- Python 3.12.3
- NumPy 1.26.4
- Matplotlib 3.6.3
- random seed 7

All assertions passed. With latent truth `[1, 1, 1]` and observations
`[1.05, -0.80, 0.90]`, pure diffusion converged to the observation mean
`[0.3833, 0.3833, 0.3833]`. Giving the corrupted center observation confidence
`0.03` produced the regularized estimate `[0.9867, 0.9233, 0.9117]` and reduced
the consistency energy from `6.3125` to `0.0041`.

### Review checkpoint

Stop here. Do not introduce overlapping barcode windows until this gate has
been reviewed and the next gate is explicitly approved.

## 2026-08-08 — Adaptive local decoder design hypothesis

### Motivation

A full-width straight scanline is unnecessarily rigid for skewed, locally
curved, or partially damaged barcodes. The proposed decoder instead advances
through the located barcode region using short, overlapping sample segments
whose direction may change gradually while remaining approximately
perpendicular to the local bars.

### Decision

Record this as a research hypothesis, not a production architecture. The
design combines:

- an outer discrete search over position, direction, local scale, module phase,
  and partial decoder state;
- an inner linear cellular sheaf that fuses overlapping grayscale evidence and
  produces corrected soft module estimates;
- incremental, symbology-specific decoding of those estimates; and
- checksum validation only after a complete candidate has been assembled.

The complete proposal, embedded cost model, staged evaluation, and separation
between common geometry and symbology plugins are documented in
[`adaptive-local-decoder-design.md`](adaptive-local-decoder-design.md).

### Timing

Do not attempt the combined system yet. First validate overlapping vector
stalks and fixed multi-scanline fusion in the linear notebook. Then validate
branch selection and incremental soft decoding independently in the discrete
notebook. The adaptive integration experiment follows those two foundations
and precedes any production architecture decision.

## 2026-08-08 — Linear cellular sheaf, Gate 2

### Objective

Replace scalar consensus with overlapping vector stalks on a straight,
module-aligned synthetic binary sequence. Verify that restriction maps compare
only duplicate descriptions of the same physical modules and therefore do not
erase genuine black/white transitions.

### Construction

- Use the eight-module truth `[1, 1, 0, 1, 0, 0, 1, 0]`.
- Create three four-module windows with stride two and a two-module overlap.
- Give each node stalk dimension four and each edge stalk dimension two.
- Implement restriction maps as coordinate selectors: the last two values of
  the earlier window and the first two values of the later window.
- Assemble a `4 x 12` coboundary and its `12 x 12` sheaf Laplacian.
- Introduce one explicit contradiction: the second window reports global
  module 2 as `1.0` instead of `0.0`, with confidence `0.03`.
- Apply confidence-weighted overlap regularization with `lambda = 3.0`, then
  glue duplicate local copies back into one global sequence.

### Result

The notebook executed successfully from a clean kernel, with every assertion
passing. The coboundary has rank four, leaving an eight-dimensional kernel—the
same dimension as the global module sequence. The stacked truth, despite its
many black/white transitions, has exactly zero overlap disagreement.

The corrupted local copy moved from `1.0` to `0.0385`, while its trusted
overlapping copy moved only from `0.0` to `0.0288`. Their disagreement fell
from `1.0` to `0.0096`. Gluing the restored stalks produced
`[1.0, 1.0, 0.0337, 1.0, 0.0, 0.0, 1.0, 0.0]`, which thresholded to the exact
original sequence.

### Interpretation

The sheaf now enforces "same physical module, same value" rather than
"neighboring modules, same value." It can preserve arbitrary barcode
transitions while identifying contradictory overlap measurements. The
restriction maps, not generic smoothing, encode this behavior.

### Review checkpoint

Stop here. The example still assumes perfect module alignment and deliberately
constructed local values; it is not yet a camera observation model. The next
gate, only after explicit approval, is fixed multi-scanline fusion with a
controlled damaged region. Gaussian blur, sensor noise, unknown alignment,
adaptive direction, and symbology decoding remain out of scope.
