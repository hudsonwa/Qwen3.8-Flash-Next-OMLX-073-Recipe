# PRIVACY

- The SSD prefix/KV cache (`~/.omlx/ssd-cache`) is prompt-derived data at rest,
  unencrypted by this recipe. FileVault (default on macOS) covers it; if you
  need more, stop the server before wiping the dir — never wipe live.
- The API key sits in `~/.omlx/api-key` (0600 by umask). The server binds
  0.0.0.0:8010 — on a shared LAN anyone with the key can run inference. Tighten
  to 127.0.0.1 in `~/.omlx/settings.json` if that is not wanted.
- No telemetry is configured by this recipe beyond oMLX's own defaults.
