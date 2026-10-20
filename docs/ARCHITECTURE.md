# Architecture

Airesume is a Flutter application at the repository root. The Android app is the first target. `lib/` owns presentation and will call an API service once the API contract and upload flow are implemented. Provider credentials must remain in the backend; they must never be included in the Flutter bundle.

## Current implementation

- The home screen introduces the planned three-step workflow.
- The resume action uses `file_picker` through `lib/resume_input.dart`. It accepts a single PDF/DOCX by filename extension, with a positive reported size up to 5 MiB. It retains a platform file reference in widget state for this session and displays name/type/size, replacement, removal, and safe access errors. Cancellation or failed replacement keeps the prior selection. No document contents are read by app code, uploaded, parsed, or analyzed. Native providers may create local temporary copies; removing a selection clears the app reference, not the original document or provider cache. File signatures and server validation remain future work.
- The backend offers a health check and validates a placeholder analysis request. Valid analysis requests return HTTP 501; no resume is stored or processed. Provider integration is future work.
- OpenAI `gpt-5-mini` remains the initial provider/model decision from the project brief. It is not currently called.

## Planned flow

1. Flutter selects a supported resume document and gathers an optional target role.
2. Flutter uploads it to the authenticated API over TLS. The API validates size and format, extracts text, and avoids logging document contents.
3. A provider interface sends the minimum necessary text to the configured model. Provider credentials remain server-side.
4. The API validates a structured result before returning it to Flutter. The app presents loading, recoverable errors, and results.

Before implementing this flow, the group should decide retention/deletion behavior, supported formats, authentication, and whether uploads are stored or processed in memory.
