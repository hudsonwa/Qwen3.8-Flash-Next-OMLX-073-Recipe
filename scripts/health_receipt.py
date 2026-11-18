#!/usr/bin/env python3
'''Smoke receipt: one real completion (asks for up to 160 tokens); writes dated JSON to results/.
Every receipt carries the machine stamp and the command that produced it.
Fewer than 100 completion tokens = liveness only, not a throughput claim (see docs/METHODOLOGY.md).'''
import datetime, json, pathlib, platform, subprocess, sys, urllib.request

MODEL = 'qwen38-flash-next-oq4e-mtp'
URL = 'http://127.0.0.1:8010/v1/chat/completions'
KEY = (pathlib.Path.home()/'.omlx/api-key').read_text().strip()
BODY = {
  'model': MODEL,
  'messages': [{'role':'user','content':'In two sentences: what is unique about Speculative MTP decoding? No preamble.'}],
  'max_tokens': 160, 'temperature': 0.7,
  'chat_template_kwargs': {'enable_thinking': False}}

def sysctl(name):
    try:
        return subprocess.run(['sysctl','-n',name], capture_output=True, text=True, timeout=5).stdout.strip()
    except Exception:
        return None

req = urllib.request.Request(URL, data=json.dumps(BODY).encode(), method='POST',
      headers={'Authorization': f'Bearer {KEY}', 'Content-Type': 'application/json'})
try:
    with urllib.request.urlopen(req, timeout=180) as r:
        d = json.loads(r.read())
except Exception as e:
    sys.exit(f'endpoint did not answer: {e}')
u = d.get('usage') or {}
mem = sysctl('hw.memsize')
ct = u.get('completion_tokens') or 0
rec = {
  'date': datetime.datetime.now().astimezone().isoformat(timespec='seconds'),
  'command': 'python3 scripts/health_receipt.py',
  'request': {k: BODY[k] for k in ('max_tokens','temperature')},
  'engine': 'oMLX 0.7.3',
  'model': MODEL,
  'hf_revision': '2322c888c2c314d4eceddf0159dec5d821aa1e41',
  'machine': {'chip': sysctl('machdep.cpu.brand_string'), 'mem_gb': int(mem)//2**30 if mem else None,
              'macos': platform.mac_ver()[0]},
  'content_head': ((d.get('choices') or [{}])[0].get('message',{}).get('content') or '')[:160].replace(chr(10),' '),
  'prompt_tokens': u.get('prompt_tokens'),
  'completion_tokens': ct,
  'gen_tokens_per_second': u.get('generation_tokens_per_second'),
  'ttft_s': u.get('time_to_first_token'),
  'kind': 'throughput-eligible' if ct >= 100 else 'liveness-only',
}
p = pathlib.Path(__file__).resolve().parent.parent/'results'; p.mkdir(exist_ok=True)
f = p/f"smoke_{datetime.datetime.now():%Y%m%d-%H%M%S}.json"
f.write_text(json.dumps(rec, indent=1))
print(f'receipt: {f}')
print(f"  {ct} tok @ {rec['gen_tokens_per_second']} tok/s, ttft {rec['ttft_s']}s ({rec['kind']})")
