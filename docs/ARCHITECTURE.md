# Architecture

Airesume is a Flutter application at the repository root. The Android app is the first target. `lib/` owns presentation and will call an API service once the API contract and upload flow are implemented. Provider credentials must remain in the backend; they must never be included in the Flutter bundle.

## Current implementation

- The home screen introduces the planned three-step workflow and links to the UX prototype.
- The prototype contains resume-selection, illustrative analysis-progress, results-layout, unsupported-file, and connection-retry screens. It explicitly labels previews and does not read, upload, or analyze a file.
- The backend offers a health check and validates a placeholder analysis request. Valid analysis requests return HTTP 501; no resume is stored or processed. Provider integration is future work.
- OpenAI `gpt-5-mini` remains the initial provider/model decision from the project brief. It is not currently called.

## Draft flow (not yet approved by the team)

1. The user chooses a resume and may provide a target role. Supported formats and limits need team agreement.
2. The app confirms the selection, then shows progress while the API validates and processes the document.
3. Results group an overall summary, strengths, and prioritized improvements. Scoring criteria and any numeric score need team agreement.
4. If the file is unsupported, explain what the user can do next. If the service fails, preserve the selection and offer retry.
5. The backend handles document processing and any provider request; credentials remain server-side. Retention and deletion need team agreement before implementation.

This is a UX proposal represented by design previews, not an accepted product workflow or functional feature. Before implementation, the group should decide retention/deletion behavior, supported formats and limits, authentication, target-role behavior, and whether uploads are stored or processed in memory.
