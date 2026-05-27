import urllib.request
import json

packages = [
    'dio', 'flutter_riverpod', 'riverpod_annotation', 'go_router',
    'drift', 'sqlite3_flutter_libs', 'path_provider', 'path',
    'shared_preferences', 'cached_network_image', 'crypto',
    'build_runner', 'drift_dev', 'flutter_lints',
    'riverpod', 'sqlite3', 'build_runner_core', 'build_resolvers',
]

results = {}
for pkg in packages:
    url = 'https://api.osv.dev/v1/query'
    body = json.dumps({'package': {'name': pkg, 'ecosystem': 'Pub'}}).encode()
    req = urllib.request.Request(url, data=body, headers={'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
            vulns = data.get('vulns', [])
            results[pkg] = vulns
    except Exception as e:
        results[pkg] = str(e)

for pkg, vulns in results.items():
    if isinstance(vulns, list) and len(vulns) > 0:
        vuln_id = vulns[0].get('id', '?')
        summary = vulns[0].get('summary', 'sin descripcion')
        print(f'[VULN] {pkg}: {len(vulns)} vulnerabilidad(es) | {vuln_id} | {summary}')
    elif isinstance(vulns, list):
        print(f'[OK]   {pkg}: sin vulnerabilidades conocidas')
    else:
        print(f'[ERR]  {pkg}: {vulns}')
