# TRAPS — every one hit in production on the reference machine

1. **/Applications in-place upgrade is TCC-blocked** from a terminal → half
   bundles. Always `~/Applications`, always fresh-copy the new bundle.
2. **control.sock refuses connections** when the app was not GUI-launched.
   `omlx restart` via the shim then fails with Errno 61. Workaround that
   works headless: `kill -TERM <app-pid>`; `open -gj` relaunches cleanly.
3. **RSS lies on Apple Silicon.** Weights are mmap'd; `ps` showed 21 GB while
   `footprint` phys\_footprint was ~69–79 GB. Budget with `/usr/bin/footprint`.
4. **A port is not an identity.** :8010 has been owned by different engines
   across this machine's history. `lsof` + `ps` the listener before trusting it.
5. **No /version HTTP route** on oMLX (404 by design). Version lives in the CLI
   and bundle plist only.
6. **1-token completions fake throughput.** `generation_tokens_per_second` on a
   7-token reply was 91 tok/s vs 55 tok/s on a real 112-token generation. The
   small number is the honest one; the big one is duration-ratio noise.
7. **launchd does not know this app.** `launchctl kickstart gui/501/com.omlx.*`
   fails unless you installed a plist yourself. The app self-supervises its
   server child; kill the app pid, not the python child, for a clean cycle.
8. **Global `sampling` has no presence\_penalty.** The quality contract's
   presence 1.5 ONLY exists per-model in `model_settings.json`. Putting it in
   the wrong file silently drops the pin.
9. **Hub re-quantizes in place.** A tree without `.hf_revision` is of unknown
   provenance even if the directory name matches. Pin + record the revision.
10. **Cold TTFT is minutes, not seconds**, on first boot after reboot (page
    cache cold). Never publish a first-token-after-boot number as latency.
