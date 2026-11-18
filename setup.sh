#!/usr/bin/env bash
# One-shot install: oMLX 0.7.3 + Qwen3.8-Flash-Next oQ4e-mtp on Apple Silicon.
# Idempotent. Fail-closed. Safe to re-run. Starts the server at the end (step 5).
# Defaults are local-only: the server listens on 127.0.0.1 and no login item is installed.
#   BIND_LAN=1      listen on all interfaces (0.0.0.0) so other machines can reach it
#   INSTALL_PLIST=1 install a launchd login item that relaunches the app (undo: scripts/uninstall_plist.sh)
set -euo pipefail
cd "$(dirname "$0")"

say(){ printf '\n==> %s\n' "$*"; }
fail(){ printf 'FAIL: %s\n' "$*" >&2; exit 1; }

ARCH=$(uname -m); [ "$ARCH" = arm64 ] || fail 'Apple Silicon required (uname -m != arm64)'
MEM_GB=$(sysctl -n hw.memsize | awk '{print int($1/1073741824)}')
[ "$MEM_GB" -ge 96 ] || fail "Need >=96 GB unified memory, found ${MEM_GB}GB (receipts are from 128GB)"

# ---------- 1. engine ----------
say '1/6 oMLX 0.7.3'
VER=$(~/.omlx/bin/omlx --version 2>/dev/null || echo none)
if [ "$VER" = 0.7.3 ]; then
  echo "    already 0.7.3"
else
  DMG=$HOME/Downloads/oMLX-0.7.3-macos26-27.dmg
  EXPECT=2acfde41aeac0b022dbca803ca109437f3ccaf0c33f3415881526b985bee86f2
  if [ ! -f "$DMG" ]; then
    echo '    downloading release DMG (~880 MB)...'
    curl -fsSL -o "$DMG" https://github.com/jundot/omlx/releases/download/v0.7.3/oMLX-0.7.3-macos26-27.dmg
  fi
  GOT=$(shasum -a 256 "$DMG" | awk '{print $1}')
  [ "$GOT" = "$EXPECT" ] || fail "DMG sha mismatch: $GOT != $EXPECT"
  hdiutil attach "$DMG" -nobrowse -quiet
    mkdir -p "$HOME/Applications"
    if [ -d "$HOME/Applications/oMLX.app" ]; then
      # Keep the previous app in the Trash; never copy on top of it (that would nest the bundles).
      mv "$HOME/Applications/oMLX.app" "$HOME/.Trash/oMLX-prev-$(date +%s).app" \
        || { hdiutil detach /Volumes/oMLX -quiet; fail 'could not move the old ~/Applications/oMLX.app aside'; }
    fi
    cp -R /Volumes/oMLX/oMLX.app "$HOME/Applications/"
  hdiutil detach /Volumes/oMLX -quiet
  xattr -dr com.apple.quarantine $HOME/Applications/oMLX.app 2>/dev/null || true
  VER=$(~/.omlx/bin/omlx --version 2>/dev/null || echo none)
  [ "$VER" = 0.7.3 ] || fail "engine version after install: $VER"
fi

# ---------- 2. checkpoint ----------
say '2/6 checkpoint 2322c888 (21 shards, ~100 GiB)'
DEST=$HOME/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp
N=$(ls "$DEST"/model-*.safetensors 2>/dev/null | wc -l | tr -d ' ' || echo 0)
if [ "$N" = 21 ] && [ -f "$DEST/config.json" ] && [ -f "$DEST/.hf_revision" ]; then
  echo '    present, 21 shards, skipping download'
else
  mkdir -p "$DEST"
  command -v hf >/dev/null || python3 -m pip install -q -U 'huggingface_hub[cli]'
  hf download Jundot/Qwen3.8-Flash-Next-oQ4e-mtp \
    --revision 2322c888c2c314d4eceddf0159dec5d821aa1e41 \
    --local-dir "$DEST" --max-workers 4
  echo 2322c888c2c314d4eceddf0159dec5d821aa1e41 > "$DEST/.hf_revision"
