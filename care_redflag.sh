#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
mkdir -p outputs
TS=$(date -u +'%Y-%m-%d %H:%M:%S UTC')
TXT="$(echo "$*" | tr '[:upper:]' '[:lower:]')"
if [ -z "$TXT" ]; then
  echo "Usage: bcare_redflag \"symptoms / situation\""
  exit 1
fi

ESCALATE=0
WHY=()

# --- hard red flags (any one triggers escalate) ---
match_any () { echo "$TXT" | grep -Eiq "$1"; }

# chest pain / SOB / heart
match_any 'chest (pain|tight(ness)?)' && { ESCALATE=1; WHY+=("chest pain/tightness"); }
match_any '(short(ness)? of breath|trouble breathing|cannot breathe|wheez(e|ing))' && { ESCALATE=1; WHY+=("shortness of breath"); }
match_any '(faint(ing)?|passed out|syncope|confusion.*sudden)' && { ESCALATE=1; WHY+=("fainting/confusion"); }

# stroke FAST
match_any '(face droop|uneven smile|slurred speech|cannot speak|one[- ]?sided weakness|sudden numbness|sudden severe headache|vision loss|arm weakness)' && { ESCALATE=1; WHY+=("possible stroke signs"); }

# allergic reaction
match_any '(swelling.*(face|lips|tongue|throat)|hive(s)?|anaphylaxis|throat tight|difficulty breathing)' && { ESCALATE=1; WHY+=("possible severe allergy"); }

# infection / sepsis signals
match_any '(fever.*(103|104)|rigor(s)?|chills.*severe|stiff neck|neck stiffness|meningitis)' && { ESCALATE=1; WHY+=("high fever/meningitis concern"); }

# bleeding / trauma
match_any '(uncontrolled bleeding|bleeding won.t stop|head injury|severe burn|deep wound)' && { ESCALATE=1; WHY+=("bleeding/trauma"); }

# dehydration / unable to keep fluids
match_any '(can.not keep (anything|fluids) down|no urination|very little urine|severe dehydration)' && { ESCALATE=1; WHY+=("severe dehydration"); }

# liver / jaundice
match_any '(yellow(ing)? (eyes|skin)|jaundice)' && { ESCALATE=1; WHY+=("possible liver issue (jaundice)"); }

# rhabdomyolysis concern (esp. statin history)
if echo "$TXT" | grep -Eiq 'dark urine' && echo "$TXT" | grep -Eiq '(muscle (pain|weakness|ache|cramp))'; then
  ESCALATE=1; WHY+=("dark urine + muscle symptoms (possible rhabdo)");
fi

# kidney concern
match_any '(no urine|very little urine|flank pain|severe back pain.*kidney)' && { ESCALATE=1; WHY+=("possible kidney issue"); }

# pregnancy emergency cues
match_any '(pregnan|pregnancy).* (bleeding|severe pain|severe headache|vision)' && { ESCALATE=1; WHY+=("pregnancy-related red flag"); }

# conservative combos: any two moderate issues => escalate
MOD=0
match_any '(persistent vomiting|cannot eat|dizzy|lightheaded|palpitations|new severe pain|worst headache)' && MOD=$((MOD+1))
match_any '(blood in (stool|urine|vomit)|black tarry stool)' && MOD=$((MOD+1))
[ $MOD -ge 2 ] && { ESCALATE=1; WHY+=("multiple concerning symptoms"); }

# default conservative bias: if keywords like "worse" + "new" show up, lean escalate
if echo "$TXT" | grep -Eiq '\b(new|sudden|worsen(ing)?|severe)\b' && echo "$TXT" | grep -Eiq '\b(pain|weakness|confusion|breath|bleed|fever)\b'; then
  ESCALATE=1; WHY+=("sudden/worsening concerning symptom");
fi

LOG=outputs/care_redflag_log.tsv
[ -f "$LOG" ] || echo -e "timestamp\tinput\tdecision\treasons" > "$LOG"

if [ $ESCALATE -eq 1 ]; then
  REASONS=$(IFS='; '; echo "${WHY[*]}")
  echo -e "$TS\t$TXT\tESCALATE\t$REASONS" >> "$LOG"
  cat <<TXT
🚨 **ESCALATE NOW** — symptoms could indicate a serious condition.
Reasons: $REASONS

**What to do now (general guidance, not medical advice):**
- If severe or rapidly worsening: consider calling local emergency services.
- Otherwise: seek urgent evaluation (urgent care / ER) and bring your meds/supplement list and recent labs.

_Not medical advice. Use judgment and local emergency resources._
TXT
else
  echo -e "$TS\t$TXT\tMONITOR\t-" >> "$LOG"
  cat <<TXT
✅ **Monitor & Follow Up** — no immediate hard red flags detected.
- Document symptoms with \`bcare_note "...\`\`
- If anything worsens, new symptoms appear, or you feel unsafe: escalate.

_Not medical advice. If in doubt, escalate._
TXT
fi
