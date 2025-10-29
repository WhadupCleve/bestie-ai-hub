#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
mkdir -p outputs

DAYS="${1:-7}"
CSV="outputs/care_notes.csv"
if [ ! -f "$CSV" ]; then
  echo "No notes yet. Add one with: bcare_note \"...\""
  exit 1
fi

TS=$(date -u +'%Y%m%d_%H%M%S')
OUT="outputs/care_summary_${TS}.md"

# Use Python to filter notes by DAYS and render markdown
python - <<'PY' "$CSV" "$DAYS" "$OUT"
import sys, csv, datetime as dt, os
csv_path, days_str, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
days = int(days_str)
now = dt.datetime.utcnow()
cut = now - dt.timedelta(days=days)

rows = []
with open(csv_path, newline='', encoding='utf-8') as f:
    r = csv.DictReader(f)
    for row in r:
        ts = row.get("timestamp","")
        note = row.get("note","").strip()
        # format: "YYYY-mm-dd HH:MM:SS UTC"
        try:
            # Strip trailing " UTC"
            ts_clean = ts.replace(" UTC","")
            t = dt.datetime.strptime(ts_clean, "%Y-%m-%d %H:%M:%S")
        except Exception:
            continue
        if t >= cut:
            rows.append((t, note))

rows.sort(key=lambda x: x[0])

with open(out_path, "w", encoding="utf-8") as out:
    out.write(f"# Symptom Summary — Last {days} Days\n\n")
    if not rows:
        out.write("_No symptom notes in this window._\n")
    else:
        out.write("| Date (UTC) | Note |\n|---|---|\n")
        for t,n in rows:
            tstr = t.strftime("%Y-%m-%d %H:%M")
            n = n.replace("|","\\|")
            out.write(f"| {tstr} | {n} |\n")
    out.write("\n> Not medical advice — bring to a licensed clinician.\n")
print(out_path)
PY

echo "✅ Summary created: $OUT"
