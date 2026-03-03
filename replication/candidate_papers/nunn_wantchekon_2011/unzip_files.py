#!/usr/bin/env python3
import zipfile
import os
import sys

base = os.path.dirname(os.path.abspath(__file__))

for zname in ['dv-files.zip', 'dv-stata-data.zip']:
    zpath = os.path.join(base, zname)
    if os.path.exists(zpath):
        with zipfile.ZipFile(zpath, 'r') as z:
            names = z.namelist()
            print(f"{zname} contains: {names}")
            z.extractall(base)
            print(f"  -> Extracted OK")
    else:
        print(f"{zname} not found")

print("\nFiles now in directory:")
for f in sorted(os.listdir(base)):
    print(f"  {f}")
