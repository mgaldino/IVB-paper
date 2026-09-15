"""Create or verify the delivery manifest without executing scientific analyses."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json

BASE = Path(__file__).resolve().parent
MANIFEST = BASE / "delivery_manifest.json"


def files():
    return sorted(path for path in BASE.rglob("*")
                  if path.is_file() and path != MANIFEST
                  and "__pycache__" not in path.relative_to(BASE).parts)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if args.verify:
        record = json.loads(MANIFEST.read_text())
        expected = {item["path"] for item in record["files"]}
        actual = {str(path.relative_to(BASE)) for path in files()}
        if expected != actual:
            raise SystemExit(f"Inventory mismatch: {sorted(expected ^ actual)}")
        for item in record["files"]:
            path = BASE / item["path"]
            if digest(path) != item["sha256"] or path.stat().st_size != item["bytes"]:
                raise SystemExit(f"Changed: {item['path']}")
        print(f"PASS: {len(expected)} delivery files match their recorded bytes")
        return
    if MANIFEST.exists():
        raise SystemExit("Manifest exists. Preserve it before creating a later delivery.")
    record = {
        "created_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "scope": "All files in this execution folder, excluding this manifest and Python caches",
        "gate_status": {str(i): json.loads((BASE / f"gate_{i:02d}" / "state.json")
                                         .read_text())["state"] for i in range(8)},
        "scientific_approval": "Read each gate decision; a technical PASS does not itself approve scientific contribution",
        "files": [{"path": str(path.relative_to(BASE)), "sha256": digest(path),
                   "bytes": path.stat().st_size} for path in files()],
    }
    MANIFEST.write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n")
    print(f"Created delivery manifest with {len(record['files'])} files")


if __name__ == "__main__":
    main()
