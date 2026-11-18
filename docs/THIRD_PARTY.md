# THIRD PARTY — credits and license map (read before redistributing)

## What this repo IS

Configuration, scripts and documentation around other people's engines and
weights. MIT for this repo's own files (see `LICENSE`).

## What this repo is NOT

It ships no engine code and no model weights.

## The credits, up front and loud

1. **TensorFold — https://github.com/ashhart/TensorFold — Apache-2.0 — © ashhart and contributors.**
   The agent-first repo structure (tell-the-agent-the-traps-in-AGENT.md,
   fail-closed verify gates, receipts-or-it-didn't-happen) is this project's
   pattern, learned from the TensorFold repo and the author's public writing.
   No code was copied; the design debt is total and acknowledged.
2. **oMLX — https://github.com/jundot/omlx — © jundot and contributors.**
   The engine this whole recipe exists to run. The app, `omlx` CLI, oQ4e
   quantization, MTP support and every performance number's substrate.
   Check the oMLX repo for its license before redistribution.
3. **Qwen — the Flash-Next base model** (Qwen4-architecture preview, 125B MoE
   / ~6B active). All model rights belong to their holders; the
   `Jundot/Qwen3.8-Flash-Next-oQ4e-mtp` packaging is a derivative quant by
   the oMLX author, on Hugging Face under its own terms.
4. **Hermes Agent — https://github.com/NousResearch/hermes-agent** — the agent
   runtime used to author and verify this recipe. Any Hermes-specific config
   in docs is illustrative; Hermes has its own license and repo.

If you fork or redistribute: keep this file intact. The people who built the
engine and the weights did the heavy lifting; this repo is the last mile.
