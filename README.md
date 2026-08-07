# Bayesian Barcode Restoration

A Bayesian inference system designed to restore degraded, blurry, or low-contrast
1D barcode signals back into clear binary patterns.

## Overview

- Formulates barcode restoration as a hidden Markov model and binary state
  estimation problem.
- Models physical lens degradation (Gaussian blur) and camera sensor noise as the
  likelihood function.
- Uses a neighbor-dependent binary prior to enforce structural barcode constraints.
- Applies Bayesian optimization/inference to reconstruct the original sequences.

## Planned tooling

- **C++** — Eigen, GTest
- **Python** — PyMC, OpenCV, NumPy, SciPy, Quarto

## Status

🚧 Work in progress — repository scaffolding. Code and documentation to follow.
