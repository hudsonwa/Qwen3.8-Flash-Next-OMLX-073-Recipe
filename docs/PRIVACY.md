# PRIVACY

- The SSD prefix/KV cache (`~/.omlx/ssd-cache`) is prompt-derived data at rest,
  unencrypted by this recipe. FileVault (default on macOS) covers it; if you
  need more, stop the server before wiping the dir — never wipe live.
- The API key sits in `~/.omlx/api-key` and is also copied into
  `~/.omlx/settings.json`; setup makes both chmod 600 (owner only), and
  `verify.sh` checks the key file. The scripts send the key over a file
  descriptor or in-process, never on a command line.
- The server listens on 127.0.0.1:8010 (this Mac only) unless you ran setup with
  `BIND_LAN=1`, which binds 0.0.0.0 — then anyone on the same network who has
  the key can run inference. It is plain HTTP, so on a network the key travels
  unencrypted.
- No telemetry is configured by this recipe beyond oMLX's own defaults.
