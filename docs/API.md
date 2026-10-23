# API contract

Base URL is configured for each environment. The backend defaults to port 3000 (`PORT`). Flutter uses `API_BASE_URL` (`http://10.0.2.2:3000` by default on Android emulator; `http://localhost:3000` elsewhere). Set `CORS_ALLOWED_ORIGINS` to the exact Flutter Web origin when using a browser build. JSON errors use `{"error":{"code":"...","message":"...","fields":{...}}}`; `fields` is included for request validation failures. Resume bytes and extracted text are held in memory for the request and are not written to disk or logged by application code.

## `GET /health`

Returns HTTP 200 with `{"status":"ok"}` while the service accepts requests. It does not verify provider availability.

## `POST /api/v1/analyses`

Send `multipart/form-data` with one `resume` file and optional `targetRole` text. The file must have a `.pdf` or `.docx` extension and matching PDF or ZIP/DOCX signature. Maximum upload size is 10 MiB; extracted text is limited to 100,000 characters; `targetRole` is limited to 200 characters. The server extracts text in memory and returns analysis feedback without storing the source document.

Successful response (HTTP 200):

```json
{
  "analysis": {
    "summary": "A concise overall assessment.",
    "strengths": [{ "title": "Relevant experience", "evidence": "Evidence quoted or summarized from the resume." }],
    "improvements": [{ "title": "Clarify impact", "evidence": "The listed role has no outcome measure.", "recommendation": "Add a truthful result or scale where available." }],
    "missing_information": ["Education details"]
  }
}
```

The response intentionally has no numeric score. Model output is constrained by a Zod/JSON Schema contract. The prompt requests evidence-grounded writing feedback and prohibits invented facts, protected-trait inferences, hiring predictions, and ranking.

Errors: HTTP 400 `INVALID_REQUEST` / `INVALID_UPLOAD`; 413 `FILE_TOO_LARGE`; 415 `UNSUPPORTED_FILE_TYPE`; 422 `INVALID_FILE`, `NO_EXTRACTABLE_TEXT`, or `INVALID_RESUME_TEXT`; 502 `INVALID_ANALYSIS_RESPONSE` / `ANALYSIS_FAILED`; 503 `ANALYSIS_UNAVAILABLE` / `ANALYSIS_BUSY`; 504 `ANALYSIS_TIMEOUT`; 404 `NOT_FOUND`. When the key is missing or left at the example placeholder, `ANALYSIS_UNAVAILABLE` instructs the developer to set `OPENAI_API_KEY` in `backend/.env` or the server environment and restart. Error messages do not include credentials, document text, or provider error details. Scanned/image-only PDFs are rejected because OCR is not implemented.

## Processing and limitations

The upload handler uses in-memory storage and does not persist files. This is a development implementation; authentication, production deployment controls, retention/deletion policy, and provider data handling still require product/privacy decisions. A configured provider key is required to get analysis; absent keys produce `ANALYSIS_UNAVAILABLE`. OpenAI calls use `store: false`, a 30-second SDK timeout, and one retry. The Flutter client calls this endpoint after explicit processing acknowledgment. It parses the documented response, shows progress, retains the selected file on failure for retry, and renders returned feedback.

The API uses `OPENAI_API_KEY` and `OPENAI_MODEL` from the backend environment. Keep the key server-side; never put it in Flutter or commit a real `.env`. No live provider call is made in automated tests.

The Flutter client parses the documented response and shows an indeterminate progress state while the upload and analysis request runs. It keeps the selected file available if a request fails so the user can retry. The client requires the user to acknowledge that resume text will be sent to the configured AI service before upload.
