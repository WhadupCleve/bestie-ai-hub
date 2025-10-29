import os, sys, re, subprocess, shutil, requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv("PERPLEXITY_API_KEY","").strip()
MODEL   = os.getenv("PERPLEXITY_MODEL","sonar-pro").strip()

# --- GitHub env (optional for -deploy) ---
GH_USER   = os.getenv("GITHUB_USERNAME","").strip()
GH_EMAIL  = os.getenv("GITHUB_EMAIL","").strip()
GH_TOKEN  = os.getenv("GITHUB_TOKEN","").strip()
GH_REPO   = os.getenv("GITHUB_REPO","").strip()           # e.g. user/my-repo
GH_BRANCH = os.getenv("GIT_BRANCH","main").strip()

def sh(cmd, cwd=None):
    """Run a shell command and return (code, stdout+stderr)."""
    try:
        out = subprocess.check_output(cmd, shell=True, cwd=cwd, stderr=subprocess.STDOUT, text=True)
        return 0, out.strip()
    except subprocess.CalledProcessError as e:
        return e.returncode, (e.output or "").strip()

def ask_perplexity(messages, temperature=0.4, timeout=60):
    if not API_KEY:
        return "❌ Missing PERPLEXITY_API_KEY in .env"
    url = "https://api.perplexity.ai/chat/completions"
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    payload = {"model": MODEL, "messages": messages, "temperature": temperature, "stream": False}
    r = requests.post(url, headers=headers, json=payload, timeout=timeout)
    if r.status_code != 200:
        return f"❌ HTTP {r.status_code}: {r.text[:1000]}"
    j = r.json()
    content = j.get("choices",[{}])[0].get("message",{}).get("content","")
    content = re.sub(r"\d+", "", content).strip()
    return content

def normal_chat(user_text: str) -> str:
    system = "You are Bestie 🐼 — precise, helpful, and casual. Do not include citation markers."
    msgs = [{"role":"system","content":system},{"role":"user","content":user_text}]
    return ask_perplexity(msgs, temperature=0.4)

def bio_mode(user_brief: str) -> str:
    system = ("You write public-facing bios in a mythic/oracle tone—calm, inevitable, elite. "
              "Output clean third-person prose only (no lists, quotes, emojis, or citations). "
              "Target length: 130–180 words in 2–3 compact paragraphs. "
              "Center on mobile-native AI systems, multi-model orchestration, and API-first engineering.")
    prompt = f"""
Write a third-person bio for Matthew David Cargnel (aka Cleveland/Cleve).
Profile: underground-leaning AI builder who engineered multi-agent orchestration from mobile-only infrastructure.
Show credibility without hype; avoid buzzword stuffing. Mention: Hugging Face Spaces (mobile), Termux Python CLI, API integrations (Perplexity first; OpenAI/Groq/Mistral when available), GitHub/HF workflow, and operational discipline.
No quotes, no headings, no emojis, no bullet points. Two or three short paragraphs, 130–180 words.
Close on forward momentum (shipping stable systems, adding providers later).
User brief to weave in: {user_brief.strip()}
""".strip()
    msgs = [{"role":"system","content":system},{"role":"user","content":prompt}]
    text = ask_perplexity(msgs, temperature=0.3)
    text = re.sub(r"\*+", "", text).strip()
    return text

def yt_mode(user_brief: str) -> str:
    system = ("You generate short-form video copy that converts. "
              "Output ONLY plain text blocks labeled exactly: Title:, Hook:, Captions:. "
              "Titles: 8–12 words, punchy, no emojis. "
              "Hook: <=12 words, must stop scroll. "
              "Captions: 3 lines, each <100 chars, no hashtags unless user asked.")
    prompt = f"""
Create a high-converting short-form package for this brief:

{user_brief.strip()}

Return exactly:
Title: <one line>
Hook: <one line>
Captions:
- <line 1>
- <line 2>
- <line 3>
""".strip()
    msgs = [{"role":"system","content":system},{"role":"user","content":prompt}]
    return ask_perplexity(msgs, temperature=0.5)

def plan_mode(user_brief: str) -> str:
    system = ("You are an operator-grade planner. Output a 7-day Tactical Elite mission brief. "
              "Format strictly as: OPERATION <NAME> // OVERVIEW (one line), then DAY n // OBJECTIVE: ... "
              "Under each DAY: TOOLS: ..., TASKS: (3 short lines prefixed by '-') , MEASURABLE: one short metric. "
              "Tone: concise, commanding, practical. No emojis or quotes.")
    op_overview = f"Tactical Elite 7-day plan — focus: {user_brief.strip()}"
    prompt = f"""
OPERATION: OPERATION-PLAN
OVERVIEW: {op_overview}

Now produce DAYS 1 through 7. For each day follow:
DAY <n> // OBJECTIVE: <one sentence>
TOOLS: <comma-separated tools to use>
TASKS:
- <task 1>
- <task 2>
- <task 3>
MEASURABLE: <single measurable metric>

Stack: Termux Python, Hugging Face Spaces (mobile), GitHub, PERPLEXITY API, lightweight local tooling.
""".strip()
    msgs = [{"role":"system","content":system},{"role":"user","content":prompt}]
    return ask_perplexity(msgs, temperature=0.25)

