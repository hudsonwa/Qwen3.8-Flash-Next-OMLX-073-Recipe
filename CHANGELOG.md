# Changelog

## recipe-0.1.1-2026-11-18
- Security: server now listens on 127.0.0.1 by default; `BIND_LAN=1` opts in to 0.0.0.0.
  An existing `server.host` is never overwritten (a 0.0.0.0 setting is reported).
- Security: `~/.omlx/api-key` and `~/.omlx/settings.json` are chmod 600; verify.sh checks it;
  the key is no longer passed on curl command lines.
- launchd login item is now really opt-in (`INSTALL_PLIST=1`); added `scripts/uninstall_plist.sh`.
- AGENT.md: agents must ask the operator before opening the server to the network or adding a login item.
- Fixes: model_dirs no longer duplicated on re-run; app upgrade never copies onto an existing bundle;
  setup.sh header no longer claims it does not start the server; verify check count corrected.
- Receipts now carry machine stamp, command and a liveness/throughput label; the 0.1.0 receipt is
  documented as liveness-only.
- Docs: model licence (qwen-community-1.0) named; oMLX licence named; what setup changes on your Mac.

## recipe-0.1.0-2026-11-18
- Initial public recipe. oMLX 0.7.3, Flash-Next oQ4e-mtp @ 2322c888, 128 GB M5 Max reference.
- setup.sh (fail-closed install), verify.sh, health_receipt.py, launchd agent (installed by default in 0.1.0; opt-in from 0.1.1).
- Single smoke receipt from the reference machine; no perf tables yet (see METHODOLOGY).
