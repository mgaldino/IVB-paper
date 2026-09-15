"""Verify saved documentary evidence; never execute R, Stata or an analysis."""
from pathlib import Path
import csv
import hashlib
import json
import subprocess
import sys

BASE = Path(__file__).resolve().parent
REPO = BASE.parents[4]
OLD = REPO / "quality_reports/execution/2026-09-15_refine_contribution"


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def read_json(p):
    return json.loads(p.read_text(encoding="utf-8"))


def check(condition, message):
    if not condition:
        raise SystemExit(message)


acquisition = read_json(BASE / "acquisition.json")
source = BASE / "sources/gelbach_2016_683668.pdf"
check(digest(source) == acquisition["pdf_sha256"], "Source PDF changed")
original = Path(acquisition["original_path"])
if original.exists():
    check(digest(original) == digest(source), "Original and copied PDF differ")
text_path = BASE / "sources/gelbach_2016_683668.txt"
check(digest(text_path) == acquisition["text_sha256"], "Extracted text changed")
pages = [p for p in text_path.read_text(encoding="utf-8").split("\f") if p.strip()]
check(len(pages) == 35, "Text page count differs from 35")

with (BASE / "reading/page_coverage.csv").open(encoding="utf-8", newline="") as f:
    coverage = list(csv.DictReader(f))
check([int(r["pdf_page"]) for r in coverage] == list(range(1, 36)), "Coverage PDF sequence invalid")
check([int(r["printed_page"]) for r in coverage] == list(range(509, 544)), "Printed page sequence invalid")
check(all(r["read_text_layout"] == "yes" for r in coverage), "Uncovered text page")
with (BASE / "reading/claim_comparison.csv").open(encoding="utf-8", newline="") as f:
    claims = list(csv.DictReader(f))
check([r["claim_id"] for r in claims] == [f"L{i:02d}" for i in range(1, 18)], "Claim sequence invalid")
reader = read_json(BASE / "reading/read_manifest.json")
check(digest(source) == reader["source"]["pdf_sha256"], "Reader refers to another PDF")
check(digest(text_path) == reader["source"]["text_sha256"], "Reader refers to another extraction")
check(digest(BASE / "sources/page_map.json") == reader["source"]["page_map_sha256"], "Page map changed")
for item in reader["outputs"] + reader["prior_inputs"]:
    check(digest(REPO / item["path"]) == item["sha256"], f"Reader input/output changed: {item['path']}")

snapshot_count = 0
for freeze_path in sorted(BASE.glob("review_input_freeze_round*.json")):
    for item in read_json(freeze_path)["files"]:
        snapshot = BASE / item["snapshot"]
        check(digest(snapshot) == item["sha256"], f"Review snapshot changed: {snapshot}")
        check(snapshot.stat().st_size == item["bytes"], f"Review snapshot size changed: {snapshot}")
        snapshot_count += 1

state = read_json(BASE / "current_state.json")
check(state["gate_approved"] is False, "Unexpected scientific approval")
check(state["fulltext_reading_status"] == "complete_and_independently_reviewed", "Reading/review incomplete")
for item in state["accepted_review_records"]:
    check(digest(BASE / item["path"]) == item["sha256"], f"Accepted review changed: {item['path']}")
build = read_json(BASE / "build.json")
check(digest(BASE / build["source"]) == build["source_sha256"], "PDF source changed since build")
check(digest(BASE / build["output"]) == build["output_sha256"], "Built PDF changed")
qa = read_json(BASE / "visual_qa.json")
check(qa["pdf_sha256"] == build["output_sha256"], "Visual QA refers to another PDF")
check(qa["result"] == "PASS" and len(qa["pages"]) == qa["pdf_pages"], "Visual QA incomplete")
check(all(p["result"] == "PASS" for p in qa["pages"]), "A PDF page did not pass visual QA")

old_manifest_output = subprocess.check_output(
    [sys.executable, str(OLD / "build_delivery_manifest.py"), "--verify"], text=True, cwd=REPO).strip()
old_validation = json.loads(subprocess.check_output(
    [sys.executable, str(OLD / "validate_execution.py")], text=True, cwd=REPO))
check(old_validation["result"] == "PASS", "Original gate validation failed")
check(old_validation["baseline"]["all_unchanged"], "Original source files changed")
result = {
    "result": "PASS",
    "scope": "Saved files, source identity, coverage records, frozen snapshots, build/QA and baseline preservation",
    "source_pdf_sha256": digest(source),
    "original_download_present": original.exists(),
    "recorded_text_pages": len(coverage),
    "recorded_visual_pages_by_reader": sum(r["visual_math_check"] == "yes" for r in coverage),
    "claims": len(claims),
    "frozen_snapshot_checks": snapshot_count,
    "pdf_pages_visually_checked": len(qa["pages"]),
    "original_delivery": old_manifest_output,
    "baseline_files_unchanged": len(old_validation["baseline"]["files"]),
    "gate_approved": False,
    "analytical_execution": False,
    "limitation": "File checks do not independently establish the truth of scientific claims or certify a reader's cognitive coverage; read the source-bound reviews.",
}
print(json.dumps(result, ensure_ascii=False, indent=2))
