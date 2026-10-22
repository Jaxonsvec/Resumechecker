# Airesume — Development Checklist

Before taking a task, read the agent guidance in [AGENTS.md](../AGENTS.md), the contributor entry point in [README.md](../README.md), and the current [project handover](HANDOVER.md). Use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) for machine setup; this file tracks feature work.

Use this checklist as the team's source of truth for building the application. Work through tasks in order and check items only when implemented and tested.

## Current progress

- **Completed:** 1.2, 1.3, 2.2, 3.2–3.7, 4.8, 9.1, 9.2, 9.5, 10.4, 10.5, and 10.6. Evidence is noted beside each checked item.
- **In progress:** None recorded. Do not infer an owner or active task from an unchecked box.
- **Next:** 1.1 — launch the app on an emulator or device from the repository root. The debug APK was built, but device launch is unverified.
- **Remaining:** All unchecked items below; see the dependency and acceptance gates near the end of this document.
- **Milestone 2 verified:** The current app accepts pasted text, runs independent local checks, and displays reusable feedback. Flutter tests passed 5 tests on 22 October 2026. Pasted text is a permanent input method. Local PDF/DOCX selection and basic validation now pass focused tests; extraction and connecting extracted text remain planned for the second input method.

## Phase 1: Project Foundation

- [ ] 1.1 — Confirm the Flutter app runs from the repository root.
- [x] 1.2 — Verify Flutter formatting, static analysis, and tests pass. *(Verified locally: Dart format check, `flutter analyze`, and `flutter test` passed.)*
- [x] 1.3 — Review and finalize the folder structure. *(Root Flutter app, `backend/`, `docs/`, and `.github/workflows/` are present and reviewed.)*
- [ ] 1.4 — Establish a consistent theme, colors, typography, and reusable UI components.
- [ ] 1.5 — Configure navigation between application screens.
- [ ] 1.6 — Add reusable loading, empty, error, and success states.
- [ ] 1.7 — Verify the project can be cloned and run by another team member.

## Phase 2: Define the User Experience

- [ ] 2.1 — Finalize the primary user workflow.
- [x] 2.2 — Design the home screen and resume-analysis entry point. *(Home screen and CTA are implemented and covered by widget tests. Android top/bottom drag tests verify the scrolling content no longer stretches; team review is still needed.)*
- [ ] 2.3 — Design the resume selection and upload screen.
- [ ] 2.4 — Design the analysis progress screen.
- [ ] 2.5 — Design the results and recommendations screen.
- [ ] 2.6 — Design error, retry, and unsupported-file states.
- [ ] 2.7 — Review the screens with the team before implementing the full workflow.

## Phase 3: Resume Input

- [ ] 3.1 — Choose supported resume formats and define file size limits.
- [x] 3.2 — Implement resume file selection in Flutter. *(Native picker is connected to the home upload entry; local tests passed.)*
- [x] 3.3 — Display the selected filename and file details. *(Filename and size appear after selection; widget test passed.)*
- [x] 3.4 — Validate file types and file size. *(PDF/DOCX extensions and nonzero size through 10 MiB; boundary tests passed.)*
- [x] 3.5 — Allow the user to replace or remove the selected resume. *(Replace/remove controls and preservation on invalid replacement; widget test passed.)*
- [x] 3.6 — Handle cancellation, invalid files, and permission errors. *(Cancellation, validation/access errors, retry, and async disposal tests passed.)*
- [x] 3.7 — Add tests for resume selection and validation. *(Service and widget selection tests passed locally on 22 October 2026.)*

### File-selection status and extraction handoff

- **Upload resume → Choose file** opens a native PDF/DOCX picker with an initial 10 MiB limit (10,485,760 bytes, displayed as 10 MB). These local defaults implement the previous proposal; team confirmation and future server-side contract remain open in 3.1.
- The selected filename/size, replace/remove, non-destructive cancellation and invalid replacement, empty/oversized/unsupported-file errors, access-error retry, and paste-text fallback are implemented and covered by local tests. Native dialog behavior must also be checked on a device.
- File content integrity, text extraction, corrupt/scanned-document handling, and extracted-text-to-checker integration remain incomplete. Selection alone does not make file-based analysis work.
- Implement extraction as a dedicated service. Pass successful text and optional role to the existing `ResumeChecker` and `ResumeResultsScreen` flow.
- Add corrupt-file, empty-extracted-text, scanned-PDF, and extraction-to-checker tests. Valid PDF/DOCX must reach the shared feedback screen before claiming file-based checking.
- The native picker may read/copy selected files into platform app cache. Agree cache/retention/deletion rules before live processing; app code does not log or transmit contents.

## Phase 4: Backend and Resume Processing

- [ ] 4.1 — Finalize the API contract and analysis request/response models.
- [ ] 4.2 — Configure backend environment variables and local development instructions. *(The `PORT` validation, `.env` loading option, and local instructions are present, but startup with configured environment values has not been verified.)*
- [ ] 4.3 — Implement and test resume upload handling.
- [ ] 4.4 — Validate uploaded files on the server.
- [ ] 4.5 — Implement text extraction for supported resume formats.
- [ ] 4.6 — Handle scanned PDFs and unsupported documents appropriately.
- [ ] 4.7 — Add consistent API errors, request limits, and timeouts. *(Consistent errors and a JSON size limit exist; request timeouts are not implemented.)*
- [x] 4.8 — Test the backend independently of the Flutter application. *(Verified locally: `npm ci`, `npm run check`, and all four `npm test` API tests passed.)*

The current `ResumeChecker` is intentionally local and rule-based: it checks common sections, bullet points, and quantified experience without a provider, hiring score, or ATS claim. It is separate from the future server-side AI work below, which still requires secure credentials, prompts, schema validation, timeouts, provider error handling, and mocked tests.

