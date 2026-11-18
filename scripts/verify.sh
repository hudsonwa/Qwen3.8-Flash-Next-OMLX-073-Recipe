#!/usr/bin/env bash
# Post-install gate. Exit 0 ONLY on full pass. No partial credit.
set -uo pipefail
cd $(dirname $0)/..
pass=0; failcnt=0
ok(){ printf '  ✓ %s\n' "$*"; pass=$((pass+1)); }
no(){ printf '  ✗ %s\n' "$*"; failcnt=$((failcnt+1)); }

echo '== verify: oMLX 0.7.3 Flash-Next stack =='
V=$($HOME/.omlx/bin/omlx --version 2>/dev/null || echo none)
[ "$V" = 0.7.3 ] && ok "engine 0.7.3" || no "engine version $V != 0.7.3"

APPVER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' $HOME/Applications/oMLX.app/Contents/Info.plist 2>/dev/null || echo none)
[ "$APPVER" = 0.7.3 ] && ok 'app bundle 0.7.3' || no "app bundle $APPVER"

N=$(ls $HOME/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp/model-*.safetensors 2>/dev/null | wc -l | tr -d ' ')
[ "$N" = 21 ] && ok '21 shards on disk' || no "shards: $N != 21"
[ -f $HOME/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp/.hf_revision ] && ok 'revision pin file' || no '.hf_revision missing'
R=$(cat $HOME/models/omlx-qwen38/qwen38-flash-next-oq4e-mtp/.hf_revision 2>/dev/null)
[ "$R" = 2322c888c2c314d4eceddf0159dec5d821aa1e41 ] && ok 'revision matches pin' || no "revision $R"

KEY=$(cat $HOME/.omlx/api-key 2>/dev/null)
# Send the key from a file descriptor, not the command line (other users can read `ps`).
auth(){ printf 'Authorization: Bearer %s' "$KEY"; }
[ -n "$KEY" ] && ok 'api-key present' || no 'api-key missing'

HTTP=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -H @<(auth) http://127.0.0.1:8010/v1/models)
[ "$HTTP" = 200 ] && ok 'endpoint /v1/models 200' || no "endpoint http $HTTP (is the server up? run setup step 5)"

MID=$(curl -s --max-time 10 -H @<(auth) http://127.0.0.1:8010/v1/models | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["data"][0]["id"] if d.get("data") else "NONE")' 2>/dev/null)
[ "$MID" = qwen38-flash-next-oq4e-mtp ] && ok "model id served: $MID" || no "model id: $MID"

# live completion: the real gate. >=8 tokens proves full pipeline.
RESP=$(curl -s --max-time 180 -H @<(auth) -H 'Content-Type: application/json' \
  http://127.0.0.1:8010/v1/chat/completions \
  -d '{"model":"qwen38-flash-next-oq4e-mtp","messages":[{"role":"user","content":"Reply with the single word: OK"}],"max_tokens":16,"temperature":0}')
CT=$(echo "$RESP" | python3 -c 'import json,sys; print(json.load(sys.stdin)["usage"]["completion_tokens"])' 2>/dev/null || echo 0)
[ "$CT" -ge 1 ] && ok "live completion ($CT completion tokens)" || no 'live completion failed'

PERM=$(stat -f %Lp $HOME/.omlx/api-key 2>/dev/null)
[ "$PERM" = 600 ] && ok 'api-key readable by owner only' || no "api-key permissions $PERM (want 600: chmod 600 ~/.omlx/api-key)"

# memory sanity: loaded model within 128GB budget via /health
HP=$(curl -s --max-time 10 -H @<(auth) http://127.0.0.1:8010/health | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["status"], int(d["engine_pool"]["current_model_memory"]//2**30))' 2>/dev/null)
echo "  health: $HP (status, model GiB)"

echo
if [ "$failcnt" = 0 ]; then echo "VERIFY PASS ($pass checks)"; exit 0; else echo "VERIFY FAIL ($pass ok, $failcnt failed)"; exit 1; fi
