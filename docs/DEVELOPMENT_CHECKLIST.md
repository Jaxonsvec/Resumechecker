# Airesume — Development Checklist

Before taking a task, start with the current [project handover](HANDOVER.md), then follow the onboarding sequence in [README.md](../README.md). AI coding agents must follow [AGENTS.md](../AGENTS.md), which requires reading the handover first. Use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) for machine setup; this file tracks feature work.

Use this checklist as the team's source of truth for building the application. Work through tasks in order and check items only when implemented and tested.

## Current progress

- **Completed:** 1.1–1.6, 2.2–2.6, 3.1–3.7, 4.1, 4.3–4.8, 5.1, 5.6–5.9, 6.1–6.7, 7.2–7.4, 7.8, 9.1, 9.2, 9.5, 10.4, 10.5, and 10.6. Evidence is noted beside each checked item. The merged local-workflow branch also provides pasted-text rule checks and a separate metadata-only local file-selection preview.
- **In progress:** 2.7 — screen review is waiting for team feedback.
- **Next:** Have another teammate verify a fresh clone and setup (item 1.7). After that, add a developer-owned OpenAI API key locally and verify one intentional analysis request; the full upload flow on Android remains to be checked.
- **Remaining:** All unchecked items below; see dependency and acceptance gates near the end. Clean `npm ci`, live provider execution, full Android analysis, and GitHub CI are not verified.

## Phase 1: Project Foundation

- [x] 1.1 — Confirm the Flutter app runs from the repository root. *(Built and launched on Pixel 7 emulator on 22 October 2026; the foreground app was `com.example.airesume/.MainActivity`, and the Android UI hierarchy showed the integrated home screen and its connected, paste, and local file-selection actions.)*
- [x] 1.2 — Verify Flutter formatting, static analysis, and tests pass. *(Verified locally: Dart format check, `flutter analyze`, and `flutter test` passed.)*
- [x] 1.3 — Review and finalize the folder structure. *(Root Flutter app, `backend/`, `docs/`, and `.github/workflows/` are present and reviewed.)*
- [x] 1.4 — Establish a consistent theme, colors, typography, and reusable UI components. *(Implemented in `lib/theme/app_theme.dart`; shared color tokens, Material 3 styles, card and button styles are consumed by the app. `AppScrollBehavior` also removes edge stretching while retaining platform scrolling.)*
- [x] 1.5 — Configure navigation between application screens. *(Home → connected resume analysis → results uses Flutter routes; pasted text opens local checks, and the file-selector preview is a separate local-only path. Widget tests cover these flows.)*
- [x] 1.6 — Add reusable loading, empty, error, and success states. *(Implemented in `lib/widgets/feedback_state.dart`; widget test verifies each state variant.)*
- [ ] 1.7 — Verify the project can be cloned and run by another team member.

## Phase 2: Define the User Experience

