# results/

`smoke_20261118-133344.json` is from the 0.1.0 release. It is a 7-token liveness check
(the server answered), written before receipts carried a machine stamp or command, and its
field names differ from what `scripts/health_receipt.py` writes now. Its tokens/s figure is
not a throughput result (see `docs/TRAPS.md` #6). It is kept unchanged as the original record.

Receipts written from 0.1.1 on carry `command`, `machine` and `kind`
(`liveness-only` under 100 completion tokens, else `throughput-eligible`).
