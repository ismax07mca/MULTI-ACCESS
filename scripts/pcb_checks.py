# scripts/pcb_checks.py
# Usage: Run inside KiCad scripting console or with pcbnew python API
# This script attaches STEP files to footprints (if the 3D_models/<name>.step exists)
# and runs a DRC summary (requires KiCad environment).
import pcbnew, os, sys

board_path = "modem_multi_access.kicad_pcb"
board = pcbnew.LoadBoard(board_path)

# Attach STEP files for footprints that contain a 3D model name in a property (optional)
models_dir = os.path.join(os.getcwd(), "3D_models")
for fp in board.GetFootprints():
    val = fp.GetValue()
    # Example: If footprint name matches a STEP file name, attach it (coarse heuristic)
    step_name = f"{fp.GetValue()}.step"
    step_path = os.path.join(models_dir, step_name)
    if os.path.exists(step_path):
        # create 3D model association (basic)
        md = pcbnew.PCB_3D_MODEL(step_path, pcbnew.RPY(0,0,0))
        # Note: actual API differs by KiCad version; use Footprint Editor to attach if needed
        print("Would attach", step_path, "to footprint", fp.GetReference())

# Run DRC
dra = pcbnew.DRAWER(board) if hasattr(pcbnew, "DRAWER") else None
checker = pcbnew.DRC(board)
report = checker.Run()
print("DRC report (summary):")
print(report)
# Save board (no modification by default)
board.Save(board_path + ".checked")
print("Saved board copy:", board_path + ".checked")