## Phase 5: AI Resume Analysis

- [ ] 5.1 — Confirm the analysis criteria and expected output with the team.
- [ ] 5.2 — Finalize the AI provider and model configuration.
- [ ] 5.3 — Securely configure the provider API key on the backend.
- [ ] 5.4 — Create a structured analysis prompt.
- [ ] 5.5 — Implement the server-side AI request.
- [ ] 5.6 — Validate the AI response against a defined schema.
- [ ] 5.7 — Return actionable feedback, strengths, weaknesses, and improvement suggestions.
- [ ] 5.8 — Handle provider errors, rate limits, invalid responses, and timeouts.
- [ ] 5.9 — Add automated tests using mocked AI responses.
- [ ] 5.10 — Evaluate the results with sample or synthetic resumes before release.

## Phase 6: Connect Flutter to the Backend

- [ ] 6.1 — Implement a reusable API client.
- [ ] 6.2 — Configure the backend URL for local development and deployment.
- [ ] 6.3 — Connect resume selection to the upload endpoint.
- [ ] 6.4 — Display progress while analysis is running.
- [ ] 6.5 — Parse and validate analysis responses in Flutter.
- [ ] 6.6 — Display useful error messages and allow retrying failed requests.
- [ ] 6.7 — Test the complete upload-to-analysis workflow.
- [ ] 6.8 — Verify the workflow on an Android emulator or physical device.

## Phase 7: Results and User Features

- [ ] 7.1 — Display an overall resume assessment, if supported by the agreed analysis design.
- [ ] 7.2 — Display resume strengths and areas for improvement.
- [ ] 7.3 — Display actionable recommendations and suggested revisions.
- [ ] 7.4 — Organize feedback into readable sections.
- [ ] 7.5 — Allow users to return to the results after navigating between screens, if required.
- [ ] 7.6 — Implement analysis history or saved results if required by the project scope.
- [ ] 7.7 — Add accessibility, responsive layouts, and useful empty states.
- [ ] 7.8 — Verify the results UI using mocked responses and error cases.

## Phase 8: Security and Privacy

- [ ] 8.1 — Confirm API credentials are never included in the mobile app.
- [ ] 8.2 — Avoid logging resume contents or unnecessary personal information.
- [ ] 8.3 — Define whether uploaded resumes and analysis results are stored.
- [ ] 8.4 — Implement appropriate retention and deletion behavior if storage is used.
- [ ] 8.5 — Verify upload validation and backend request limits.
- [ ] 8.6 — Document how resume data is processed and sent to any AI provider.
- [ ] 8.7 — Test that failures do not expose secrets or sensitive document contents.

## Phase 9: Testing and Quality Assurance

- [x] 9.1 — Add Flutter unit tests for models and services. (The plain-text ResumeChecker has tests for passing checks, specific failures, and retained source/role data.)
- [x] 9.2 — Add widget tests for the main screens and interactions. (The input-to-feedback flow, file selection, validation, sample resume, feedback copy, Android home edge drags, and desktop scrollbar preservation are covered; all 21 Flutter tests passed on 22 October 2026.)
- [ ] 9.3 — Add backend unit and API integration tests.
- [ ] 9.4 — Test invalid uploads, network failures, and AI provider errors.
- [x] 9.5 — Run formatting, static analysis, and all automated tests. *(Verified locally for the current implementation: Flutter format/analyze/widget tests and backend syntax/API tests passed.)*
- [ ] 9.6 — Build a release-mode Android APK.
- [ ] 9.7 — Perform end-to-end testing on a real device or emulator.
- [ ] 9.8 — Have a teammate test the app using the documented setup guide.
- [ ] 9.9 — Resolve release-blocking defects.

## Phase 10: CI, Documentation, and Delivery

- [ ] 10.1 — Verify GitHub Actions runs on pushes and pull requests.
- [ ] 10.2 — Ensure CI runs Flutter tests, analysis, and the Android build.
- [ ] 10.3 — Ensure CI runs backend checks and tests.
- [x] 10.4 — Update the README with accurate setup and execution instructions. *(README commands and links were reviewed against the current project.)*
- [x] 10.5 — Update the API contract and architecture documentation. *(Docs describe the implemented health/validation routes and clearly label analysis as unimplemented.)*
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
- **Workflow and input (Phases 2–3):** Get team agreement on 2.1 and screen review 2.7. Local selection currently uses initial PDF/DOCX and 10 MiB defaults; finalize file formats and limits with the team in 3.1 before file processing/upload work. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Finalize 4.1 and the privacy/data decisions in 8.3–8.6 before accepting real resumes. Upload handling, file validation, extraction, unsupported/scanned-document behavior, size limits, errors, and timeouts must be tested independently before integration.
- **AI analysis (Phase 5):** Confirm criteria and provider/model (5.1–5.2) before implementing prompts or requests. Keep credentials server-side. Define and validate the response schema; use mocked provider responses for routine tests and synthetic resumes for evaluation.
- **Flutter integration and results (Phases 6–7):** These depend on a stable API request/response contract, working backend analysis, and file input. End-to-end acceptance requires upload progress, response parsing, useful failures/retry, results display, and mocked success/error UI coverage.
- **Security and release (Phases 8–10):** Resolve privacy and retention decisions before live resume processing. Release acceptance requires passing local checks, Android device/emulator end-to-end verification, a teammate setup run, and an observed GitHub Actions run. Local CI-equivalent commands do not prove that GitHub CI passed.

## First incomplete task

**1.1 — Confirm the Flutter app runs from the repository root.** The debug APK builds and the widget test passes, but the app has not been launched on an emulator or physical device. Run `flutter run` from the repository root and verify the home screen on a device before checking this item.
