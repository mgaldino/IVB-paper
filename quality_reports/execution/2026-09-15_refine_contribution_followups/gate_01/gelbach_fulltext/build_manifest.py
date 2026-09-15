"""Create or verify the addendum manifest without running scientific analyses."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json

BASE = Path(__file__).resolve().parent
MANIFEST = BASE / "delivery_manifest.json"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory():
    return sorted(p for p in BASE.rglob("*") if p.is_file() and p != MANIFEST
                  and "__pycache__" not in p.relative_to(BASE).parts)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    paths = inventory()
    if args.verify:
        record = json.loads(MANIFEST.read_text(encoding="utf-8"))
        expected = {item["path"] for item in record["files"]}
        actual = {str(p.relative_to(BASE)) for p in paths}
        if actual != expected:
            raise SystemExit(f"Inventory mismatch: {sorted(actual ^ expected)}")
        for item in record["files"]:
            p = BASE / item["path"]
            if digest(p) != item["sha256"] or p.stat().st_size != item["bytes"]:
                raise SystemExit(f"Changed: {item['path']}")
        print(f"PASS: {len(paths)} addendum files match their recorded bytes")
        return
    if MANIFEST.exists():
        raise SystemExit("Manifest exists. Preserve this delivery before writing a later one.")
    state = json.loads((BASE / "current_state.json").read_text(encoding="utf-8"))
    record = {
        "created_at_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "scope": "All addendum files except this manifest and Python caches",
        "gate_approved": state["gate_approved"],
        "fulltext_reading_status": state["fulltext_reading_status"],
        "files": [{"path": str(p.relative_to(BASE)), "sha256": digest(p),
                   "bytes": p.stat().st_size} for p in paths],
    }
    MANIFEST.write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Created addendum manifest with {len(paths)} files")


if __name__ == "__main__":
    main()
