#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd ~/bestie_ai

OUTDIR="$HOME/storage/shared/Download/BestieAI"
mkdir -p "$OUTDIR"

TS=$(date -u +'%Y%m%d_%H%M%S')
ZIP="$OUTDIR/care_pack_${TS}.zip"

# Expand patterns safely (skip if no matches)
shopt -s nullglob
include=(outputs/care_* outputs/meds.csv outputs/labs.csv README.md LOCKED.md)

files=()
for pattern in "${include[@]}"; do
  for file in $pattern; do
    [ -e "$file" ] && files+=("$file")
  done
done

if [ ${#files[@]} -eq 0 ]; then
  echo "Nothing to export yet."
  exit 0
fi

rm -f "$ZIP"
zip -r9 "$ZIP" "${files[@]}" >/dev/null

# Integrity hash
sha256sum "$ZIP" | tee "$ZIP.sha256"

echo "✅ Exported → $ZIP"
echo "Tip: Share it from Files › Downloads › BestieAI."
