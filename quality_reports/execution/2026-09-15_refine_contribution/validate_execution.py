"""Validate gate records and reviewed freezes without running paper analyses."""
from pathlib import Path
import argparse
import csv
import hashlib
import json

BASE = Path(__file__).resolve().parent
REPO = BASE.parents[2]
STATES = {"planejado", "em execução", "em revisão", "aprovado",
          "requer correção", "decisão do autor"}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate():
    records = []
    states = []
    for gate in range(8):
        folder = BASE / f"gate_{gate:02d}"
        for name in ["README.md", "state.json", "checklist.json"]:
            assert (folder / name).is_file(), f"Missing {folder / name}"
        state = json.loads((folder / "state.json").read_text())
        checklist = json.loads((folder / "checklist.json").read_text())
        assert state["gate"] == checklist["gate"] == gate
        assert state["state"] in STATES
        ids = [x["id"] for x in checklist["items"]]
        assert len(ids) == len(set(ids)) and ids
        # The already reviewed Gate 0 checklist uses paths relative to its gate;
        # later checklists use paths relative to the execution folder.
        evidence_base = folder if gate == 0 else BASE
        for item in checklist["items"]:
            for reference in item.get("evidence", []):
                assert (evidence_base / reference).is_file(), f"Missing item evidence: {reference}"
        for reference in state.get("evidence", []):
            assert (BASE / reference).is_file(), f"Missing evidence: {reference}"
        if state.get("decision"):
            assert (BASE / state["decision"]).is_file()
        if state["state"] == "aprovado":
            assert gate == 0 or states[-1] == "aprovado", f"Gate {gate}: dependency"
            assert all(x["status"] == "verificado" and x["evidence"]
                       for x in checklist["items"]), f"Gate {gate}: checklist"
            assert state["review"] and state["decision"]
            assert (BASE / state["decision"]).is_file()
        if state.get("review"):
            review = json.loads((BASE / state["review"]).read_text())
            assert review["verdict"] == "PASS", f"Gate {gate}: technical review not PASS"
            if state["state"] == "decisão do autor":
                assert review["gate_approved"] is False
                assert state.get("goal_completion") is False
                assert state.get("pending"), f"Gate {gate}: decision without open items"
            freeze_path = BASE / review["freeze_manifest"]
            assert sha(freeze_path) == review["freeze_manifest_sha256"]
            freeze = json.loads(freeze_path.read_text())
            for item in freeze["files"]:
                assert sha(BASE / item["path"]) == item["sha256"], item["path"]
            for item in review.get("reviewed_context", []):
                assert sha(BASE / item["path"]) == item["sha256"], item["path"]
        if gate > 1 and states[1] != "aprovado":
            assert state["state"] == "planejado", f"Gate {gate}: premature execution"
            assert state.get("execution_started") is False
        states.append(state["state"])
        records.append({"gate": gate, "state": state["state"],
                        "checklist_items": len(ids), "decision": state["decision"],
                        "review": state["review"]})

    inventory = BASE / "gate_00/inventory"
    for name, expected in [("task_inventory.csv", 26),
                           ("application_candidates.csv", 14),
                           ("rogowski_additional_comparisons.csv", 3),
                           ("number_provenance.csv", 4)]:
        with (inventory / name).open() as handle:
            assert len(list(csv.DictReader(handle))) == expected, name
    with (BASE / "gate_00/revalidation/response_matrix.csv").open() as handle:
        assert len(list(csv.DictReader(handle))) == 21
    return records


def baseline_status():
    """Report current hashes without treating later authorized edits as errors."""
    baseline = json.loads((BASE / "baseline_manifest.json").read_text())
    checked = []
    for entry in baseline["files"]:
        current = sha(REPO / entry["path"])
        checked.append({"path": entry["path"],
                        "baseline_sha256": entry["sha256"],
                        "current_sha256": current,
                        "unchanged": current == entry["sha256"]})
    return {"files": checked,
            "all_unchanged": all(entry["unchanged"] for entry in checked)}


def numeric_status():
    """Verify saved R outputs; this function never executes R or refits models."""
    folder = BASE / "gate_01/numerical/results/primary"
    if not folder.exists():
        return {"executed": False}
    marker = dict(line.split("=", 1) for line in
                  (folder / "final_status.txt").read_text().splitlines())
    manifest_path = folder / "output_manifest.csv"
    assert sha(manifest_path) == marker["output_manifest_sha256"]

    def rows(name):
        with (folder / name).open() as handle:
            return list(csv.DictReader(handle))

    manifest = rows("output_manifest.csv")
    for entry in manifest:
        output = folder / entry["file"]
        assert sha(output) == entry["sha256"], entry["file"]
        assert output.stat().st_size == int(entry["bytes"])
    checks = rows("validation_checks.csv")
    covariance = rows("covariance_transform_checks.csv")
    projections = [x for x in rows("expected_vs_computed_projections.csv")
                   if x["field_status"] == "reportado"]
    if marker["status"] == "PASS":
        assert all(x["pass"] == "TRUE" for x in checks + covariance)
        assert all(x["check_status"] == "PASS" for x in projections)
    return {
        "executed": True, "final_status": marker["status"],
        "hashed_outputs": len(manifest), "validation_checks": len(checks),
        "covariance_checks": len(covariance),
        "reported_projection_checks": len(projections),
        "max_projection_absolute_error": max(float(x["abs_error"])
                                             for x in projections),
        "max_covariance_absolute_difference":
            max(float(x["max_abs_difference"]) for x in covariance),
        "scope": "deterministic fixtures; no Monte Carlo or coverage evaluation",
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, help="Optional validation JSON")
    args = parser.parse_args()
    result = {"result": "PASS", "scope": "gate records, reviewed hashes and counts",
              "gates": validate(), "baseline": baseline_status(),
              "saved_numeric_outputs": numeric_status(),
              "analytical_execution": False}
    if args.out:
        args.out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(result, ensure_ascii=False, indent=2))
