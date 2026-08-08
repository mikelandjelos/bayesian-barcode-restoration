# Adaptive local barcode decoder — research design hypothesis

**Status:** Proposed and not yet validated

**Recorded:** 2026-08-08

**Decision boundary:** Research design only; not a production architecture

## Intended outcome

Decode damaged or geometrically distorted 1D barcodes without requiring one
straight scanline to span the complete symbol. Traverse the already located
barcode region through short, overlapping sample segments whose direction may
change gradually. Fuse sampling, correction, soft digitization, and partial
decoding into one streaming inference process. Apply checksum validation only
after a complete candidate decode exists.

This design is aimed at low-memory, low-latency devices. It must therefore be
implementable without constructing a full image-sized graph, materializing a
global sheaf Laplacian, or performing a generic matrix inverse.

## Scope and pipeline position

Barcode localization and an approximate region of interest remain separate.
Within that region, the proposed decoder replaces the conventional sequence of
full-width scanline extraction, independent correction, hard thresholding, and
decoding:

```text
located barcode region
          |
          v
local direction candidates + short grayscale samples
          |
          v
overlap alignment and confidence-weighted sheaf fusion
          |
          v
soft module probabilities + incremental decoder state
          |
          v
beam/Viterbi expansion to the next local segment
          |
          v
complete candidates -> checksum validation -> accept/reject
```

The method is intended for 1D barcodes. A sampling segment advances across the
modules, approximately perpendicular to the local bar direction. "Changing
direction" means following gradual skew, perspective, surface curvature, or
deformation; it does not permit unconstrained motion along or backward through
the bars.

## Hybrid inference model

The complete problem is not one fixed linear cellular-sheaf solve. Geometry,
module alignment, graph-branch selection, and symbol identity are discrete or
nonlinear choices. The proposed system therefore has two coupled layers.

### Outer discrete traversal

A candidate path state contains at least:

- image position and direction of travel;
- local module pitch/scale and subpixel phase;
- accumulated path score and measurement confidence;
- recent soft module estimates needed by the fixed-lag window; and
- the active symbology decoder state.

At every expansion, the search considers a small, bounded set of successor
directions, scale adjustments, and module alignments. An edge is allowed only
when it preserves:

- forward, monotonic progress across the symbol;
- a configured maximum change in direction and scale;
- spatial continuity between segment endpoints;
- agreement between overlapping module coordinates; and
- at least one valid partial decoder transition.

Use a bounded beam search or Viterbi-style dynamic program. Do not greedily
commit to one local direction: blur, scratches, text, or glare can make the
strongest local gradient misleading.

### Inner linear cellular sheaf

For a fixed local path/alignment hypothesis, each node stalk holds a short
vector of grayscale-derived module values. Edge restriction maps select the
physical modules shared by two neighboring segments. They are index-selection
operators, not stored dense matrices.

The local estimate balances measurement fidelity and overlap consistency:

\[
\hat{x}=\arg\min_x
\sum_i \lVert W_i^{1/2}(H_i x_i-y_i)\rVert^2
+\lambda\lVert\delta x\rVert^2.
\]

Here, \(y_i\) is a sampled local observation, \(H_i\) is an optional local blur
operator, \(W_i\) expresses confidence, and \(\delta\) measures disagreement on
overlaps. The solver produces continuous module estimates or log-likelihoods;
it does not make premature hard binary decisions.

Correction begins once enough overlapping evidence exists. A fixed-lag window
updates recent modules as new segments arrive and commits older modules only
when their estimates are sufficiently stable or required by the bounded memory
policy.

## Fused sampling-to-decoding behavior

One streaming iteration performs the following logical operations:

1. Propose a few local travel directions from the ROI geometry and local image
   gradients.
2. Sample a short grayscale profile at subpixel locations.
3. Estimate measurement confidence and local alignment candidates.
4. Fuse the new observation with recent overlaps using the linear sheaf model.
5. Convert corrected values into soft black/white module probabilities.
6. Advance the partial symbology decoder and score the resulting path states.
7. Prune to a bounded beam and repeat.