- [x] 2.1 — Finalize the primary user workflow. *(Using the user's direction to proceed without design preferences: choose a resume, acknowledge provider processing, optionally enter a target role, analyze, view structured feedback, and retry safe failures; paste-text and metadata-only local selection remain secondary options.)*
- [x] 2.2 — Design the home screen and resume-analysis entry point. *(Home screen and connected, pasted-text, and local-selection entry points are implemented and covered by widget tests; team review is still needed.)*
- [x] 2.3 — Design the resume selection and upload screen. *(Selection screen provides metadata, optional target role, processing consent, and connected upload.)*
- [x] 2.4 — Design the analysis progress screen. *(Shows active upload/analysis progress and completion or failure states.)*
- [x] 2.5 — Design the results and recommendations screen. *(Renders returned summary, strengths, improvements, and missing information without inventing a score.)*
- [x] 2.6 — Design error, retry, and unsupported-file states. *(Validation and user-safe API errors are displayed; failed uploads can be retried.)*
- [ ] 2.7 — Review the screens with the team before implementing the full workflow.

## Phase 3: Resume Input

<<<<<<< HEAD
- [ ] 3.1 — Choose supported resume formats and define file size limits.
- [x] 3.2 — Implement resume file selection in Flutter. *(Native picker is connected to the home upload entry; local tests passed.)*
- [x] 3.3 — Display the selected filename and file details. *(Filename and size appear after selection; widget test passed.)*
- [x] 3.4 — Validate file types and file size. *(PDF/DOCX extensions and nonzero size through 5 MiB; boundary tests passed.)*
- [x] 3.5 — Allow the user to replace or remove the selected resume. *(Replace/remove controls and preservation on invalid replacement; widget test passed.)*
- [x] 3.6 — Handle cancellation, invalid files, and permission errors. *(Cancellation, validation/access errors, retry, and async disposal tests passed.)*
- [x] 3.7 — Add tests for resume selection and validation. *(Service and widget selection tests passed locally on 22 October 2026.)*

### File-selection status and extraction handoff

- **Upload resume → Choose file** opens a native PDF/DOCX picker with an initial 5 MiB limit (5,242,880 bytes, displayed as 5 MiB). These local defaults implement the previous proposal; team confirmation and future server-side contract remain open in 3.1.
- The selected filename/size, replace/remove, non-destructive cancellation and invalid replacement, empty/oversized/unsupported-file errors, access-error retry, and paste-text fallback are implemented and covered by local tests. Native dialog behavior must also be checked on a device.
- File content integrity, text extraction, corrupt/scanned-document handling, and extracted-text-to-checker integration remain incomplete. Selection alone does not make file-based analysis work.
- Implement extraction as a dedicated service. Pass successful text and optional role to the existing `ResumeChecker` and `ResumeResultsScreen` flow.
- Add corrupt-file, empty-extracted-text, scanned-PDF, and extraction-to-checker tests. Valid PDF/DOCX must reach the shared feedback screen before claiming file-based checking.
- The native picker may read/copy selected files into platform app cache. Agree cache/retention/deletion rules before live processing; app code does not log or transmit contents.
=======
- [x] 3.1 — Choose supported resume formats and define file size limits. *(Connected and local selection flows accept PDF and DOCX files from 1 byte through 10 MiB; the backend also validates the upload limit. Confirm this policy with the team.)*
- [x] 3.2 — Implement resume file selection in Flutter. *(The connected `file_picker` path reads selected bytes and uploads only after consent; the separate `file_selector` preview retains metadata and does not upload.)*
- [x] 3.3 — Display the selected filename and file details. *(Shows filename, extension, and formatted file size.)*
- [x] 3.4 — Validate file types and file size. *(Checks extension and byte length, including empty and unmeasurable files.)*
- [x] 3.5 — Allow the user to replace or remove the selected resume. *(Invalid replacements preserve the previous valid selection.)*
- [x] 3.6 — Handle cancellation, invalid files, and permission errors. *(Cancellation preserves the current selection; validation and picker failures show safe messages without local paths.)*
- [x] 3.7 — Add tests for resume selection and validation. *(Unit and widget tests cover format/size boundaries, selection details, replace/remove, cancellation, rejected replacements, and picker failures.)*
>>>>>>> bf7d89571cc4492edd42705af50c5564a64c57d5

## Phase 4: Backend and Resume Processing

- [x] 4.1 — Finalize the API contract and analysis request/response models. *(Multipart contract and structured response schema are documented in `docs/API.md`; mocked API success/error cases pass.)*
- [x] 4.2 — Configure backend environment variables and local development instructions. *(Node's `--env-file-if-exists` loaded a temporary sentinel env file; `.env` is ignored by Git; README documents local key setup and restart steps. No real key was used.)*
- [x] 4.3 — Implement and test resume upload handling. *(In-memory multipart upload success, missing file, unsupported extension, and oversized file cases pass mocked API tests.)*
- [x] 4.4 — Validate uploaded files on the server. *(Extension/signature rejection and the 10 MiB limit pass tests; extracted text is capped at 100,000 characters.)*
- [x] 4.5 — Implement text extraction for supported resume formats. *(Verified both extractors using generated, text-only PDF and DOCX documents; no real resume or provider request was used.)*
- [x] 4.6 — Handle scanned PDFs and unsupported documents appropriately. *(Unsupported types and PDFs without extractable text return explicit errors; route behavior is tested. OCR is not implemented.)*
- [x] 4.7 — Add consistent API errors, request limits, and timeouts. *(Backend suite verifies shared error responses, malformed/oversized inputs, the 10 MiB upload limit, 35-second route timeout signal, and timeout/rate-limit mappings.)*
- [x] 4.8 — Test the backend independently of the Flutter application. *(Verified locally: `npm run check` and all eleven `npm test` API/unit tests passed. `npm install` reports the lockfile is up to date; clean `npm ci` has not been run.)*

## Phase 5: AI Resume Analysis

- [x] 5.1 — Confirm the analysis criteria and expected output with the team. *(User directed us to proceed without waiting for design preferences; default output is a summary, evidence-based strengths/improvements, and missing information, without scores or hiring predictions.)*
- [ ] 5.2 — Finalize the AI provider and model configuration. *(OpenAI Responses API and `OPENAI_MODEL` configuration are implemented; live availability is not verified.)*
- [ ] 5.3 — Securely configure the provider API key on the backend. *(Reads only `OPENAI_API_KEY` from backend environment; no actual key was supplied or used. The app now shows local setup steps when it is missing.)*
- [ ] 5.4 — Create a structured analysis prompt. *(Implemented with evidence and non-inference requirements.)*
- [ ] 5.5 — Implement the server-side AI request. *(OpenAI Responses API adapter implemented; live call not made.)*
- [x] 5.6 — Validate the AI response against a defined schema. *(Structured output schema and server-side Zod validation are implemented; malformed analysis results return a tested safe error.)*
- [x] 5.7 — Return actionable feedback, strengths, weaknesses, and improvement suggestions. *(Mocked success returns summary, evidence-backed strengths/improvements, and missing information; no numeric score.)*
- [x] 5.8 — Handle provider errors, rate limits, invalid responses, and timeouts. *(Mocked API tests verify safe responses for missing configuration, rate limiting, invalid results, and timeouts; no live provider request was made.)*
- [x] 5.9 — Add automated tests using mocked AI responses. *(All eleven backend tests pass; provider requests are injected/mocked and no live calls are made.)*
- [ ] 5.10 — Evaluate the results with sample or synthetic resumes before release.

## Phase 6: Connect Flutter to the Backend

- [x] 6.1 — Implement a reusable API client. *(Injectable HTTP client builds multipart requests and safely maps API errors; MockClient tests pass.)*
- [x] 6.2 — Configure the backend URL for local development and deployment. *(Supports `API_BASE_URL`; defaults to Android emulator host or localhost. Web CORS uses an explicit origin allowlist.)*
- [x] 6.3 — Connect resume selection to the upload endpoint. *(Selected PDF/DOCX bytes and optional target role are sent after user acknowledgment.)*
- [x] 6.4 — Display progress while analysis is running. *(Progress screen shows the request state until success or failure.)*
- [x] 6.5 — Parse and validate analysis responses in Flutter. *(Response model validates fields and size limits; malformed data is covered by tests.)*
- [x] 6.6 — Display useful error messages and allow retrying failed requests. *(Safe server messages and retry action preserve the selected resume.)*
- [x] 6.7 — Test the complete upload-to-analysis workflow. *(Mocked widget flow verifies consent, retry, and returned feedback; API client tests verify multipart fields and error parsing.)*
- [ ] 6.8 — Verify the workflow on an Android emulator or physical device.

## Phase 7: Results and User Features

- [ ] 7.1 — Display an overall resume assessment, if supported by the agreed analysis design.
- [x] 7.2 — Display resume strengths and areas for improvement. *(Results screen renders evidence-based API fields.)*
- [x] 7.3 — Display actionable recommendations and suggested revisions. *(Recommendations are displayed with supporting evidence.)*
- [x] 7.4 — Organize feedback into readable sections. *(Summary, strengths, improvements, and missing information are grouped into sections.)*
- [ ] 7.5 — Allow users to return to the results after navigating between screens, if required.
- [ ] 7.6 — Implement analysis history or saved results if required by the project scope.
- [ ] 7.7 — Add accessibility, responsive layouts, and useful empty states.
- [x] 7.8 — Verify the results UI using mocked responses and error cases. *(Flutter tests cover safe failure, retry, and rendered results.)*

## Phase 8: Security and Privacy

- [x] 8.1 — Confirm API credentials are never included in the mobile app. *(Flutter source only contains the environment-variable name in setup guidance; the provider adapter reads the key from the backend environment. Tracked-file scan found no key.)*
- [x] 8.2 — Avoid logging resume contents or unnecessary personal information. *(Source scan found only backend startup/configuration status logs; no resume text, uploads, or personal details are logged.)*
- [ ] 8.3 — Define whether uploaded resumes and analysis results are stored.
- [ ] 8.4 — Implement appropriate retention and deletion behavior if storage is used.
- [ ] 8.5 — Verify upload validation and backend request limits.
- [ ] 8.6 — Document how resume data is processed and sent to any AI provider.
- [ ] 8.7 — Test that failures do not expose secrets or sensitive document contents.

## Phase 9: Testing and Quality Assurance

- [x] 9.1 — Add Flutter unit tests for models and services. *(Checker, file-picker, and API-client tests pass as part of the Flutter suite.)*
- [x] 9.2 — Add widget tests for the main screens and interactions. *(Connected selection, paste checks, local file selection, scrolling, and feedback states are covered by passing widget tests.)*
- [x] 9.3 — Add backend unit and API integration tests. *(Eleven backend tests pass, covering extraction signature validation and API health, upload, provider, limits, and error responses.)*
- [x] 9.4 — Test invalid uploads, network failures, and AI provider errors. *(Backend tests cover unsupported/oversized uploads and provider errors; Flutter API-client tests cover unreachable-server and provider-failure messages.)*
- [x] 9.5 — Run formatting, static analysis, and all automated tests. *(Verified locally on 22 October 2026: Dart format check, `flutter pub get`, Flutter analysis, all 38 Flutter tests (one opt-in URL override test skipped by default), backend syntax check, and all eleven backend tests passed. URL override has a separate passing targeted test.)*
- [ ] 9.6 — Build a release-mode Android APK.
- [ ] 9.7 — Perform end-to-end testing on a real device or emulator.
- [ ] 9.8 — Have a teammate test the app using the documented setup guide.
- [ ] 9.9 — Resolve release-blocking defects.

## Phase 10: CI, Documentation, and Delivery

- [ ] 10.1 — Verify GitHub Actions runs on pushes and pull requests.
- [ ] 10.2 — Ensure CI runs Flutter tests, analysis, and the Android build.
- [ ] 10.3 — Ensure CI runs backend checks and tests.
- [x] 10.4 — Update the README with accurate setup and execution instructions. *(README commands and links were reviewed against the current project.)*
- [x] 10.5 — Update the API contract and architecture documentation. *(Docs describe the implemented analysis API, Flutter integration, consent, and current verification limits.)*
- [x] 10.6 — Update the developer handover and setup checklist. *(Both documents exist and were checked against the current files.)*
- [ ] 10.7 — Confirm no credentials, real resumes, or build artifacts are committed.
- [ ] 10.8 — Review outstanding tasks and known limitations with the team.
- [ ] 10.9 — Complete final acceptance testing.
- [ ] 10.10 — Prepare the final demonstration and project submission.

## Definition of Done

A task can be checked off only when:

- The implementation is present in the repository.
- Relevant tests pass.
- The change has been reviewed by the team when appropriate.
- Documentation is updated if behavior or setup instructions changed.

Do not mark planned features as completed. If a task is blocked, record the blocker and leave the checkbox unchecked.

## Dependencies and acceptance gates

- **Foundation (Phase 1):** Use the [setup checklist](SETUP_CHECKLIST.md) first. Phase 1.1 is accepted after `flutter run` from the repository root reaches the home screen on an emulator or device. Phase 1.7 requires a teammate to complete a fresh clone/setup/run without relying on this machine's local paths.
<<<<<<< HEAD
- **Workflow and input (Phases 2–3):** Get team agreement on 2.1 and screen review 2.7. Local selection currently uses initial PDF/DOCX and 5 MiB defaults; finalize file formats and limits with the team in 3.1 before file processing/upload work. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Finalize 4.1 and the privacy/data decisions in 8.3–8.6 before accepting real resumes. Upload handling, file validation, extraction, unsupported/scanned-document behavior, size limits, errors, and timeouts must be tested independently before integration.
- **AI analysis (Phase 5):** Confirm criteria and provider/model (5.1–5.2) before implementing prompts or requests. Keep credentials server-side. Define and validate the response schema; use mocked provider responses for routine tests and synthetic resumes for evaluation.
- **Flutter integration and results (Phases 6–7):** These depend on a stable API request/response contract, working backend analysis, and file input. End-to-end acceptance requires upload progress, response parsing, useful failures/retry, results display, and mocked success/error UI coverage.
=======
- **Workflow and input (Phases 2–3):** The user approved proceeding with the default 2.1 workflow; screen review 2.7 still needs team feedback. Phase 3 implements PDF/DOCX selection up to 10 MiB for both the connected analysis path and the metadata-only preview; confirm that policy. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Backend upload/extraction/API source and mocked tests are implemented. PDF/DOCX extraction passed with synthetic files. Clean dependency installation remains to be verified. Complete authentication, retention/deletion, provider data handling, and deployment controls before production use.
- **AI analysis (Phase 5):** Default criteria and a configurable OpenAI Responses implementation are in source. Keep credentials server-side. Verify with mocked provider responses and synthetic resumes; do not use live resumes until privacy/data decisions are complete.
- **Flutter integration and results (Phases 6–7):** The connected upload, progress, response parsing, retry, results display, and mocked success/error UI coverage are implemented and locally tested. Android emulator/device verification remains open.
>>>>>>> bf7d89571cc4492edd42705af50c5564a64c57d5
- **Security and release (Phases 8–10):** Resolve privacy and retention decisions before live resume processing. Release acceptance requires passing local checks, Android device/emulator end-to-end verification, a teammate setup run, and an observed GitHub Actions run. Local CI-equivalent commands do not prove that GitHub CI passed.

## First incomplete task

<<<<<<< HEAD
**1.1 — Confirm the Flutter app runs from the repository root.** The debug APK builds and the widget test passes, but the app has not been launched on an emulator or physical device. Run `flutter run` from the repository root and verify the home screen on a device before checking this item.

## Fileupload merge verification — 22 October 2026

The reconciled code retains the 5 MiB selection limit. Formatting and whitespace checks passed; dependency retrieval blocked analysis/test/build verification in the temporary merge checkout. Earlier checked items retain their historical verification, not a passing result for this merge. Native device testing remains required.
=======
**1.7 — Verify the project can be cloned and run by another team member.** This requires a teammate to follow the documented setup on a fresh checkout. The integrated app home screen has now been verified on the Pixel 7 emulator for item 1.1.
>>>>>>> bf7d89571cc4492edd42705af50c5564a64c57d5
