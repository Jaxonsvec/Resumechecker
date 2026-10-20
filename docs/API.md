# API contract (foundation)

Base URL is configured for each environment; the app does not yet call this API. The local service defaults to port 3000 (`PORT` environment variable). JSON errors use `{"error":{"code":"...","message":"...","fields":{...}}}`; `fields` is included for request validation failures.

## Implemented

### `GET /health`

Returns HTTP 200 with `{"status":"ok"}` while the server is accepting requests. This is a service health check only; it does not indicate that analysis is available.

### `POST /api/v1/analyses` (validation only)

Accepts JSON with a required `resumeText` string (trimmed length 1–100,000 characters) and optional `targetRole` string (maximum 200 characters). Unknown fields are rejected. Valid input currently returns HTTP 501 `ANALYSIS_NOT_IMPLEMENTED`; it is not analyzed or stored. JSON bodies over 300 KB return 413. Empty or invalid fields return HTTP 400 `INVALID_REQUEST`; malformed JSON returns HTTP 400 `INVALID_JSON`; unknown routes return HTTP 404 `NOT_FOUND`.

## Planned, not implemented

A production upload request format is intentionally undecided until the team selects upload retention and document extraction behavior. The future endpoint should accept a PDF or DOCX resume and an optional target role, enforce a strict byte limit, and return a validated structured analysis. It must never log resume content or provider credentials.

Proposed successful response: an analysis id, concise overall feedback, and categorized suggestions with evidence from the supplied resume. Proposed errors use a stable JSON shape with a machine-readable code, safe message, and optional field errors. Authentication, maximum file size, PDF/DOCX extraction limits, timeout behavior, and deletion guarantees still need team decisions.

The current placeholder accepts resume text for schema validation only and returns 501 for valid requests. No file upload or real AI output is currently returned.
