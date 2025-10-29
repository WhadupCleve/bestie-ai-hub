#!/data/data/com.termux/files/usr/bin/python
# Auto-Orchestrator (mobile-safe) — Perplexity-first, multi-phase with retries
# Requires: PERPLEXITY_API_KEY and PERPLEXITY_MODEL in .env

import os, json, time, sys, textwrap, requests
from datetime import datetime

PPLX_KEY   = os.getenv("PERPLEXITY_API_KEY", "")
PPLX_MODEL = os.getenv("PERPLEXITY_MODEL", "sonar-pro")
PPLX_URL   = "https://api.perplexity.ai/chat/completions"

def _safe_print(s):  # avoid broken pipes
    try:
        sys.stdout.write(s + ("\n" if not s.endswith("\n") else ""))
        sys.stdout.flush()
    except BrokenPipeError:
        pass

def call_perplexity(messages, temperature=0.2, max_tokens=800, timeout=45, tries=3, backoff=2.0):
    if not PPLX_KEY:
        raise RuntimeError("❌ Missing PERPLEXITY_API_KEY in .env")

    headers = {
        "Authorization": f"Bearer {PPLX_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": PPLX_MODEL,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "top_p": 1.0,
    }
    last_err = None
    for attempt in range(1, tries+1):
        try:
            r = requests.post(PPLX_URL, headers=headers, data=json.dumps(payload), timeout=timeout)
            if r.status_code == 200:
                data = r.json()
                # OpenAI-compatible shape
                content = data["choices"][0]["message"]["content"]
                return content
            else:
                last_err = f"HTTP {r.status_code}: {r.text[:300]}"
        except Exception as e:
            last_err = str(e)
        time.sleep(backoff ** attempt * 0.5)
    raise RuntimeError(last_err or "unknown error")

SYS_PLANNER = """You are the Planner. Produce 3–6 crisp steps to answer the user's question using external knowledge if needed.
Return JSON with keys: steps (array of strings), warnings (array), focus (one-sentence).
No prose outside JSON.
"""

SYS_RESEARCHER = """You are the Researcher. For the given step, gather and condense the most relevant facts.
Return JSON with keys: bullet_points (array of short factual bullets), notes (array), uncertainties (array).
No prose outside JSON.
"""

SYS_SYNTHESIZER = """You are the Synthesizer. Merge all step facts into a single, clean final answer for a non-technical reader.
Keep it concise, structured, and practical. If there are uncertainties, acknowledge them briefly.
Output plain text only.
"""

def plan(question):
    msg = [
        {"role":"system", "content": SYS_PLANNER},
        {"role":"user", "content": question}
    ]
    raw = call_perplexity(msg, temperature=0.1, max_tokens=600)
    try:
        j = json.loads(raw)
    except Exception:
        # fallback: try extracting JSON block
        start = raw.find("{")
        end   = raw.rfind("}")
        j = json.loads(raw[start:end+1]) if start!=-1 and end!=-1 else {"steps":[raw], "warnings":[], "focus":""}
    steps = [s.strip() for s in j.get("steps", []) if isinstance(s, str) and s.strip()]
    return {
        "steps": steps[:6],
        "warnings": j.get("warnings", []),
        "focus": j.get("focus", "")
    }

def research(step_text):
    msg = [
        {"role":"system", "content": SYS_RESEARCHER},
        {"role":"user", "content": step_text}
    ]
    raw = call_perplexity(msg, temperature=0.2, max_tokens=700)
    try:
        j = json.loads(raw)
    except Exception:
        start = raw.find("{"); end = raw.rfind("}")
        j = json.loads(raw[start:end+1]) if start!=-1 and end!=-1 else {"bullet_points":[raw], "notes":[], "uncertainties":[]}
    bullets = j.get("bullet_points", [])
    notes = j.get("notes", [])
    uncertainties = j.get("uncertainties", [])
    return {"bullets": bullets, "notes": notes, "uncertainties": uncertainties}

def synthesize(question, all_findings):
    merged = []
    for i, blk in enumerate(all_findings, 1):
        merged.append(f"Step {i} findings:")
        for b in blk["bullets"][:6]:
            merged.append(f"- {b}")
    prompt = "\n".join(merged[:100])
    msg = [
        {"role":"system", "content": SYS_SYNTHESIZER},
        {"role":"user", "content": f"Question: {question}\n\nFindings:\n{prompt}"}
    ]
    text = call_perplexity(msg, temperature=0.25, max_tokens=900)
    return text

def orchestrate(question):
    t0 = time.time()
    plan_obj = plan(question)
    steps = plan_obj["steps"]
    findings = []
    for s in steps:
        findings.append(research(s))
    final = synthesize(question, findings)
    out = {
        "question": question,
        "planned_steps": steps,
        "warnings": plan_obj.get("warnings", []),
        "final_answer": final.strip(),
        "meta": {
            "model": PPLX_MODEL,
            "duration_s": round(time.time()-t0, 2),
            "timestamp_utc": datetime.utcnow().isoformat() + "Z"
        }
    }
    return out

def main():
    if len(sys.argv) < 2:
        _safe_print("Usage: python orchestrator.py \"your question\"")
        sys.exit(1)
    q = " ".join(sys.argv[1:]).strip()
    result = orchestrate(q)
    _safe_print("\n=== FINAL ANSWER ===\n" + result["final_answer"] + "\n")
    _safe_print("=== PLAN ===")
    for i,s in enumerate(result["planned_steps"],1):
        _safe_print(f"{i}. {s}")
    if result["warnings"]:
        _safe_print("\nWarnings: " + "; ".join(result["warnings"]))
    _safe_print("\n(meta: " + json.dumps(result["meta"]) + ")")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        _safe_print(f"❌ Orchestrator error: {e}")
        sys.exit(2)
