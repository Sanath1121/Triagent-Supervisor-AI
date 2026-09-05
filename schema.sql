-- ==============================================================================
-- Tri-Agent Dissertation Supervisor — PostgreSQL Telemetry & Audit Schema
-- v1.1 — Added report_markdown column for full report archival and retrieval
-- ==============================================================================

CREATE TABLE IF NOT EXISTS dissertation_jobs (
    id SERIAL PRIMARY KEY,
    job_id VARCHAR(255) NOT NULL,
    title_hash VARCHAR(255),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    submission_status VARCHAR(50),
    recency_pct NUMERIC(5,2),
    total_citations INTEGER DEFAULT 0,
    sections_reviewed_count INTEGER DEFAULT 0,
    report_markdown TEXT
);

-- Indexing for high-throughput lookup and analytical reporting
CREATE INDEX IF NOT EXISTS idx_dissertation_jobs_job_id ON dissertation_jobs(job_id);
CREATE INDEX IF NOT EXISTS idx_dissertation_jobs_timestamp ON dissertation_jobs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_dissertation_jobs_status ON dissertation_jobs(submission_status);

-- Upgrade existing tables: add column if upgrading from schema v1.0
-- (Safe to run on an existing DB — will no-op if column exists in Postgres 12+)
ALTER TABLE dissertation_jobs ADD COLUMN IF NOT EXISTS report_markdown TEXT;

-- Verification query:
-- SELECT job_id, submission_status, recency_pct, total_citations, sections_reviewed_count,
--        LENGTH(report_markdown) as report_length_chars, timestamp
-- FROM dissertation_jobs
-- ORDER BY timestamp DESC
-- LIMIT 10;
