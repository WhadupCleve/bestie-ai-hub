#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai

# Defaults for you, but you can just press Enter to accept them
read -p "GitHub username [WhadUpCleve]: " U; U=${U:-WhadUpCleve}
read -p "GitHub email [m_cargnel@yahoo.com]: " E; E=${E:-m_cargnel@yahoo.com}
read -p "Repo name [bestie-ai-hub]: " R; R=${R:-bestie-ai-hub}
read -s -p "Paste GitHub token: " T; echo
read -p "Perplexity model [sonar-pro]: " M; M=${M:-sonar-pro}

# Git identity + credential store
git config --global user.name "$U"
git config --global user.email "$E"
git config --global credential.helper store

# .env (Perplexity + GitHub only)
cat > .env <<EOF
PERPLEXITY_API_KEY=
PERPLEXITY_MODEL=$M
GITHUB_USERNAME=$U
GITHUB_EMAIL=$E
GITHUB_TOKEN=$T
GITHUB_REPO=$U/$R
GIT_BRANCH=main
EOF

# Save credentials (so pushes don’t ask again)
printf "https://%s:%s@github.com\n" "$U" "$T" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Init repo if needed and set remote
[ -d .git ] || git init
git branch -M main || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$U/$R.git" || true

echo
echo "✅ Setup complete."
echo "➡️  If the repo doesn't exist yet, create it EMPTY (no README) at:"
echo "   https://github.com/$U/$R"
echo "➡️  Then push:"
echo "   git add -A && git commit -m 'first push' && git push -u origin main"
