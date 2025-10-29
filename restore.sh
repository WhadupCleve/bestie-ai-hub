#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "🔧 RESTORE: Initializing fresh mobile system..."

# 1) Termux permissions (safe if already granted)
termux-setup-storage || true

# 2) Base deps
pkg update -y
pkg install -y python git nano tmux coreutils zip

# 3) Venv + pip
python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install requests


# 4) Add core aliases (point to existing scripts)
for P in "bboot:boot.sh" "bhealth:health.sh" "bstatus:status.sh" "bsync:sync.sh"; do
  A="${P%%:*}"; F="${P##*:}"
  grep -qxF "alias $A=\"~/bestie_ai/$F\"" ~/.bashrc || echo "alias $A=\"~/bestie_ai/$F\"" >> ~/.bashrc
done

echo "✅ restore.sh done. Run:  . ~/.bashrc  &&  bboot"
