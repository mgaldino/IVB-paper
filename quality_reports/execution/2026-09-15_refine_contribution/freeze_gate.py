"""Freeze gate artifacts for review; verify a saved freeze without changing it."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json

BASE = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("gate", type=int, choices=range(8))
    parser.add_argument("round", type=int)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    folder = BASE / f"gate_{args.gate:02d}"
    manifest = folder / f"freeze_round{args.round}.json"
    if args.verify:
        record = json.loads(manifest.read_text())
        errors = [entry["path"] for entry in record["files"]
                  if not (BASE / entry["path"]).is_file()
                  or sha(BASE / entry["path"]) != entry["sha256"]]
        if errors:
            raise SystemExit("Changed or missing: " + ", ".join(errors))
        print(f"PASS: {len(record['files'])} frozen files match")
        return
    if manifest.exists():
        raise SystemExit("Freeze already exists; use a new round")
    files = [{"path": str(path.relative_to(BASE)), "sha256": sha(path)}
             for path in sorted(folder.rglob("*"))
             if path.is_file() and "review" not in path.relative_to(folder).parts
             and not path.name.startswith("freeze_round")
             and path.name not in {"state.json", "checklist.json", "README.md"}]
    manifest.write_text(json.dumps({
        "gate": args.gate, "round": args.round,
        "frozen_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "scope": "Scientific and documentary artifacts; review and live index excluded",
        "files": files,
    }, ensure_ascii=False, indent=2) + "\n")
    print(f"Frozen {len(files)} files: {manifest}")


if __name__ == "__main__":
    main()
