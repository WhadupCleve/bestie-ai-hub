import os, time, json, hashlib, requests
from datetime import datetime

# -------- env --------
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

OPENAI_KEY     = os.getenv("OPENAI_API_KEY", "")
ANTHROPIC_KEY  = os.getenv("ANTHROPIC_API_KEY", "")
DEEPSEEK_KEY   = os.getenv("DEEPSEEK_API_KEY", "")

OPENAI_MODEL   = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
ANTHROPIC_MODEL= os.getenv("ANTHROPIC_MODEL", "claude-3-5-sonnet-latest")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")

os.makedirs("logs", exist_ok=True)

# -------- helpers --------
def _hash(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()

def log_run(payload: dict):
    stamp = datetime.now().strftime("%Y%m%d")
    with open(f"logs/{stamp}.jsonl", "a") as f:
        f.write(json.dumps(payload, ensure_ascii=False) + "\n")

def _post(url, headers, body, timeout=60):
    r = requests.post(url, headers=headers, json=body, timeout=timeout)
    r.raise_for_status()
    return r.json()

# -------- model wrappers (requests only, Termux-friendly) --------
def ask_openai(prompt: str, model: str = OPENAI_MODEL) -> str:
    url = "https://api.openai.com/v1/chat/completions"
    headers = {"Authorization": f"Bearer {OPENAI_KEY}"}
    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.6,
    }
    j = _post(url, headers, data)
    return j["choices"][0]["message"]["content"].strip()

def ask_anthropic(prompt: str, model: str = ANTHROPIC_MODEL) -> str:
    url = "https://api.anthropic.com/v1/messages"
    headers = {
        "x-api-key": ANTHROPIC_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
    }
    data = {
        "model": model,
        "max_tokens": 1024,
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": prompt}]}
        ],
        "temperature": 0.6,
    }
    j = _post(url, headers, data)
    # API returns a list of content blocks; pick text ones and join
    parts = [c.get("text","") for c in j.get("content",[]) if c.get("type")=="text"]
    return "\n".join(parts).strip()

def ask_deepseek(prompt: str, model: str = DEEPSEEK_MODEL) -> str:
    url = "https://api.deepseek.com/chat/completions"
    headers = {"Authorization": f"Bearer {DEEPSEEK_KEY}"}
    data = {
        "model": model,
        "messages": [{"role":"user", "content": prompt}],
        "temperature": 0.6,
    }
    j = _post(url, headers, data)
    return j["choices"][0]["message"]["content"].strip()

# -------- core pipeline: Claude -> DeepSeek -> OpenAI --------
def pipeline(user_input: str) -> dict:
    trace = []

    # 1) Draft (Claude)
    p1 = f"Draft a structured, clear answer for this request:\n\n{user_input}"
    r1 = ask_anthropic(p1)
    trace.append({"stage":"draft", "model":"anthropic", "input":p1, "output":r1})

    # 2) Critique/Improve Plan (DeepSeek)
    p2 = f"Critique and propose concrete improvements to the draft. Be specific:\n\n{r1}"
    r2 = ask_deepseek(p2)
    trace.append({"stage":"critique", "model":"deepseek", "input":p2, "output":r2})

    # 3) Final Polish (OpenAI)
    p3 = (
        "Integrate the critique into a final, polished answer. "
        "Use bullets for actions and a brief TL;DR at the end.\n\n"
        f"Draft:\n{r1}\n\nCritique:\n{r2}"
    )
    r3 = ask_openai(p3)
    trace.append({"stage":"final", "model":"openai", "input":p3, "output":r3})

    # log
    log_run({
        "ts": int(time.time()),
        "prompt": user_input,
        "trace": trace,
        "final": r3,
        "prompt_hash": _hash(user_input)
    })

    return {"final": r3, "trace": trace}

if __name__ == "__main__":
    print("🐼 Bestie AI Hub (CORE) — Claude → DeepSeek → OpenAI")
    print("Type your request and press Enter. Ctrl+C to quit.\n")
    while True:
        try:
            q = input("You: ").strip()
            if not q:
                continue
            res = pipeline(q)
            print("\n--- FINAL ---\n")
            print(res["final"])
            print("\n(Full trace saved in logs/)")
            print()
        except KeyboardInterrupt:
            print("\nBye! 🐼")
            break
        except Exception as e:
            print(f"[Error] {e}")
