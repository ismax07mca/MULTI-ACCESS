#!/usr/bin/env bash
# create_all_files.sh
# Usage: chmod +x create_all_files.sh && ./create_all_files.sh
set -euo pipefail
mkdir -p kicad_project footprints scripts docs 3D_models
# README
cat > README.md <<'EOF'
Projet KiCad — modem_multi_access (squelette)
Exécutez create_all_files.sh pour créer les fichiers placeholders et générer footprints initiaux.
Voir docs/workplan.md pour conventions mécaniques.
EOF

# stackup and design rules
cat > docs/stackup.md <<'EOF'
Stackup proposé (exemple)
Layers: 8 (L1..L8). Er ~3.48 pour simulations.
Voir netclasses.csv et .kicad_dru pour règles.
EOF

cat > docs/netclasses.csv <<'EOF'
name,track_width,clearance,via_drill
default,0.25,0.2,0.6
high_speed,0.2,0.15,0.4
ddr,0.12,0.12,0.3
EOF

cat > .kicad_dru <<'EOF'
# Exemple de design rules unit
min_track_width=0.12
min_annular_ring=0.15
EOF

# minimal KiCad project file (placeholder)
cat > kicad_project/modem_multi_access.kicad_pro <<'EOF'
(kicad_propery_version "2023-01-01")
[version] 2023-08-01
EOF

# placeholder schematic & pcb files
mkdir -p kicad_project/schematic
cat > kicad_project/schematic/modem_multi_access.kicad_sch <<'EOF'
(kicad_schematic_placeholder)
# Remplacer par votre schématique dans KiCad
EOF

cat > kicad_project/modem_multi_access.kicad_pcb <<'EOF'
(kicad_pcb_placeholder)
# Ouvrir dans KiCad et importer DXF, footprints, etc.
EOF

# generate footprints script (invoked below)
cat > scripts/generate_footprints.py <<'PY'
#!/usr/bin/env python3
# generate_footprints.py
# Generates placeholder footprints for MT7988A BGA (configurable) and others.
import os, math
os.makedirs("../footprints", exist_ok=True)
def write_bga(name, rows, cols, pitch_mm, pad_dia_mm):
    path = f"../footprints/{name}.kicad_mod"
    with open(path, "w") as f:
        f.write(f"(footprint {name} (attr smd) (descr \"Auto-generated BGA placeholder\"))\n")
        for r in range(rows):
            for c in range(cols):
                i = r*cols + c + 1
                x = (c - (cols-1)/2) * pitch_mm
                y = (r - (rows-1)/2) * pitch_mm
                f.write(f'(pad {i} smd circle (at {x:.3f} {y:.3f}) (size {pad_dia_mm:.3f} {pad_dia_mm:.3f}) '
                        f'(layers F.Cu F.Mask F.Paste))\n')
    print("Wrote", path)

def write_simple_footprint(name, pads):
    path = f"../footprints/{name}.kicad_mod"
    with open(path, "w") as f:
        f.write(f"(footprint {name} (attr smd) (descr \"Placeholder {name}\"))\n")
        for p in pads:
            f.write(f'(pad {p["n"]} {p["type"]} circle (at {p["x"]} {p["y"]}) (size {p["sx"]} {p["sy"]}) '
                    f'(layers {p["layers"]}))\n')
    print("Wrote", path)

# Example: MT7988A approx. BGA 31x31 @ 0.8mm (placeholder sizes)
write_bga("MT7988A_BGA", 31, 31, 0.8, 0.45)
# RJ45 sample footprint (small subset)
write_simple_footprint("RJ45_7498111001A", [
    {"n":1,"type":"smd","x":-5.715,"y":11.68,"sx":"0.76","sy":"2.03","layers":"F.Cu F.Mask F.Paste"},
    {"n":2,"type":"smd","x":-4.445,"y":11.68,"sx":"0.76","sy":"2.03","layers":"F.Cu F.Mask F.Paste"},
    # ... add as needed
])
PY
chmod +x scripts/generate_footprints.py

# small export bom script
cat > scripts/export_bom.sh <<'EOF'
#!/usr/bin/env bash
# export_bom.sh - placeholder that calls kicad-cli or instructs user
echo "Pour exporter le BOM, ouvrez KiCad Eeschema et utilisez Tools->Generate BOM or use kicad-cli if installed."
EOF
chmod +x scripts/export_bom.sh

# Run footprint generator to create initial footprints
( cd scripts && ./generate_footprints.py )

echo "Squelette créé. Vérifie les dossiers et fichiers :"
ls -R | sed -n '1,200p'
EOF
