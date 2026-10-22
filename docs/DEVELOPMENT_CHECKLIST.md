# Airesume — Development Checklist

Before taking a task, start with the current [project handover](HANDOVER.md), then follow the onboarding sequence in [README.md](../README.md). AI coding agents must follow [AGENTS.md](../AGENTS.md), which requires reading the handover first. Use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) for machine setup; this file tracks feature work.

Use this checklist as the team's source of truth for building the application. Work through tasks in order and check items only when implemented and tested.

## Current progress

- **Completed:** 1.2–1.6, 2.2–2.6, 3.1–3.7, 4.1, 4.3, 4.4, 4.6, 4.8, 5.1, 5.6, 5.7, 5.9, 6.1–6.7, 7.2–7.4, 7.8, 9.5, 10.4, 10.5, and 10.6. Evidence is noted beside each checked item.
- **In progress:** 2.1 — a draft flow is represented in the prototype, but the team has not confirmed it. Item 2.7 is waiting for team review.
- **Next:** Refresh and verify the backend dependency lockfile after npm registry access returns, then test PDF/DOCX extraction with synthetic documents and verify the connected flow on an Android emulator/device.
- **Remaining:** All unchecked items below; see dependency and acceptance gates near the end. Clean-install reproducibility, extraction against synthetic files, live provider execution, Android device execution, and GitHub CI are not verified.

## Phase 1: Project Foundation

- [ ] 1.1 — Confirm the Flutter app runs from the repository root.
- [x] 1.2 — Verify Flutter formatting, static analysis, and tests pass. *(Verified locally: Dart format check, `flutter analyze`, and `flutter test` passed.)*
- [x] 1.3 — Review and finalize the folder structure. *(Root Flutter app, `backend/`, `docs/`, and `.github/workflows/` are present and reviewed.)*
- [x] 1.4 — Establish a consistent theme, colors, typography, and reusable UI components. *(Implemented in `lib/theme/app_theme.dart`; shared color tokens, Material 3 styles, card and button styles are consumed by the app.)*
- [x] 1.5 — Configure navigation between application screens. *(Home → workflow → analysis → results prototype screens navigate through Flutter routes; widget tests cover the flow. These are previews, not functional resume processing.)*
- [x] 1.6 — Add reusable loading, empty, error, and success states. *(Implemented in `lib/widgets/feedback_state.dart`; widget test verifies each state variant.)*
- [ ] 1.7 — Verify the project can be cloned and run by another team member.

## Phase 2: Define the User Experience

- [ ] 2.1 — Finalize the primary user workflow.
- [x] 2.2 — Design the home screen and resume-analysis entry point. *(Home screen and CTA are implemented and covered by the widget test; team review is still needed.)*
- [x] 2.3 — Design the resume selection and upload screen. *(Selection screen provides metadata, optional target role, processing consent, and connected upload.)*
- [x] 2.4 — Design the analysis progress screen. *(Shows active upload/analysis progress and completion or failure states.)*
- [x] 2.5 — Design the results and recommendations screen. *(Renders returned summary, strengths, improvements, and missing information without inventing a score.)*
- [x] 2.6 — Design error, retry, and unsupported-file states. *(Validation and user-safe API errors are displayed; failed uploads can be retried.)*
- [ ] 2.7 — Review the screens with the team before implementing the full workflow.

## Phase 3: Resume Input

- [x] 3.1 — Choose supported resume formats and define file size limits. *(Local selection accepts PDF and DOCX files from 1 byte through 10 MiB; confirm this policy with the team before implementing uploads.)*
- [x] 3.2 — Implement resume file selection in Flutter. *(Uses the native file picker and retains the selected file handle in app state; no file contents are read or uploaded.)*
- [x] 3.3 — Display the selected filename and file details. *(Shows filename, extension, and formatted file size.)*
- [x] 3.4 — Validate file types and file size. *(Checks extension and byte length, including empty and unmeasurable files.)*
- [x] 3.5 — Allow the user to replace or remove the selected resume. *(Invalid replacements preserve the previous valid selection.)*
- [x] 3.6 — Handle cancellation, invalid files, and permission errors. *(Cancellation preserves the current selection; validation and picker failures show safe messages without local paths.)*
- [x] 3.7 — Add tests for resume selection and validation. *(Unit and widget tests cover format/size boundaries, selection details, replace/remove, cancellation, rejected replacements, and picker failures.)*

## Phase 4: Backend and Resume Processing

