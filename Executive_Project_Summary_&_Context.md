# Executive Project Summary & Context (For New Chat Session)

## 🎯 Project Goal & Overview
An automated academic evaluation pipeline and web UI that simulates a strict, experienced dissertation examiner. It parses user-submitted dissertations (PDF or raw text), performs multi-stage LLM analysis via Google Vertex AI (Gemini 2.5 Pro & Flash), and returns calibrated, examiner-level feedback with a 3-tier submission verdict.

---

## 🏗️ Architecture & Stack
1. **Frontend / Web UI (`dissertation-ui.html` + `start-ui.ps1`)**:
   - Built with Vanilla HTML/CSS (Glassmorphic dark design) and JS.
   - Dual-mode input: Paste raw text OR drag-and-drop machine-readable PDFs.
   - Served locally via Python HTTP server on port 8080 (`powershell -ExecutionPolicy Bypass -File .\start-ui.ps1`).
   - Async multi-stage progress tracker and responsive feedback dashboard (Supervisor Verdict, Priority Action List, Examiner Risk, Collapsible Section-by-Section Issue Cards).

2. **Backend Engine (`Triagent-multiinput.json` in n8n)**:
   - **Input Router & Normalizer:** Handles dual-path routing (PDF extraction vs direct text JSON body).
   - **Agent 1 — Macro Analyser (`gemini-2.5-pro`):** Extracts global structure (title, thesis statement, argument chain, methodology, key variables, section list) without evaluating.
   - **Section Splitter & Sub-Loop:** Line-anchored regex heading splitter; loops over sections with `SplitInBatches`.
   - **Agent 2 — Section Analyser (`gemini-2.5-flash`):** Sequentially evaluates each section for Critical, Major, and Minor issues using strict examiner severity criteria.
   - **Aggregate & Filter:** Groups section feedback and filters by `run_id` timestamp to prevent cross-run data contamination.
   - **Merge & Calibration Engine:** Evaluates holistic quality against a 5-question test (`Underdeveloped ≠ Absent` rule).
   - **Agent 3 — Verdict Generator (`gemini-2.5-pro`):** Generates 3-tier verdict (`READY FOR SUBMISSION`, `CONDITIONAL`, `NOT READY`), priority action list, and risk assessment.
   - **Final Report Assembler:** Formats unified text report, applies regex status matcher to guarantee badge/narrative consistency.
   - **PostgreSQL Logger & Webhook Response:** Logs execution metadata to Postgres and returns full report to Web UI.

---

## ⚖️ Key Calibration & System Rules
- **Underdeveloped ≠ Absent:** Thin literature reviews (3–5 sources), short discussions, or missing assumption tests trigger `CONDITIONAL`, **never** `NOT READY`.
- **Hard Override:** If core methodology, logic chain, and statistical tests are sound (scoring 4/5 on holistic assessment), `NOT READY` is strictly forbidden.
- **Reference Count Rule:** Reference count alone never justifies a `NOT READY` verdict.
- **Strict Examiner Severity:** Critical issues are reserved strictly for fundamental failures that would cause an examiner to write "FAIL" or "REFER" on a mark sheet.
- **Badge/Narrative Consistency:** Exact status matcher regex enforces 100% agreement between UI status badge and narrative opening.

---

## 📁 Repository Files (`Final_Prototype/`)
- `dissertation-ui.html` — Glassmorphism Web Dashboard.
- `start-ui.ps1` — PowerShell server launcher script (`http://localhost:8080/dissertation-ui.html`).
- `Triagent-multiinput.json` — Production n8n Workflow JSON with full calibration rules & CORS support.
- `README.md` — Complete repository documentation and setup guide.
- `Executive_Project_Summary_&_Context.md` — Context file for starting new AI chat sessions.
