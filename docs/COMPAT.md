# COMPAT — the measured tuple

Receipts in `results/` are valid for EXACTLY this tuple. Any change → re-measure.

- oMLX **0.7.3** (stable line; 0.8.0rc exists, not pinned here)
- HF `Jundot/Qwen3.8-Flash-Next-oQ4e-mtp` @ `2322c888c2c314d4eceddf0159dec5d821aa1e41` (21 shards)
- Per-model: presence 1.5, force\_sampling, MTP on, PLE SSD offload on,
  turboquant\_kv **off**, oq\_a8 **off** (quality contract, not speed contract)
- scheduler: mc=2, chunked\_prefill, prefill\_priority=context; hot cache 0; SSD cache on
- 128 GB Apple Silicon (M5 Max reference), single GPU-heavy app
