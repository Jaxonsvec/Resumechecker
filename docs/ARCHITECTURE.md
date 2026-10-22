# Architecture

Airesume is a Flutter application at the repository root. The Android app is the first target. Provider credentials remain in the backend; they must never be included in the Flutter bundle.

## Current implementation

- Flutter supports PDF/DOCX selection up to 10 MiB and displays file metadata. After an explicit processing acknowledgment, the app reads the selected file, uploads it with optional target role through a reusable multipart HTTP client, shows progress/retry states, validates the JSON response, and renders actual feedback sections. The HTTP client and UI are covered with mocked tests.
- The Express backend accepts a PDF/DOCX multipart upload at `POST /api/v1/analyses`, checks the file signature and size, extracts text in memory, and calls an injectable analyzer. The default analyzer sends the extracted text to OpenAI using a structured response schema. Uploads and extracted text are not stored by the application.
- The analysis response contains a summary, evidence-backed strengths and improvements, and missing-information notes. It intentionally contains no numeric score. The server prompt directs the model not to invent facts or infer protected traits.
- Automated tests use fake extraction/analyzer implementations and never make live provider requests. Dependencies and the refreshed lockfile still need successful installation/verification in an environment with npm registry access.
- Real app-to-server integration has not been exercised against a clean backend install, Android emulator/device, or live provider. The backend lockfile is stale pending npm registry access.

## End-to-end flow

1. Flutter selects a PDF or DOCX resume up to 10 MiB, may provide a target role, and requires acknowledgment that resume text will go to the configured AI service.
2. The app uploads the file through its reusable multipart API client and displays progress while the request runs.
3. The API accepts one file in memory, checks the extension and magic bytes, and extracts text. Scanned PDFs without an embedded text layer return `NO_EXTRACTABLE_TEXT`; OCR is not implemented.
4. The backend submits extracted text and optional target role to the configured OpenAI model and validates the structured response before returning it.
5. Flutter parses and displays summary, strengths, improvements, and missing-information notes. On failure it shows a safe message and allows retry. Provider credentials and raw provider errors are not sent to the client.

This provides a backend analysis path with sensible default criteria and an in-app acknowledgment before upload. Authentication, retention/deletion policy, production deployment controls, and legal/privacy review remain necessary before processing real resumes in a deployed service. `store: false` is sent to OpenAI, but this is not a substitute for reviewing current provider terms and project privacy requirements.
