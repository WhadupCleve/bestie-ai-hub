#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
TS=$(date -u +'%Y%m%d_%H%M%S')
OUT="backups/bestie_backup_${TS}.tar.gz"
tar \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='.env.sealed' \
  -czf "$OUT" \
  README.md LOCKED.md \
  boot.sh health.sh sync.sh status.sh status_pack.sh \
  bestie.py content_pack.sh care_pack.sh care_pdf.sh \
  outputs
echo "✅ Backup saved: $OUT"
