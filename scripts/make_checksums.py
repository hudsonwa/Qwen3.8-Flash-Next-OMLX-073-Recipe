#!/usr/bin/env python3
'Regenerate files/SHA256SUMS from a local pinned tree. Usage: make_checksums.py [tree]'
import hashlib, pathlib, sys
tree=pathlib.Path(sys.argv[1] if len(sys.argv)>1 else pathlib.Path.home()/'models/omlx-qwen38/qwen38-flash-next-oq4e-mtp')
rev=(tree/'.hf_revision').read_text().strip() if (tree/'.hf_revision').exists() else 'UNKNOWN'
out=['# SHA256 of small checkpoint files at revision '+rev,
     '# weight shards excluded; verify via count (21) + hf etag during download']
for p in sorted(tree.iterdir()):
    if p.is_file() and not p.name.startswith('.') and p.name!='_pull_state.txt' and not p.name.startswith('model-'):
        out.append(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}')
print('\n'.join(out))