These operations are coupled, but they remain separately testable. In
particular, the decoder may reject a geometrically plausible path whose soft
modules cannot form valid symbols, while new image evidence may revise an
uncertain recent module before it is committed.

Checksum is excluded from local correction and path manipulation. It validates
complete candidates at the end and may choose the first valid candidate among
the final ranked alternatives.

## Symbology extension boundary

The common engine owns:

- direction and local-scale proposals;
- grayscale sampling and confidence estimation;
- overlap registration;
- linear-sheaf fusion;
- soft module likelihoods; and
- bounded search orchestration.

Each symbology plugin owns:

- start, stop, guard, and symbol patterns;
- valid symbol widths and state transitions;
- code-set or parity state where applicable;
- completion criteria; and
- final checksum calculation.

The outer search state exposes soft module likelihoods to the plugin and
receives valid next decoder states with additive costs. Code 128 is the first
planned real-symbology adapter, using Zint-generated fixtures. EAN, Code 39, or
ITF should be addable without changing the geometric/sheaf core.

## Embedded implementation constraints

Let \(M\) be the number of traversal steps, \(B\) the retained beam width,
\(A\) the bounded number of successors per state, and \(w\) the local/fixed-lag
window size. The target implementation shape is approximately:

\[
\text{time}=O(MBAw), \qquad \text{working state}=O(Bw),
\]

plus small decoder-specific state and sampled image access. These are design
targets, not measured results.

The embedded version should:

- represent the regular neighborhood structure and restriction maps
  implicitly;
- use fixed-size, reusable buffers;
- keep beam width, successor count, window width, and iterations bounded;
- use `float32` initially, then evaluate fixed-point arithmetic separately;
- avoid a full global Laplacian, generic sparse factorization, and dense
  restriction matrices; and
- operate only on the localized ROI, preferably as a fallback after a cheaper
  conventional decode attempt fails.

## Staged validation

The integrated experiment begins only after two independent foundations pass.

1. **Linear foundation:** overlapping vector stalks on a straight sequence,
   followed by fixed multi-scanline fusion with known corruption.
2. **Discrete foundation:** branch selection and partial soft decoding on a
   small graph without image-restoration uncertainty.
3. **Adaptive geometry:** a synthetic curved barcode with known center path,
   initially without blur or noise.
4. **Combined degradation:** add Gaussian blur, sensor noise, glare/scratches,
   and slowly varying scale one factor at a time, then in combination.
5. **Real symbology:** use Zint to generate Code 128 fixtures and connect the
   first decoder plugin.
6. **Bayesian comparison:** test whether an HMM replaces, follows, or augments
   the soft decoding component.

Compare at least:

- a straight full-width scanline baseline;
- adaptive traversal without sheaf fusion;
- fixed multi-scanline sheaf fusion; and
- adaptive traversal with sheaf fusion.

Record path position/direction error, module bit-error rate, successful decode
rate, checksum success, runtime, peak working memory, beam expansions, and
iteration count.

## Risks and open questions

- A standard geometric rectification plus conventional decoder may be faster
  and equally robust; the sheaf formulation must earn its complexity through
  comparative evidence.
- Local gradient direction may become unreliable under severe blur or damage,
  requiring multiple hypotheses and a trustworthy confidence estimator.
- Module phase and pitch errors can make otherwise correct overlaps appear
  inconsistent.
- The linear overlap formulation may reduce algebraically to a simpler
  structured least-squares or robust averaging method; implementation should
  prefer the simplest equivalent solver.
- Beam width and fixed-lag size determine the robustness/latency/memory
  tradeoff and must be measured on target-like hardware.
- Symbology rules should help reject paths without causing the common geometry
  layer to become tied to Code 128.

No production API, solver, or data structure is selected by this document.
