Bestie AI Hub — One-Command Restore (Mobile)

Fresh phone (Termux installed)
1) Storage permission:
   termux-setup-storage

2) Clone:
   pkg install -y git
   git clone https://github.com/WhadupCleve/bestie-ai-hub.git ~/bestie_ai
   cd ~/bestie_ai

3) Bootstrap:
   bash restore.sh

4) Add your API key:
   nano .env   # set PERPLEXITY_API_KEY=...

5) Quick test:
   . ~/.bashrc
   bboot
   bhealth
   bestie "hi"
   bstatus
