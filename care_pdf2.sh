#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null

# Inputs
INTAKE=$(ls -t outputs/care_intake_*.md 2>/dev/null | head -n1)
BRIEF=$(ls -t outputs/care_doctor_brief_*.md 2>/dev/null | head -n1)
FUPS=$(ls -t outputs/care_followups_*.md 2>/dev/null | head -n1)
SUMM=$(ls -t outputs/care_summary_*.md 2>/dev/null | head -n1)

[ -z "$INTAKE" ] && { echo "No care_* files found. Run bcare first."; exit 1; }

TS=$(date -u +'%Y%m%d_%H%M%S')
OUTMD="outputs/care_bundle_${TS}.md"
OUTHTML="outputs/care_bundle_${TS}.html"

# CSV → Markdown table helper (no extra deps)
csv_to_md() {
  python - "$1" <<'PY'
import csv, sys
path=sys.argv[1]
with open(path, newline='', encoding='utf-8') as f:
    r=csv.reader(f)
    rows=list(r)
if not rows:
    sys.exit(0)
header=rows[0]
print("| " + " | ".join(header) + " |")
print("|" + "|".join(["---"]*len(header)) + "|")
for row in rows[1:]:
    safe=[(c or "").replace("|","\\|") for c in row]
    print("| " + " | ".join(safe) + " |")
PY
}

# assemble markdown
{
  echo "# Care Pack — Print Bundle (${TS} UTC)"
  echo
  [ -n "$BRIEF" ] && { echo "## Doctor Brief"; echo; cat "$BRIEF"; echo; }
  [ -n "$SUMM" ]  && { echo "## Symptom Summary (Last 7 Days)"; echo; cat "$SUMM"; echo; }
  [ -n "$INTAKE" ] && { echo "## Patient Intake Checklist"; echo; cat "$INTAKE"; echo; }
  [ -n "$FUPS" ] && { echo "## Follow-up Questions"; echo; cat "$FUPS"; echo; }

  # meds table if exists
  if [ -f outputs/meds.csv ]; then
    echo "## Medications & Supplements (History)"
    echo
    csv_to_md outputs/meds.csv
    echo
  fi

  # labs table if exists
  if [ -f outputs/labs.csv ]; then
    echo "## Labs (History)"
    echo
    csv_to_md outputs/labs.csv
    echo
  fi

  echo
  echo "> **Disclaimer:** Not medical advice. For discussion with a licensed clinician."
} > "$OUTMD"

CSS=/sdcard/Download/pandoc_print.css
cat > "$CSS" <<'CSS'
body { font-family: -apple-system, Roboto, "Segoe UI", Arial, sans-serif; line-height: 1.4; margin: 24px; }
h1, h2, h3 { margin-top: 1.2em; margin-bottom: 0.5em; }
code, pre { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
hr { border: 0; border-top: 1px solid #ddd; margin: 1.2em 0; }
blockquote { color: #444; border-left: 4px solid #ddd; padding-left: 12px; }
table { border-collapse: collapse; width: 100%; }
td, th { border: 1px solid #ddd; padding: 6px; }
CSS

if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc not found. Install with: pkg install -y pandoc"
  exit 1
fi

pandoc "$OUTMD" --from markdown --to html5 --standalone \
  --metadata title="Care Pack — Print Bundle" \
  --css "$CSS" -o "$OUTHTML"

echo "✅ Print bundle saved:"
echo " - $OUTMD"
echo " - $OUTHTML"
echo "Open in Chrome → Share → Print → Save as PDF."
