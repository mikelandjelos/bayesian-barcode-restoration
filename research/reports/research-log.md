# Barcode restoration research log

This log records the decisions, evidence, limitations, and next steps for the
research notebooks. A gate is advanced only after explicit review.

## Roadmap

| Notebook | Approach | Status |
| --- | --- | --- |
| `01_linear_cellular_sheaf.ipynb` | Linear cellular sheaf | Gate 4 implemented |
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

## 2026-08-08 — Linear cellular sheaf, Gate 3

### Objective

Demonstrate fixed multi-scanline fusion on a straight, perfectly aligned
barcode. Use redundant graph paths and known confidence to correct a controlled
damaged region while retaining the overlapping-window semantics from Gate 2.

### Construction

- Replicate the eight-module truth across three scanlines.
- Divide each scanline into three four-module windows, producing a `3 x 3`
  node grid with four values per node.
- Use two-dimensional horizontal edge stalks to compare window overlaps.
- Use four-dimensional vertical edge stalks with identity restrictions to
  compare corresponding windows on adjacent scanlines.
- Flip modules 2–4 in the middle scanline and assign those measurements
  confidence `0.02`; keep all other confidence values at `1.0`.
- Solve the confidence-weighted linear problem with `lambda = 2.0`, glue each
  scanline's overlapping windows, and average the nearly consistent restored
  scanlines into one global estimate.
- Retain plain and confidence-weighted per-module means as explicit baselines.

### Result

The notebook executed successfully from a clean kernel, with every assertion
passing. Nine nodes produce 36 local variables. Six horizontal edges contribute
12 scalar comparisons, and six vertical edges contribute 24, giving a
`36 x 36` coboundary. Its rank is 28 because grid cycles make some comparisons
redundant. The kernel remains eight-dimensional and contains the correctly
replicated barcode with zero disagreement.

The damaged input has consistency energy `12.0`; the restored local states have
energy `0.000291`. The fused global estimate is
`[1.0, 1.0, 0.0115, 0.9885, 0.0115, 0.0, 1.0, 0.0]` and thresholds to the exact
truth. The recovered scanlines agree closely even in the damaged region.

### Interpretation and baseline

The grid demonstrates how clean scanlines above and below constrain a damaged
local region through vertical edges while horizontal overlaps maintain local
sequence consistency. This is redundant constraint propagation rather than a
literal path-routing algorithm.

Because alignment and confidence are already known, a simple confidence-
weighted per-module mean produces nearly the same values in this experiment.
The sheaf has not yet demonstrated a practical advantage over that baseline.
It must earn its added structure in later experiments involving observation
blur, local coverage, alignment, geometry, or decoder constraints.

### Review checkpoint

Stop here. The next gate, only after explicit approval, adds controlled Gaussian
blur and sensor noise while keeping geometry and module alignment fixed. It
must compare the sheaf result against straightforward fusion/restoration
baselines. Unknown direction, adaptive traversal, and symbology decoding remain
out of scope.

## 2026-08-08 — Linear cellular sheaf, Gate 4

### Objective

Add an explicit Gaussian likelihood/observation operator and seeded sensor
noise to the fixed aligned multi-scanline experiment. Separate the value of
confidence weighting, deconvolution, and sheaf consistency through an
ablation against progressively stronger baselines.

### Construction

- Represent local optical mixing with a row-normalized `4 x 4` Gaussian matrix
  using `sigma = 1.0` module.
- Build the complete observation operator as nine independent copies of that
  matrix, one for each window stalk.
- Generate measurements from the known latent stalks with Gaussian sensor
  noise of standard deviation `0.10` and random seed `11`.
- Retain the controlled middle-scanline damage from Gate 3, replacing its
  affected observations with noisy gray saturation and oracle confidence
  `0.02`.
- Use Tikhonov strength `0.02` for both deconvolution methods and sheaf strength
  `2.0` for the joint method.
- Compare raw averaging, confidence-weighted averaging, independent local
  deconvolution, and joint sheaf deconvolution.

### Result

The complete notebook executed successfully from a clean kernel, with every
assertion passing. Results for the fixed seeded example were:

| Estimator | RMSE | Bit-error rate | Thresholded result correct |
| --- | ---: | ---: | --- |
| Raw mean | 0.3514 | 0.1250 | No |
| Confidence mean | 0.3387 | 0.1250 | No |
| Independent deconvolution | 0.2419 | 0.1250 | No |
| Joint sheaf deconvolution | 0.1534 | 0.0000 | Yes |

Independent deconvolution has latent consistency energy `3.518205`; adding the
sheaf penalty reduces it to `0.008264`. The final continuous estimate is
`[0.8445, 1.0508, 0.1410, 0.7143, 0.0763, 0.0227, 0.8078, 0.1297]`, which
thresholds to the exact eight-module truth.

### Interpretation

Confidence weighting cannot undo optical mixing by itself. Independent local
deconvolution models the blur but amplifies ambiguity and permits duplicate
latent module estimates to disagree. In this example, the sheaf penalty makes
the local inverse problems support one consistent global estimate and corrects
the remaining bit error.

This is a positive single-example result, not evidence of general superiority
or embedded performance. The experiment uses one hand-selected sequence, one
blur setting, one noise realization, oracle alignment, oracle confidence, and
a known blur operator. The module-space Gaussian matrix is not yet a complete
pixel-level camera model. The unconstrained linear estimate can leave `[0, 1]`
slightly, as demonstrated by the value `1.0508`; future probability outputs may
need box constraints or calibration.

### Review checkpoint

Stop here. The next gate, only after explicit approval, is a small seeded sweep
over blur, noise, and damage levels. It should report decode success, RMSE,
runtime, and approximate working memory for all four estimators. Unknown
alignment, adaptive direction, real symbology, and checksum validation remain
out of scope.