fi
[ $(ls "$DEST"/model-*.safetensors | wc -l | tr -d ' ') = 21 ] || fail 'shard count != 21 after download'
python3 - <<'PY'
import hashlib, pathlib, sys
bad=[]
for line in open('files/SHA256SUMS'):
    line=line.strip()
    if not line or line.startswith('#'): continue
    h,name=line.split(None,1) if len(line.split())==2 else (None,line)
    p=pathlib.Path.home()/'models/omlx-qwen38/qwen38-flash-next-oq4e-mtp'/name.strip()
    if not p.exists(): continue  # files added upstream later are not failures
    d=hashlib.sha256(p.read_bytes()).hexdigest()
    if d!=h: bad.append((name.strip(),d,h))
if bad:
    [print(f'  {n}: {a} != {b}') for n,a,b in bad]; sys.exit(1)
print('    small-file manifest OK')
PY

# ---------- 3. settings ----------
say '3/6 quality contract + endpoint'
mkdir -p $HOME/.omlx
[ -f $HOME/.omlx/api-key ] || (umask 077; openssl rand -hex 24 > $HOME/.omlx/api-key)
chmod 600 $HOME/.omlx/api-key
python3 scripts/omlx_settings.py --ensure-keys
python3 scripts/omlx_model_settings.py --apply
KEY=$(cat $HOME/.omlx/api-key)
BIND_LAN="${BIND_LAN:-0}" python3 - "$KEY" <<'PY'
import json, os, pathlib, sys
key=sys.argv[1]
p=pathlib.Path.home()/'.omlx'/'settings.json'
s=json.loads(p.read_text()) if p.exists() else {}
s.setdefault('version','1.0')
s.setdefault('server',{})
srv=s['server']
if os.environ.get('BIND_LAN')=='1':
    srv['host']='0.0.0.0'
else:
    srv.setdefault('host','127.0.0.1')
    if srv['host']=='0.0.0.0':
        print('    NOTE: server is set to listen on ALL interfaces (0.0.0.0); left as is.')
        print('          For local-only, set server.host to 127.0.0.1 in ~/.omlx/settings.json and restart.')
srv.update(port=int(srv.get('port',8010)), auto_start_on_launch=True)
s.setdefault('model',{})
md=pathlib.Path.home()/'models/omlx-qwen38'
cur=s['model'].get('model_dirs') or []
if str(md) not in cur: s['model']['model_dirs']=cur+[str(md)]
s.setdefault('scheduler',{}).update(max_concurrent_requests=2, chunked_prefill=True, prefill_priority='context')
s.setdefault('memory',{}).update(prefill_memory_guard=True, memory_guard_tier='balanced')
s.setdefault('cache',{}).update(enabled=True, hot_cache_only=False, hot_cache_max_size='0', ssd_cache_dir=str(pathlib.Path.home()/'.omlx/ssd-cache'))
a=s.setdefault('auth',{}); a.setdefault('api_key',key)
p.write_text(json.dumps(s,indent=1))
p.chmod(0o600)  # holds the API key
print(f"    settings.json written (listening on {srv['host']}:{srv['port']})")
PY

# ---------- 4. launchd (opt-in daily driver) ----------
say '4/6 optional launchd login item (off unless INSTALL_PLIST=1)'
if [ "${INSTALL_PLIST:-0}" != 1 ]; then echo '    not installed (set INSTALL_PLIST=1 to add it; undo with scripts/uninstall_plist.sh)'; else
  bash scripts/install_plist.sh
fi

# ---------- 5. start ----------
say '5/6 start server'
if lsof -nP -iTCP:8010 -sTCP:LISTEN >/dev/null 2>&1; then
  PID=$(lsof -tnP -iTCP:8010 -sTCP:LISTEN | head -1)
  echo "    :8010 already served by pid $PID — leaving it alone"
else
  open -gj $HOME/Applications/oMLX.app
  for i in $(seq 1 60); do lsof -nP -iTCP:8010 -sTCP:LISTEN >/dev/null 2>&1 && break; sleep 2; done
  lsof -nP -iTCP:8010 -sTCP:LISTEN >/dev/null || fail 'server did not listen on :8010 in 120s'
fi

# ---------- 6. first model load probe happens in verify.sh ----------
say '6/6 done — now run: bash scripts/verify.sh'
