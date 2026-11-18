# Bootstrap — bare 128 GB Apple Silicon Mac → verified serving endpoint

Run order. Every step is idempotent; re-running never duplicates work.

1. `bash setup.sh` — engine check/install (SHA256-gated DMG), checkpoint
   download at the pinned revision, quality contract, settings, optional
   launchd agent, first start. Exits non-zero on any failed gate; fix and re-run.
2. `bash scripts/verify.sh` — 8 checks; **exit 0 is the definition of installed**.
3. `python3 scripts/health_receipt.py` — writes `results/smoke_<ts>.json`
   (≥100-token completion with usage block). That receipt is the proof of life.
4. Point your client at `http://<this-host>:8010/v1`, model
   `qwen38-flash-next-oq4e-mtp`, `Authorization: Bearer $(cat ~/.omlx/api-key)`.

## What setup.sh will NOT do

- It will not rotate an existing API key (add-only).
- It will not touch an existing `model_settings.json` entry beyond the recipe's
  own model id.
- It will not delete `~/.omlx/ssd-cache` or any checkpoint tree.
- It will not run on Intel or <96 GB — by design, fail-closed.

## First completion is slow

Cold start loads ~79 GiB of weights; first token on a fresh boot can take
minutes if the OS cache is cold. That is normal. The TTFT in your first
receipt is a cold number; do not cite it as steady-state.

## Upgrading later

Change the pin in `MODELS.md` deliberately (new DMG sha + new `files/SHA256SUMS`
at the new revision + re-run). Never let a package manager silently move the
engine under a pinned receipt.
