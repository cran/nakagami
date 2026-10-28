# nakagami 1.2.0

* Fix `pnaka()` for negative quantiles in both tails and on the log scale.
* Fix `dnaka()` below zero and at zero and infinity. At zero the density is
  infinite for `shape < 0.5`, `sqrt(2 / (pi * scale))` for `shape = 0.5`, and
  zero for `shape > 0.5`.
* Recycle quantiles, probabilities, shape and scale independently. Previously,
  combining shape and scale before recycling could silently give wrong results.
* Use a unit-rate Gamma transformation and log-scale calculations to avoid
  intermediate overflow and underflow, including in very small probabilities
  and quantiles.
* Allow zero random draws and empty input vectors. Reject missing or infinite
  parameters and missing logical flags with clear errors. Shape and scale
  remain strictly positive; invalid parameter vectors still cause errors.
* Remove the `assertthat` runtime dependency and warning-suppression machinery.
* Simplify the quantile implementation, build exclusions and GitHub Actions
  workflow. Remove obsolete VGAM benchmarks and unused `covr` suggestion.
* Clarify the scale parameter and log-density documentation.
* Replace the package logo with a black-and-white hex sticker.
