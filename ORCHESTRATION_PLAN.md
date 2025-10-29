# Orchestration Plan (v1 → v2)
v1 (Moto G, Perplexity-only): Intake → Doctor Brief → Follow-ups (Care Pack v0).
v2 (Laptop/Better phone): 10-role pipeline with Router, Fallbacks, and Safety Guard.

Roles:
1) Intake Redactor  2) Planner  3) Guideline Scout  4) Literature Scanner
5) Risk Auditor     6) Math/Stats  7) Summarizer  8) Patient Explainer
9) Citations Verifier  10) Safety Guard

Pattern: Fan-out → Verify → Reduce → Guard → Package (Doctor/Patient/Appendix)
Safety: No diagnoses. No directives. “Ask your clinician about…” phrasing only.

Data: PHI redaction first; consent line stored; trace + token cost logged.
Cost: Per-run caps; backoff/retry; provider fallbacks; graceful degradation.