- [x] 4.1 — Finalize the API contract and analysis request/response models. *(Multipart contract and structured response schema are documented in `docs/API.md`; mocked API success/error cases pass.)*
- [ ] 4.2 — Configure backend environment variables and local development instructions. *(The `PORT` validation, `.env` loading option, and local instructions are present, but startup with configured environment values has not been verified.)*
- [x] 4.3 — Implement and test resume upload handling. *(In-memory multipart upload success, missing file, unsupported extension, and oversized file cases pass mocked API tests.)*
- [x] 4.4 — Validate uploaded files on the server. *(Extension/signature rejection and the 10 MiB limit pass tests; extracted text is capped at 100,000 characters.)*
- [ ] 4.5 — Implement text extraction for supported resume formats. *(PDF and DOCX extraction implemented in source; verification pending.)*
- [x] 4.6 — Handle scanned PDFs and unsupported documents appropriately. *(Unsupported types and PDFs without extractable text return explicit errors; route behavior is tested. OCR is not implemented.)*
- [ ] 4.7 — Add consistent API errors, request limits, and timeouts. *(Shared JSON errors, upload/text limits, SDK request timeout, and route timeout are implemented; verification pending.)*
- [x] 4.8 — Test the backend independently of the Flutter application. *(Verified locally: `npm run check` and all eight `npm test` API/unit tests passed. A clean `npm ci` has not been verified because the lockfile is stale.)*

## Phase 5: AI Resume Analysis

- [x] 5.1 — Confirm the analysis criteria and expected output with the team. *(User directed us to proceed without waiting for design preferences; default output is a summary, evidence-based strengths/improvements, and missing information, without scores or hiring predictions.)*
- [ ] 5.2 — Finalize the AI provider and model configuration. *(OpenAI Responses API and `OPENAI_MODEL` configuration are implemented; live availability is not verified.)*
- [ ] 5.3 — Securely configure the provider API key on the backend. *(Reads only `OPENAI_API_KEY` from backend environment; no actual key was supplied or used.)*
- [ ] 5.4 — Create a structured analysis prompt. *(Implemented with evidence and non-inference requirements.)*
- [ ] 5.5 — Implement the server-side AI request. *(OpenAI Responses API adapter implemented; live call not made.)*
- [x] 5.6 — Validate the AI response against a defined schema. *(Structured output schema and server-side Zod validation are implemented; malformed analysis results return a tested safe error.)*
- [x] 5.7 — Return actionable feedback, strengths, weaknesses, and improvement suggestions. *(Mocked success returns summary, evidence-backed strengths/improvements, and missing information; no numeric score.)*
- [ ] 5.8 — Handle provider errors, rate limits, invalid responses, and timeouts. *(Safe mappings implemented; runtime verification pending.)*
- [x] 5.9 — Add automated tests using mocked AI responses. *(All eight backend tests pass; provider requests are injected/mocked and no live calls are made.)*
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

- [ ] 8.1 — Confirm API credentials are never included in the mobile app.
- [ ] 8.2 — Avoid logging resume contents or unnecessary personal information.
- [ ] 8.3 — Define whether uploaded resumes and analysis results are stored.
- [ ] 8.4 — Implement appropriate retention and deletion behavior if storage is used.
- [ ] 8.5 — Verify upload validation and backend request limits.
- [ ] 8.6 — Document how resume data is processed and sent to any AI provider.
- [ ] 8.7 — Test that failures do not expose secrets or sensitive document contents.

## Phase 9: Testing and Quality Assurance

- [ ] 9.1 — Add Flutter unit tests for models and services.
- [ ] 9.2 — Add widget tests for the main screens and interactions.
- [ ] 9.3 — Add backend unit and API integration tests.
- [ ] 9.4 — Test invalid uploads, network failures, and AI provider errors.
- [x] 9.5 — Run formatting, static analysis, and all automated tests. *(Verified locally on 22 October 2026: Dart format check, Flutter analysis, all 15 Flutter tests, backend syntax check, and all eight backend tests passed.)*
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
- **Workflow and input (Phases 2–3):** Get team agreement on 2.1 and screen review 2.7. Phase 3 currently implements PDF/DOCX selection up to 10 MiB for local use; confirm that policy before accepting uploads. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Backend upload/extraction/API source and mocked tests are implemented. Clean dependency installation and PDF/DOCX extraction against synthetic files remain to be verified. Complete authentication, retention/deletion, provider data handling, and deployment controls before production use.
- **AI analysis (Phase 5):** Default criteria and a configurable OpenAI Responses implementation are in source. Keep credentials server-side. Verify with mocked provider responses and synthetic resumes; do not use live resumes until privacy/data decisions are complete.
- **Flutter integration and results (Phases 6–7):** The connected upload, progress, response parsing, retry, results display, and mocked success/error UI coverage are implemented and locally tested. Android emulator/device verification remains open.
- **Security and release (Phases 8–10):** Resolve privacy and retention decisions before live resume processing. Release acceptance requires passing local checks, Android device/emulator end-to-end verification, a teammate setup run, and an observed GitHub Actions run. Local CI-equivalent commands do not prove that GitHub CI passed.

## First incomplete task

**1.1 — Confirm the Flutter app runs from the repository root.** The debug APK builds, analysis passes, and widget tests cover the prototype navigation, but `flutter devices` found no Android emulator or physical device. Run `flutter run` from the repository root and verify the home screen on an Android device before checking this item. Task 1.7 also needs another teammate to complete the documented fresh-clone setup and run.
