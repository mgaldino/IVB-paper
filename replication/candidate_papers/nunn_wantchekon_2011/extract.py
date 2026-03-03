import zipfile
import os

base = '/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/candidate_papers/nunn_wantchekon_2011'

for zname in ['dv-files.zip', 'dv-stata-data.zip']:
    zpath = os.path.join(base, zname)
    with zipfile.ZipFile(zpath, 'r') as z:
        print(f"Contents of {zname}:")
        for n in z.namelist():
            print(f"  {n}")
        z.extractall(base)
        print(f"Extracted successfully.\n")
