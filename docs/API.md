# API contract

Base URL is configured for each environment. The backend defaults to port 3000 (`PORT`). Flutter uses `API_BASE_URL` (`http://10.0.2.2:3000` by default on Android emulator; `http://localhost:3000` elsewhere). Set `CORS_ALLOWED_ORIGINS` to the exact Flutter Web origin when using a browser build. JSON errors use `{"error":{"code":"...","message":"...","fields":{...}}}`; `fields` is included for request validation failures. Resume bytes and extracted text are held in memory for the request and are not written to disk or logged by application code.

## `GET /health`

Returns HTTP 200 with `{"status":"ok"}` while the service accepts requests. It does not verify provider availability.

## `POST /api/v1/analyses`

Send `multipart/form-data` with one `resume` file and optional `targetRole` text. The file must have a `.pdf` or `.docx` extension and matching PDF or ZIP/DOCX signature. Maximum upload size is 10 MiB; extracted text is limited to 100,000 characters; `targetRole` is limited to 200 characters. The server extracts text in memory and returns analysis feedback with the extracted `resume_text` to the same client so it can support editing and regrading. The application does not store the source document.

### `POST /api/v1/analyses/text`

Send JSON `{"resumeText":"...", "targetRole":"..."}` to analyze an edited or OCR-corrected text revision without uploading the original file again. `resumeText` must contain 1–100,000 characters; `targetRole` is optional and limited to 200 characters. The request uses the same provider, prompt, scoring rubric, response schema, timeout, and safe error handling as file analysis.

Successful response (HTTP 200):

```json
{
  "analysis": {
    "overall_score": 82,
    "category_scores": {
      "clarity": {"score": 85, "explanation": "..."},
      "impact": {"score": 80, "explanation": "..."},
      "measurable_results": {"score": 78, "explanation": "..."},
      "skills_experience": {"score": 84, "explanation": "..."},
      "formatting_organization": {"score": 83, "explanation": "..."}
    },
    "summary": "A concise overall assessment.",
    "strengths": [{ "title": "Relevant experience", "evidence": "Evidence quoted or summarized from the resume." }],
    "improvements": [{ "title": "Clarify impact", "evidence": "The listed role has no outcome measure.", "recommendation": "Add a truthful result or scale where available." }],
    "missing_information": ["Education details"],
    "suggested_rewrites": [{"section":"Experience", "original_text":"...", "revised_text":"...", "rationale":"..."}],
    "job_relevance": null
  },
  "resume_text": "Extracted resume text returned to the requesting client",
  "target_role": "Product engineer"
}
```

`target_role` is `null` when no target role was supplied. The backend returns the extracted text and role to the requesting client to enable local editing and subsequent regrading; it does not persist either value.

When `targetRole` is supplied, `job_relevance` contains its own score and relevant, missing, and transferable skill lists. Otherwise it is `null`. The five overall categories use the equally weighted arithmetic mean rubric in [SCORING_RUBRIC.md](SCORING_RUBRIC.md); all scores must be integers from 0 through 100. The score is not a hiring or ATS prediction.

The response intentionally has no numeric score. Model output is constrained by a Zod/JSON Schema contract. The prompt requests evidence-grounded writing feedback and prohibits invented facts, protected-trait inferences, hiring predictions, and ranking.

Errors: HTTP 400 `INVALID_REQUEST` / `INVALID_UPLOAD`; 413 `FILE_TOO_LARGE`; 415 `UNSUPPORTED_FILE_TYPE`; 422 `INVALID_FILE`, `NO_EXTRACTABLE_TEXT`, or `INVALID_RESUME_TEXT`; 502 `INVALID_ANALYSIS_RESPONSE` / `ANALYSIS_FAILED`; 503 `ANALYSIS_UNAVAILABLE` / `ANALYSIS_BUSY` / `OLLAMA_UNAVAILABLE` / `OLLAMA_MODEL_NOT_FOUND`; 504 `ANALYSIS_TIMEOUT`; 404 `NOT_FOUND`. With `AI_PROVIDER=openai`, a missing/example `OPENAI_API_KEY` returns an actionable configuration error. With `AI_PROVIDER=ollama`, an offline local service or missing model returns a provider-specific code and setup guidance. Error messages do not include credentials, document text, or provider error details. Scanned/image-only PDFs are rejected; OCR is currently available in Flutter for JPG/JPEG/PNG image input, not server-side PDF pages.

## Processing and limitations

The upload handler uses in-memory storage and does not persist files. This is a development implementation; authentication, production deployment controls, retention/deletion policy, and provider data handling still require product/privacy decisions. OpenAI requires a server-side API key; local Ollama requires a running local service and installed model, but no OpenAI key. OpenAI calls use `store: false`, a 30-second SDK timeout, and one retry. Ollama's backend request timeout defaults to 180 seconds for model loading/inference; the Flutter client permits 210 seconds. The Flutter client calls this endpoint after explicit processing acknowledgment. It parses the documented response, shows progress, retains the selected file on failure for retry, and renders returned feedback.

Select the server-side provider with `AI_PROVIDER` (`openai` by default or `ollama`). OpenAI uses `OPENAI_API_KEY` and `OPENAI_MODEL`; Ollama uses `OLLAMA_BASE_URL` (default `http://127.0.0.1:11434`), `OLLAMA_MODEL` (default `qwen3:8b`), and `OLLAMA_NUM_CTX` (default 8192) through its local `/api/chat` route. Keep provider credentials server-side; never put them in Flutter or commit a real `.env`. No live provider call is made in automated tests.

The Flutter client parses the documented response and shows an indeterminate progress state while the upload and analysis request runs. It keeps the selected file available if a request fails so the user can retry. The client requires the user to acknowledge that resume text will be sent to the configured AI service before upload.
