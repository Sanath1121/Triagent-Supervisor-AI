# Dissertation Supervisor AI — Final Prototype & Server

An end-to-end AI-powered academic evaluation system built with **n8n**, **Google Vertex AI (Gemini 2.5 Pro & Flash)**, **PostgreSQL**, and a modern **Web UI**.

The system acts as a strict, experienced dissertation examiner—parsing academic manuscripts, evaluating individual sections sequentially, and generating calibrated, examiner-level feedback with a 3-tier submission verdict.

---

## 🏛️ System Architecture

```
[ Web UI / PDF Upload ] ──(HTTP POST Webhook)──► [ n8n Workflow ]
                                                      │
 ┌────────────────────────────────────────────────────┴────────────────────────────────────────────────────┐
 │                                                                                                         │
 ▼                                                                                                         ▼
[ Input Router & Normalizer ]                                                                     [ PDF Extractor ]
 │                                                                                                         │
 └────────────────────────────────────────────────────┬────────────────────────────────────────────────────┘
                                                      │
                                                      ▼
                                         [ Code: Input Validator ]
                                                      │
                                                      ▼
                                       [ Agent 1: Macro Analyser ] ◄── (Gemini 2.5 Pro)
                                      (Extracts Title, Thesis, Chain,
                                       Methodology & Section Index)
                                                      │
                                                      ▼
                                         [ Code: Section Splitter ]
                                                      │
                                                      ▼
                                     [ Loop: SplitInBatches Sub-routine ]
                                                      │
                                                      ▼
                                      [ Agent 2: Section Analyser ] ◄── (Gemini 2.5 Flash)
                                     (Evaluates Section for Critical,
                                      Major, & Minor Examiner Issues)
                                                      │
                                                      ▼
                                    [ Aggregate & Contamination Filter ]
                                                      │
                                                      ▼
                                        [ Merge & Calibration Engine ]
                                      (Enforces 5-Question Holistic
                                       Rule & Underdeveloped ≠ Absent)
                                                      │
                                                      ▼
                                      [ Agent 3: Verdict Generator ] ◄── (Gemini 2.5 Pro)
                                     (Generates Final Verdict, Action
                                      Items, & Risk Assessment)
                                                      │
                                                      ▼
                                       [ Code: Report Assembler ]
                                     (Structured Regex Parser & Matcher)
                                                      │
                                                      ▼
                                        [ PostgreSQL Logger & Webhook ]
                                                      │
                                                      ▼
                                            [ Web UI Dashboard ]
```

---

## 🚀 Key Features

1. **Dual-Mode Web UI (`dissertation-ui.html`)**:
   - **Direct Text Input** or **Drag-and-Drop PDF Upload** (with auto-extraction).
   - Real-time multi-stage progress tracking (Macro Analysis ➔ Section Review ➔ Verdict Assembly).
   - Glassmorphism UI displaying 3-Tier Status Badges, Supervisor Verdict, Priority Action List, Examiner Risk Assessment, and collapsible section-by-section issue breakdowns.
   - One-click report download (`.txt`).

2. **Tri-Agent Multi-Stage Analysis**:
   - **Macro Analyser (Gemini 2.5 Pro)**: Maps global thesis structure without pre-evaluating.
   - **Section Analyser (Gemini 2.5 Flash)**: Sequentially reviews section-by-section with running context passing.
   - **Verdict Generator (Gemini 2.5 Pro)**: Synthesizes holistic findings into supervisor-level recommendations.

3. **Strict Examiner Calibration Rules**:
   - **3-Tier Verdict System**: `READY FOR SUBMISSION` | `CONDITIONAL` | `NOT READY`.
   - **Underdeveloped ≠ Absent Rule**: Thin literature reviews (3–5 sources), short discussions, or missing assumption tests trigger `CONDITIONAL`, **never** `NOT READY`.
   - **Hard Override**: If core methodology, logic chain, and statistical tests are sound (scoring 4/5 on holistic questions), `NOT READY` is strictly forbidden.
   - **Reference Count Protection**: Citation count alone cannot force a `NOT READY` verdict.
   - **Data Contamination Prevention**: Stamped `run_id` ensures multi-user concurrency without cross-talk.
   - **Regex Status Matcher**: Guarantees 100% agreement between badge color and narrative verdict text.

---

## 📁 Repository Structure

```
Final_Prototype/
├── dissertation-ui.html      # Glassmorphism Web Interface
├── start-ui.ps1              # PowerShell Web Server Launcher
├── Triagent-multiinput.json  # Master n8n Workflow JSON
└── README.md                 # Project Documentation
```

---

## 🛠️ Quick Start Guide

### Prerequisites

1. **Python 3.x** installed and added to `PATH`.
2. **n8n** instance running (Docker or Local CLI).
3. **Google Vertex AI / Gemini API Credentials** configured in n8n.
4. **PostgreSQL** database (Optional, workflow continues on error if omitted).

### 1. Enable CORS in n8n (Required for Local UI)

If running n8n via Docker, add this environment variable in `docker-compose.yml`:
```yaml
environment:
  - N8N_CORS_ALLOW_ORIGIN=*
```
Then restart n8n:
```bash
docker compose restart
```

### 2. Import Workflow into n8n

1. Open n8n (`http://localhost:5678`).
2. Go to **Workflows ➔ Import from File**.
3. Select `Triagent-multiinput.json`.
4. Link your **Google Vertex AI** credentials to the three model nodes (`Macro Analyser`, `Section Analyser`, `Verdict Generator`).
5. Save and activate the workflow (or use the test webhook URL).

### 3. Launch Web Server & UI

Open PowerShell in the `Final_Prototype` directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-ui.ps1
```

This will automatically start a local HTTP server on port `8080` and open `http://localhost:8080/dissertation-ui.html` in your default browser.

---

## 📊 Database Schema (PostgreSQL)

If using the PostgreSQL logging node, initialize your database table with:

```sql
CREATE TABLE IF NOT EXISTS dissertation_reviews (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    submission_status VARCHAR(50) NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    full_report TEXT NOT NULL
);
```

---

## 🧪 Validated Test Benchmarks

| Test Paper | Description | Expected Verdict | Workflow Verdict | Status |
|---|---|---|---|---|
| **Paper 1 (Social Media)** | Good methodology, thin literature (5 refs) | `CONDITIONAL` | `CONDITIONAL` | ✅ Pass |
| **Paper 2 (Remote Work)** | Valid ANOVA & Tukey tests, 2-paragraph discussion | `CONDITIONAL` | `CONDITIONAL` | ✅ Pass |
| **Paper 3 (Breakfast)** | n=10 friends via text, no stats, zero refs | `NOT READY` | `NOT READY` | ✅ Pass |

---

## 📝 License

Distributed under the MIT License. Built for dissertation supervision automation research.