def deploy_mode(message: str) -> str:
    """
    Auto git-add/commit/push this project to GitHub using .env creds.
    Safe for mobile: creates repo if needed, sets remote if missing.
    """
    # 0) basic checks
    if shutil.which("git") is None:
        return "❌ git not installed. Run: pkg install -y git"
    if not GH_REPO:
        return "❌ GITHUB_REPO missing in .env (e.g., user/my-repo)."
    if not GH_TOKEN or not GH_USER:
        return "❌ GITHUB_TOKEN or GITHUB_USERNAME missing in .env."

    repo_dir = os.getcwd()
    log = []

    # 1) init if needed
    if not os.path.isdir(os.path.join(repo_dir, ".git")):
        code, out = sh("git init", cwd=repo_dir)
        log += [f"git init -> {code}", out]

    # 2) config user
    if GH_EMAIL:
        sh(f'git config user.email "{GH_EMAIL}"', cwd=repo_dir)
    sh(f'git config user.name "{GH_USER}"', cwd=repo_dir)

    # 3) set remote if missing
    code, remotes = sh("git remote -v", cwd=repo_dir)
    if "origin" not in (remotes or ""):
        remote_url = f"https://{GH_USER}:{GH_TOKEN}@github.com/{GH_REPO}.git"
        code, out = sh(f'git remote add origin "{remote_url}"', cwd=repo_dir)
        log += [f"add origin -> {code}", out]
    else:
        # ensure https with token (won't echo token)
        pass

    # 4) add & commit
    sh("git add -A", cwd=repo_dir)
    stamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    commit_msg = message.strip() or f"deploy: mobile push at {stamp}"
    code, out = sh(f'git commit -m "{
cd ~/bestie_ai
cd ~/bestie_ai
cat > bestie.py << 'PY'
import os, sys, re, subprocess, shutil, requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv("PERPLEXITY_API_KEY","").strip()
MODEL   = os.getenv("PERPLEXITY_MODEL","sonar-pro").strip()

# --- GitHub deploy config (optional; used by -deploy) ---
GH_USER   = os.getenv("GITHUB_USERNAME","").strip()
GH_EMAIL  = os.getenv("GITHUB_EMAIL","").strip()
GH_TOKEN  = os.getenv("GITHUB_TOKEN","").strip()
GH_REPO   = os.getenv("GITHUB_REPO","").strip()      # e.g. youruser/bestie-ai-hub
GH_BRANCH = os.getenv("GIT_BRANCH","main").strip()

def ask_perplexity(messages, temperature=0.4, timeout=60):
    if not API_KEY:
        return "❌ Missing PERPLEXITY_API_KEY in .env"
    url = "https://api.perplexity.ai/chat/completions"
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    payload = {"model": MODEL, "messages": messages, "temperature": temperature, "stream": False}
    r = requests.post(url, headers=headers, json=payload, timeout=timeout)
    if r.status_code != 200:
        return f"❌ HTTP {r.status_code}: {r.text[:1000]}"
    j = r.json()
    content = j.get("choices",[{}])[0].get("message",{}).get("content","")
    return re.sub(r"\[\d+\]", "", content or "").strip()

def normal_chat(user_text: str) -> str:
    msgs = [
        {"role":"system","content":"You are Bestie 🐼 — precise, helpful, casual. No citation markers."},
        {"role":"user","content":user_text}
    ]
    return ask_perplexity(msgs, temperature=0.4)

def bio_mode(brief: str) -> str:
    sysmsg = ("You write public-facing bios in a mythic/oracle tone—calm, inevitable, elite. "
              "Output clean third-person prose only (no lists, quotes, emojis, or citations). "
              "130–180 words in 2–3 compact paragraphs. Emphasize mobile-native AI systems, "
              "multi-model orchestration, API-first engineering.")
    prompt = f"""
Write a third-person bio for Matthew David Cargnel (aka Cleveland/Cleve).
Profile: underground-leaning AI builder who engineered multi-agent orchestration from mobile-only infrastructure.
Mention: Hugging Face Spaces (mobile), Termux Python CLI, API integrations (Perplexity first; OpenAI/Groq/Mistral when available),
GitHub/HF workflow, operational discipline. No quotes/emoji/bullets. Close on shipping stable systems.
User brief: {brief.strip()}
""".strip()
    txt = ask_perplexity([{"role":"system","content":sysmsg},{"role":"user","content":prompt}], temperature=0.3)
    return re.sub(r"\*+","",txt).strip()

def yt_mode(brief: str) -> str:
    sysmsg = ("You generate short-form video copy that converts. "
              "Output ONLY: Title:, Hook:, Captions:. Titles 8–12 words, no emojis. "
              "Hook <=12 words. Captions: 3 lines, each <100 chars, no hashtags unless asked.")
    prompt = f"""
Create a high-converting short-form package for this brief:

{brief.strip()}

Return exactly:
Title: <one line>
Hook: <one line>
Captions:
- <line 1>
- <line 2>
- <line 3>
""".strip()
    return ask_perplexity([{"role":"system","content":sysmsg},{"role":"user","content":prompt}], temperature=0.5)

def plan_mode(brief: str) -> str:
    sysmsg = ("You are an operator-grade planner. Output a 7-day Tactical Elite mission brief. "
              "Format strictly: OPERATION: OPERATION-PLAN / OVERVIEW: <one line> then DAY n // OBJECTIVE: ... "
              "Then TOOLS: <csv>; TASKS: - <1> - <2> - <3>; MEASURABLE: <one metric>. "
              "Tone concise, commanding, practical. No emojis or quotes.")
    overview = f"Tactical Elite 7-day plan — focus: {brief.strip()}"
    prompt = f"""
OPERATION: OPERATION-PLAN
OVERVIEW: {overview}

Produce DAYS 1..7. Each day:
DAY <n> // OBJECTIVE: <one sentence>
TOOLS: <csv tools>
TASKS:
- <task 1>
- <task 2>
- <task 3>
MEASURABLE: <single metric>

Stack focus: Termux Python, Hugging Face Spaces (mobile), GitHub, PERPLEXITY API, lightweight local tooling.
""".strip()
    return ask_perplexity([{"role":"system","content":sysmsg},{"role":"user","content":prompt}], temperature=0.25)

def sh(cmd, cwd=None):
    try:
        out = subprocess.check_output(cmd, shell=True, cwd=cwd, stderr=subprocess.STDOUT, text=True)
        return 0, out.strip()
    except subprocess.CalledProcessError as e:
        return e.returncode, (e.output or "").strip()

def deploy_mode(message: str) -> str:
    if shutil.which("git") is None:
        return "❌ git not installed. Run: pkg install -y git"
    if not GH_REPO:
        return "❌ GITHUB_REPO missing in .env (e.g., youruser/bestie-ai-hub)"
    if not GH_TOKEN or not GH_USER:
        return "❌ GITHUB_TOKEN or GITHUB_USERNAME missing in .env"

    repo_dir = os.getcwd()
    log = []

    # init if needed
    if not os.path.isdir(os.path.join(repo_dir, ".git")):
        c,o = sh("git init"); log += [f"git init -> {c}", o]

    # user config
    if GH_EMAIL: sh(f'git config user.email "{GH_EMAIL}"')
    sh(f'git config user.name "{GH_USER}"')

    # set remote if missing
    c, rem = sh("git remote -v")
    if "origin" not in (rem or ""):
        remote_url = f"https://{GH_USER}:{GH_TOKEN}@github.com/{GH_REPO}.git"
        c,o = sh(f'git remote add origin "{remote_url}"'); log += [f"add origin -> {c}", o]

    # add & commit
    sh("git add -A")
    stamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    msg = (message or "").strip() or f"deploy: mobile push at {stamp}"
    c,o = sh(f'git commit -m "{msg}"')
    if c != 0 and "nothing to commit" in (o or "").lower():
        log.append("Nothing to commit; working tree clean.")
    else:
        log += [f"commit -> {c}", o]

    # push
    c,o = sh(f"git push -u origin {GH_BRANCH}")
    log += [f"push -> {c}", o]

    # redact token
    safe = "\n".join(log).replace(GH_TOKEN, "****")
    return "✅ Deploy log:\n" + safe

def main():
    if len(sys.argv) <= 1:
        print('Usage:\n  bestie "message"\n  bestie -bio "context"\n  bestie -yt "video brief"\n  bestie -plan "focus"\n  bestie -deploy "commit message"')
        return
    mode = sys.argv[1]
    if mode == "-bio":
        print(bio_mode(" ".join(sys.argv[2:]).strip() or "Mobile-only HF Spaces + Termux; multi-model orchestration.")); return
    if mode == "-yt":
        print(yt_mode(" ".join(sys.argv[2:]).strip() or "Ohio State hype; 12–20s vertical; fierce; no hashtags.")); return
    if mode == "-plan":
        print(plan_mode(" ".join(sys.argv[2:]).strip() or "Harden mobile multi-model orchestration with reproducible wins.")); return
    if mode == "-deploy":
        print(deploy_mode(" ".join(sys.argv[2:]))); return
    print(normal_chat(" ".join(sys.argv[1:])))
if __name__ == "__main__":
    main()
