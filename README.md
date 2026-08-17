# Dissertation Supervisor AI 

An end-to-end AI-powered academic evaluation system built with **n8n**, **Google Vertex AI (Gemini Flash & Pro)**, **PostgreSQL**, and a modern **Web UI**.

The system acts as a strict, experienced dissertation examiner—parsing academic manuscripts, filtering by review scope, analyzing citations, evaluating individual sections sequentially, and generating calibrated, examiner-level feedback with a formal 3-tier submission verdict.

---

## 🏛️ System Architecture (V2)

```text
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
                                     (Extracts text & review_type)
                                                      │
                                                      ▼
                                       [ Agent 1: Macro Analyser ] ◄── (Gemini Pro)
                                      (Extracts Title, Thesis, Chain,
                                       Methodology & Section Index)
                                                      │
                                                      ▼
                                         [ Code: Section Splitter ]
                                   (Splits text & applies Scope Filters)
                                                      │
                                                      ▼
                                     [ Loop: SplitInBatches Sub-routine ]
                                                      │
                                                      ▼
                                      [ Agent 2: Section Analyser ] ◄── (Gemini Flash)
                                     (Evaluates Section for Critical,
                                      Major, & Minor Examiner Issues)
                                                      │
                                                      ▼
                                    [ Aggregate & Contamination Filter ]
                                                      │
                                                      ▼
                                        [ Merge & Calibration Engine ]
                                  (Calculates Citations, 60% Recency Rule,
                                   & Enforces Holistic Grading Criteria)
                                                      │
                                                      ▼
                                      [ Agent 3: Verdict Generator ] ◄── (Gemini Pro)
                                     (Generates Final Verdict, Action
                                      Items, & Risk Assessment)
                                                      │
                                                      ▼
                                       [ Code: Report Assembler ]
                                     (Injects Citation Checklist & Verdict)
                                                      │
                                                      ▼
                                            [ Web UI Dashboard ]
```

---

## 🚀 Key Features

1. **Dual-Mode Web UI (`dissertation-ui-V2.html`)**:
   - **Direct Text Input** or **PDF Upload**.
   - **Targeted Scope Filtering**: Choose between *Full Review*, *Literature Review Only*, or *Literature & Methodology Only*. The system dynamically drops irrelevant sections to save AI tokens and prevent false positives.
   - Real-time multi-stage progress tracking.
   - Glassmorphism UI displaying the Supervisor Verdict, Priority Action List, Citation Checklist, and collapsible section-by-section issue breakdowns.

2. **Automated Citation & Recency Auditing**:
   - Automatically counts in-text citations and reference list entries.
   - Cross-references for mismatches (e.g. 30 in-text vs 10 in bibliography).
   - Enforces a strict **60% Recency Rule** (60% of references must be published within the last 5 years), outputting a clear `PASS`, `BORDERLINE`, or `FAIL`.

3. **Tri-Agent Multi-Stage Analysis**:
   - **Macro Analyser (Gemini Pro)**: Maps global thesis structure without pre-evaluating.
   - **Section Analyser (Gemini Flash)**: Sequentially reviews section-by-section with running context passing.
   - **Verdict Generator (Gemini Pro)**: Synthesizes holistic findings into supervisor-level recommendations.

4. **Strict Examiner Calibration Rules**:
   - **3-Tier Verdict System**: `READY FOR SUBMISSION` | `CONDITIONAL` | `NOT READY`.
   - **Underdeveloped ≠ Absent Rule**: Thin literature reviews or short discussions trigger `CONDITIONAL`, **never** `NOT READY`.
   - **Hard Override**: If core methodology and logic are sound, `NOT READY` is strictly forbidden.

---

## 📁 Repository Structure

```
.
├── dissertation-ui-V2.html      # Glassmorphism Web Interface
├── start-ui-V2.ps1              # PowerShell Web Server Launcher
├── Triagent-multiinput-V2.json  # Master n8n Workflow JSON
└── README.md                    # Project Documentation
```

---

## 🛠️ Quick Start Guide

### Prerequisites

1. **Python 3.x** installed and added to `PATH` (Used for the UI local server).
2. **n8n** instance running via Docker (Required for CORS configuration).
3. **Google Vertex AI / Gemini API Credentials** configured in n8n.

---

### Step 1: Run n8n with CORS Enabled

To allow the local UI to communicate with n8n, you must enable CORS in your n8n Docker setup. 

In your `docker-compose.yml`, add the `N8N_CORS_ALLOW_ORIGIN` environment variable:

```yaml
version: '3.8'

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_CORS_ALLOW_ORIGIN=*    # <--- CRITICAL FOR LOCAL UI
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

Start the container:
```bash
docker compose up -d
```

---

### Step 2: Import Workflow into n8n

1. Open n8n (`http://localhost:5678`).
2. Go to **Workflows ➔ Import from File**.
3. Select `Triagent-multiinput-V2.json` from this repository.
4. Open the three AI nodes (`Macro Analyser`, `Section Analyser`, `Verdict Generator`) and link your **Google Vertex AI** credentials.
5. Save and **Activate** the workflow.
6. Open the `Webhook` node at the start of the workflow, and copy your **Test URL** or **Production URL**.

---

### Step 3: Launch the Web UI

To prevent local browser CORS/Network errors, the UI must be served over a local HTTP server rather than opening the file directly.

1. Open Windows PowerShell in this directory.
2. Run the provided launcher script:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-ui-V2.ps1
```

3. The script will start a local server on port `8080` and automatically open your browser to `http://localhost:8080/dissertation-ui-V2.html`.
4. Paste your n8n Webhook URL into the UI, select your review scope, and upload a document!

---

## 📝 License

Distributed under the MIT License. Built for dissertation supervision automation research.
