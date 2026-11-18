#!/usr/bin/env python3
'''Write the per-model quality contract for qwen38-flash-next-oq4e-mtp.
Per-model settings beat the global sampling block (which has no presence field).'''
import json, pathlib, sys

HOME = pathlib.Path.home()
MS = HOME/'.omlx/model_settings.json'
KEY = 'qwen38-flash-next-oq4e-mtp'

CONTRACT = {
    'display_name': 'Qwen3.8-Flash-Next oQ4e-mtp',
    'is_pinned': True, 'is_default': True,
    'max_context_window': 262144,
    'enable_thinking': False, 'preserve_thinking': False,
    'chat_template_kwargs': {'enable_thinking': False},
    'forced_ct_kwargs': ['enable_thinking'],
    'temperature': 0.7, 'top_p': 0.8, 'top_k': 20, 'min_p': 0.0,
    'presence_penalty': 1.5, 'repetition_penalty': 1.0,
    'force_sampling': True,
    'mtp_enabled': True, 'vlm_mtp_enabled': False,
    'qwen4_ple_ssd_offload': True,
    'turboquant_kv_enabled': False,      # quality pin: KV quantization off
    'qwen35_oq_a8_enabled': False,       # quality pin: activation quant off
    'moe_expert_offload_enabled': False,
    'specprefill_enabled': False,
}

def main():
    data = json.loads(MS.read_text()) if MS.exists() else {'version':'1.0','models':{}}
    models = data.setdefault('models', {})
    old = models.get(KEY, {})
    merged = dict(old); merged.update(CONTRACT)
    models[KEY] = merged
    MS.parent.mkdir(parent_ok := True, exist_ok=True) if False else MS.parent.mkdir(parents=True, exist_ok=True)
    MS.write_text(json.dumps(data, indent=1))
    print(f'quality contract written for {KEY} ({len(merged)} keys)')

if __name__ == '__main__':
    main()
