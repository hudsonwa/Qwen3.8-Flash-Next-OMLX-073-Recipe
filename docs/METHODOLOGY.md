# METHODOLOGY — how claims in results/ may be earned

- **Liveness**: any HTTP 200 with ≥1 completion token.
- **Throughput claim**: usage block of a ≥100-completion-token generation,
  single stream, warm or cold labeled, prefix-cache state labeled
  (fresh random system suffix to force miss — identical repeats collapse to
  cache hits and lie by ~10x).
- **Concurrency claim**: N ≥2 streams fired within 2 s of each other, equal
  prompts, per-stream walls recorded, spread reported. 'No crash' is not
  concurrency.
- **Quality claim**: A/B on the same engine, same seed policy, blind-rated;
  single-run vibes are not quality evidence. The quality CONTRACT (temperatures,
  penalties, MTP) is configuration, not a quality result.
- Every JSON receipt carries: UTC-ish local timestamp, engine version, model
  revision, machine memory class, and the command that made it.
