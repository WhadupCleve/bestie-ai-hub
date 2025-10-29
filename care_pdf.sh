#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null

# find latest care files
INTAKE=$(ls -t outputs/care_intake_*.md 2>/dev/null | head -n1)
BRIEF=$(ls -t outputs/care_doctor_brief_*.md 2>/dev/null | head -n1)
FUPS=$(ls -t outputs/care_followups_*.md 2>/dev/null | head -n1)
[ -z "$INTAKE" ] && { echo "No care_* files found. Run bcare first."; exit 1; }

TS=$(date -u +'%Y%m%d_%H%M%S')
OUTMD="outputs/care_bundle_${TS}.md"
OUTHTML="outputs/care_bundle_${TS}.html"

# bundle markdown with a title + mini CSS
{
  echo "# Care Pack — Print Bundle (${TS} UTC)"
  echo
  [ -n "$BRIEF" ] && { echo "## Doctor Brief"; echo; cat "$BRIEF"; echo; }
  [ -n "$INTAKE" ] && { echo "## Patient Intake Checklist"; echo; cat "$INTAKE"; echo; }
  [ -n "$FUPS" ] && { echo "## Follow-up Questions"; echo; cat "$FUPS"; echo; }
  echo
  echo "> **Disclaimer:** Not medical advice. For discussion with a licensed clinician."
} > "$OUTMD"

# light CSS for printing
CSS=outputs/pandoc_print.css
cat > "$CSS" <<'CSS'
body { font-family: -apple-system, Roboto, "Segoe UI", Arial, sans-serif; line-height: 1.4; margin: 24px; }
h1, h2, h3 { margin-top: 1.2em; margin-bottom: 0.5em; }
code, pre { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
hr { border: 0; border-top: 1px solid #ddd; margin: 1.2em 0; }
blockquote { color: #444; border-left: 4px solid #ddd; padding-left: 12px; }
CSS

# Need pandoc: install if missing hint
if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc not found. Install with: pkg install -y pandoc"
  exit 1
fi

pandoc "$OUTMD" --from markdown --to html5 --standalone \
  --metadata title="Care Pack — Print Bundle" \
  --css "$CSS" -o "$OUTHTML"

./sync.sh
echo "✅ Print bundle saved & synced:"
echo " - $OUTMD"
echo " - $OUTHTML"
echo "Open the HTML in your browser → Share → Print → **Save as PDF**."
