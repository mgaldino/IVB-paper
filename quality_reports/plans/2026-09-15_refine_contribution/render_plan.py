"""Render only the planning report; does not render or re-estimate the paper."""
from pathlib import Path
import subprocess
import json

out = Path(__file__).resolve().parent
document = json.loads(subprocess.check_output(['pandoc', str(out/'plan.md'), '-t', 'json']))
widths = iter([[0.20,0.42,0.38], [0.16,0.84], [0.24,0.60,0.16], [0.42,0.58]])
for block in document['blocks']:
    if block['t'] == 'Table':
        for column,width in zip(block['c'][2], next(widths), strict=True):
            column[1] = {'t':'ColWidth','c':width}
subprocess.run([
    'pandoc', '--from=json', '-o', str(out/'plan.pdf'),
    '--pdf-engine=xelatex', '--toc', '--toc-depth=2',
    '--include-in-header', str(out/'pdf_header.tex'),
    '-V', 'papersize=a4', '-V', 'fontsize=11pt',
    '-V', 'geometry:margin=2.1cm', '-V', 'mainfont=Palatino',
    '-V', 'sansfont=Helvetica', '-V', 'monofont=Menlo',
    '-V', 'linestretch=1.08', '-V', 'colorlinks=true',
    '-V', 'linkcolor=teal', '-V', 'urlcolor=teal',
], input=json.dumps(document), text=True, cwd=out, check=True)
print(out/'plan.pdf')
