"""Render the execution report only; never execute the RMarkdown manuscript."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess

BASE = Path(__file__).resolve().parent
source = BASE / "execution_report.md"
output = BASE / "execution_report.pdf"
command = [
    "pandoc", str(source), "--from=markdown+tex_math_single_backslash",
    "--standalone", "--pdf-engine=xelatex",
    "-o", str(output), "-V", "papersize=a4", "-V", "fontsize=11pt",
    "-V", "geometry:margin=2.1cm", "-V", "mainfont=Palatino",
    "-V", "sansfont=Helvetica", "-V", "monofont=Menlo",
    "-V", "linestretch=1.08", "-V", "colorlinks=true",
    "-V", "linkcolor=teal", "-V", "urlcolor=teal",
]
result = subprocess.run(command, text=True, capture_output=True, cwd=BASE)
(BASE / "report_render.log").write_text(result.stdout + result.stderr)
result.check_returncode()
record = {
    "built_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "command": command,
    "source": source.name,
    "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
    "output": output.name,
    "output_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
    "pandoc_version": subprocess.check_output(["pandoc", "--version"], text=True).splitlines()[0],
    "xelatex_version": subprocess.check_output(["xelatex", "--version"], text=True).splitlines()[0],
    "analytical_execution": False,
}
(BASE / "report_build.json").write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n")
print(output)
