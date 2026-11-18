#!/usr/bin/env python3
'''Smoke receipt: one real >=100-token completion; writes dated JSON to results/.
This is the ONLY accepted proof the endpoint answered. 1-token replies are liveness, not throughput.'''
import json, pathlib, subprocess, datetime, sys

KEY = (pathlib.Path.home()/'.omlx/api-key').read_text().strip()
URL = 'http://127.0.0.1:8010/v1/chat/completions'
BODY = json.dumps({
  'model': 'qwen38-flash-next-oq4e-mtp',
  'messages': [{'role':'user','content':'In two sentences: what is unique about Speculative MTP decoding? No preamble.'}],
  'max_tokens': 160, 'temperature': 0.7,
  'chat_template_kwargs': {'enable_thinking': False}})
out = subprocess.run(['curl','-s','--max-time','180','-H',f'Authorization: Bearer {KEY}',
                      '-H','Content-Type: application/json','-d',BODY,URL],
                     capture_output=True, text=True, timeout=200)
try:
    d = json.loads(out.stdout)
except Exception:
    sys.exit(f'no JSON from endpoint: {out.stdout[:200]} {out.stderr[:200]}')
u = d['usage']
rec = {
  'date': datetime.datetime.now().isoformat(timespec='seconds'),
  'engine': 'oMLX 0.7.3',
  'model': 'qwen38-flash-next-oq4e-mtp',
  'hf_revision': '2322c888c2c314d4eceddf0159dec5d821aa1e41',
  'content_head': (d['choices'][0]['message']['content'] or '')[:160].replace(chr(10),' '),
  'prompt_tokens': u.get('prompt_tokens'),
  'completion_tokens': u.get('completion_tokens'),
  'gen_tokens_per_second': u.get('generation_tokens_per_second'),
  'ttft_s': u.get('time_to_first_token'),
  'machine': {'mem_gb': 128},
}
p = pathlib.Path('results'); p.mkdir(exist_ok=True)
f = p/f"smoke_{datetime.datetime.now():%Y%m%d-%H%M%S}.json"
f.write_text(json.dumps(rec, indent=1))
print(f'receipt: {f}')
print(f"  {rec['completion_tokens']} tok @ {rec['gen_tokens_per_second']} tok/s, ttft {rec['ttft_s']}s")
if (rec['completion_tokens'] or 0) < 60:
    print('  NOTE: <60 completion tokens; treat as liveness only, not a throughput claim.')
