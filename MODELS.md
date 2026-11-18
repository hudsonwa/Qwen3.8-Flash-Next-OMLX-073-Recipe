# MODELS.md — pinned artifacts (do not search, do not 'just use latest')

Every receipt in `results/` was measured against exactly these bits on the
reference machine (128 GB M5 Max, macOS 26.6.2, Nov 2026).

## 1. Engine — oMLX 0.7.3 (stable, 2026-10-31)

Release: https://github.com/jundot/omlx/releases/tag/v0.7.3

| macOS | File | Size (bytes) | SHA256 |
|---|---|---|---|
| 26 / 27 (this recipe) | `oMLX-0.7.3-macos26-27.dmg` | 881239063 | `2acfde41aeac0b022dbca803ca109437f3ccaf0c33f3415881526b985bee86f2` |
| 15 Sequoia | `oMLX-0.7.3-macos15-sequoia.dmg` | 838158761 | `cd5e3b454798a002f32ef2f3bf06ae033ea2f4e5b02aa039a2c68445498605f1` |

Install to `~/Applications/oMLX.app`. Confirm:
`~/.omlx/bin/omlx --version` prints `0.7.3`.

Why 0.7.3 and not newer: 0.8.0 is release-candidate only as of this pin
(2026-11); the stable line's in-place KV improvements (batch KV in-place
update: −35% peak memory, +33% decode on 8 streams for exactly this model
class, per upstream notes) are the reason this pin exists. Re-pin deliberately,
never silently.

## 2. Model checkpoint

| Field | Value |
|---|---|
| Hugging Face id | `Jundot/Qwen3.8-Flash-Next-oQ4e-mtp` |
| Revision | `2322c888c2c314d4eceddf0159dec5d821aa1e41` |
| Shards | 21 (`model-00001-of-00021.safetensors` … `-00021-`) + index |
| Weights on disk | ~100 GiB |
| Resident (loaded, idle) | ~79.5 GiB phys\_footprint on 128 GB |
| Serve dir | `~/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp` (real dir, not symlink — 0.7.3 scans subdirs) |
| Served model id | `qwen38-flash-next-oq4e-mtp` (directory name) |

```bash
hf download Jundot/Qwen3.8-Flash-Next-oQ4e-mtp \
  --revision 2322c888c2c314d4eceddf0159dec5d821aa1e41 \
  --local-dir ~/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp
echo 2322c888c2c314d4eceddf0159dec5d821aa1e41 \
  > ~/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp/.hf_revision
```

The Hub re-quantizes this repo in place. The revision above is a full-tree
snapshot hash; if upstream moves main, this pin still installs the exact bits
this recipe's receipts were made with.

## 3. Small-file manifest

`files/SHA256SUMS` lists SHA256 of every non-shard file at the pinned
revision. `setup.sh` verifies what exists and fails closed on mismatch.
Weight shards are verified by count + HF etag during download, not by local
hash (100 GiB re-hash is not worth it on every run; the etag check happens
inside `hf download`).
