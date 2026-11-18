#!/usr/bin/env python3
'''Ensure ~/.omlx/settings.json exists with recipe-required keys. Never
overwrites values already set (idempotent, add-only for missing keys).'''
import json, pathlib

p = pathlib.Path.home()/'.omlx/settings.json'
s = json.loads(p.read_text()) if p.exists() else {'version':'1.0'}
s.setdefault('server', {}).setdefault('host','0.0.0.0')
s['server'].setdefault('port', 8010)
s['server'].setdefault('auto_start_on_launch', True)
s.setdefault('model', {}).setdefault('model_dirs', [])
md = str(pathlib.Path.home()/'models/omlx-qwen38')
if md not in s['model']['model_dirs']:
    s['model']['model_dirs'].append(md)
s['model'].setdefault('model_dir', md)
s.setdefault('scheduler', {}).update({'chunked_prefill': s['scheduler'].get('chunked_prefill', True)})
s.setdefault('memory', {}).setdefault('prefill_memory_guard', True)
s.setdefault('cache', {}).setdefault('ssd_cache_dir', str(pathlib.Path.home()/'.omlx/ssd-cache'))
pathlib.Path.home().joinpath('.omlx/ssd-cache').mkdir(parents=True, exist_ok=True)
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(json.dumps(s, indent=1))
print('settings.json ensure-keys OK')
