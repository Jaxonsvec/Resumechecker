# Architecture

Airesume is a Flutter application at the repository root. The Android app is the first target. `lib/` owns presentation and will call an API service once the API contract and upload flow are implemented. Provider credentials must remain in the backend; they must never be included in the Flutter bundle.

## Current implementation

- The home screen introduces the planned three-step workflow.
- Pasted text passes through `ResumeChecker` into a shared `ResumeFeedback` model and results screen. These are local rule-based checks.
- **Upload resume** opens `ResumeUploadScreen`. `ResumeFilePicker` uses Flutter's `file_selector` native dialog for PDF/DOCX, validates extension and nonzero size up to 10 MiB (10,485,760 bytes), and retains the current selection and size in screen state. The native plugin may read/copy selected contents into platform app cache. The UI supports replace/remove, cancellation, retry, and paste fallback. Document contents are not parsed or uploaded; filename/size validation does not establish document integrity. These picker defaults do not finalize a future backend upload contract.
- The backend offers a health check and validates a placeholder analysis request. Valid analysis requests return HTTP 501; no resume is stored or processed. Provider integration is future work.
- OpenAI `gpt-5-mini` remains the initial provider/model decision from the project brief. It is not currently called.

## Planned flow

1. Flutter selects a supported resume document and gathers an optional target role.
2. Flutter uploads it to the authenticated API over TLS. The API validates size and format, extracts text, and avoids logging document contents.
3. A provider interface sends the minimum necessary text to the configured model. Provider credentials remain server-side.
4. The API validates a structured result before returning it to Flutter. The app presents loading, recoverable errors, and results.

Before implementing this flow, the group should decide retention/deletion behavior, supported formats, authentication, and whether uploads are stored or processed in memory.
