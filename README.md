# Qwen3.8 Flash-Next on oMLX 0.7.3 — one-Mac serving recipe (agent-installable)

**Status: measured on ONE machine (128 GB M5 Max MacBook Pro, macOS 26.6.2, Nov 2026). Zero independent reproductions. Re-run the verify script on your box before trusting any number in `results/`.**

Give this repo URL to your coding agent and it should be able to take a bare
128 GB Apple Silicon Mac (macOS 26) from nothing to a verified, serving,
quality-locked Qwen3.8 Flash-Next endpoint. That is the entire point of this
repo: `AGENT.md` is written for the agent, not for you.

## What you get

- oMLX **0.7.3** (pinned DMG + SHA256) installed to `~/Applications`
- `Jundot/Qwen3.8-Flash-Next-oQ4e-mtp` @ revision `2322c888c2c314d4eceddf0159dec5d821aa1e41` (~100 GB, 21 shards) under `~/models/`
- Server on `http://127.0.0.1:8010/v1` (local-only by default; `BIND_LAN=1` to open it to your network), OpenAI-compatible, API key auth
- Quality contract (sampling + MTP + cache pins) written to per-model settings
- `scripts/verify.sh`: fail-closed checks, exit 0 only on full pass
- A smoke receipt proving the endpoint answered after install

## Quick start (human)

```bash
git clone https://github.com/hudsonwa/Qwen3.8-Flash-Next-OMLX-073-Recipe.git
cd Qwen3.8-Flash-Next-OMLX-073-Recipe
bash setup.sh          # installs engine + weights + config, starts the server; safe to re-run
                       # options: BIND_LAN=1 (reachable from other machines), INSTALL_PLIST=1 (login item)
bash scripts/verify.sh # must exit 0
```

## Quick start (agent)

Read `AGENT.md` top to bottom, then do what it says. It encodes every trap
hit while building the parent stack (TCC app installs, footprint vs RSS,
per-model settings vs global, port identity, key handling).

## Honesty contract

- Receipts written by `scripts/health_receipt.py` carry the machine stamp and the command that produced it.
  The one receipt from the first release predates that and is liveness-only (see `results/README.md`).
- `results/*-PENDING.md` means: claimed but not yet receipted. Do not cite.
- Nothing here is benchmarked-quality: quality claims need the A/B protocol in `docs/METHODOLOGY.md`.

## CREDITS — read this first

This recipe exists on the shoulders of two specific projects. Neither
endorsed it; all engineering credit for the underlying systems is theirs.

1. **[TensorFold](https://github.com/ashhart/TensorFold) by ashhart — the structural pattern of this repo.**
   The ideas of agent-first repo design used here are learned from the
   TensorFold (Apache-2.0) approach; nothing was copied, but the debt is real
   and acknowledged up-front, in the README, where a first-time reader lands.
2. **[oMLX](https://github.com/jundot/omlx) by jundot — the serving engine this recipe configures.**
   The app, the `omlx` CLI, the oQ4e quant, the MTP implementation and the
   `Jundot/Qwen3.8-Flash-Next-oQ4e-mtp` checkpoint packaging are all oMLX work.
3. **Qwen team — the Flash-Next checkpoint itself** (licence `qwen-community-1.0`, see `docs/THIRD_PARTY.md`) ([base weights](https://huggingface.co/Jundot/Qwen3.8-Flash-Next-oQ4e-mtp), Qwen4-arch preview, 125B MoE / ~6B act).

License mapping and full third-party notices: `docs/THIRD_PARTY.md`.

## Layout

| Path | Contents |
| --- | --- |
| `AGENT.md` | The install contract for coding agents |
| `BOOTSTRAP.md` | Human-readable step order |
| `MODELS.md` | Pinned DMG SHA + HF revision + shard count |
| `setup.sh` | One-shot install; idempotent; fail-closed |
| `scripts/verify.sh` | Post-install gate, exit 0 = verified |
| `scripts/health_receipt.py` | Writes the smoke receipt to `results/` |
| `scripts/uninstall_plist.sh` | Removes the optional login item |
| `results/` | Dated receipts from the reference machine |
| `docs/` | COMPAT / TRAPS / METHODOLOGY / PRIVACY / THIRD\_PARTY |

## Machine contract (reference box)

128 GB unified memory, Apple M5 Max, macOS 26.6.2, ~120 GB free on the model
volume at install time, no second GPU-heavy app running. Numbers in
`results/` are NOT portable to other memory classes without re-measuring.
