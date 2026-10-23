# Architecture

Airesume is a Flutter application at the repository root. The Android app is the first target. Provider credentials remain in the backend; they must never be included in the Flutter bundle.

## Current implementation

- The home screen offers three distinct paths: the connected backend analysis workflow, local pasted-text checks, and a local file-selection preview. Pasted text uses `ResumeChecker` and the shared `ResumeFeedback`/results screen entirely on-device. The local preview uses `file_selector` to show filename and size, with replace/remove and cancellation handling; that path does not parse, upload, or analyze the selected file. The native plugin may copy selected data to app cache.
- Flutter supports PDF/DOCX selection up to 10 MiB and displays file metadata. After an explicit processing acknowledgment, the app reads the selected file, uploads it with optional target role through a reusable multipart HTTP client, shows progress/retry states, validates the JSON response, and renders actual feedback sections. The HTTP client and UI are covered with mocked tests.
- The Express backend accepts a PDF/DOCX multipart upload at `POST /api/v1/analyses`, checks the file signature and size, extracts text in memory, and calls an injectable analyzer. `AI_PROVIDER=openai` selects the existing OpenAI Responses adapter; `AI_PROVIDER=ollama` selects a local Ollama `/api/chat` adapter with a JSON Schema response format. Local inference uses a configurable context budget and longer timeout for cold model loading. Uploads and extracted text are not stored by the application.
- The analysis response contains a summary, evidence-backed strengths and improvements, and missing-information notes. It intentionally contains no numeric score. The server prompt directs the model not to invent facts or infer protected traits.
- Automated tests use fake extraction/analyzer implementations and mocked provider requests; they never make live provider requests. `flutter pub get` resolved both file-selection plugins without upgrading the existing Flutter dependencies; a clean `npm ci` passed in a temporary source snapshot.
- The file-selector preview is separate from the connected `file_picker` workflow. Avoid describing local selection as an upload or as evidence of file parsing. Synthetic text-only PDF and DOCX extraction has been verified. A real local Ollama inference request with synthetic text succeeded through the API route; a live OpenAI request and full on-device analysis have not been made.

## End-to-end flow

The primary workflow is file-based analysis. Following the user's direction to use sensible defaults without blocking on visual preferences, the home screen presents **Choose a resume** as the connected path, with pasted-text checks and local metadata preview as separate alternatives.

1. Flutter selects a PDF or DOCX resume up to 10 MiB, may provide a target role, and requires acknowledgment that resume text will go to the configured AI service.
2. The app uploads the file through its reusable multipart API client and displays progress while the request runs.
3. The API accepts one file in memory, checks the extension and magic bytes, and extracts text. Scanned PDFs without an embedded text layer return `NO_EXTRACTABLE_TEXT`; OCR is not implemented.
4. The backend submits extracted text and optional target role to the selected provider: OpenAI over its Responses API or the local Ollama service over `/api/chat`. Both paths validate the structured response before returning it. Local Ollama requests need no OpenAI key and do not send prompts off the machine when pointed at the local service.
5. Flutter parses and displays summary, strengths, improvements, and missing-information notes. On failure it shows a safe message and allows retry. Provider credentials and raw provider errors are not sent to the client.

This provides a backend analysis path with sensible default criteria and an in-app acknowledgment before upload. Authentication, retention/deletion policy, production deployment controls, and legal/privacy review remain necessary before processing real resumes in a deployed service. OpenAI requests set `store: false`; local Ollama is the private-by-network default. Ollama Cloud is not configured. Cloud inference would send prompts to Ollama and requires account/API credentials, internet access, and review of its privacy and usage terms.
