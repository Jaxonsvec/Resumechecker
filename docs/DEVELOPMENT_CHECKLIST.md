# Airesume — Development Checklist

Before taking a task, read the agent guidance in [AGENTS.md](../AGENTS.md), the contributor entry point in [README.md](../README.md), and the current [project handover](HANDOVER.md). Use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) for machine setup; this file tracks feature work.

Use this checklist as the team's source of truth for building the application. Work through tasks in order and check items only when implemented and tested.

## Current progress

- **Completed:** 1.2, 1.3, 2.2, 4.8, 9.5, 10.4, 10.5, and 10.6. Evidence is noted beside each checked item.
- **In progress:** None recorded. Do not infer an owner or active task from an unchecked box.
- **Next:** 1.1 — launch the app on an emulator or device from the repository root. The debug APK was built, but device launch is unverified.
- **Remaining:** All unchecked items below; see the dependency and acceptance gates near the end of this document.
- **Milestone 2 verified:** The current app accepts pasted text, runs independent local checks, and displays reusable feedback. Flutter tests passed 5 tests on 22 October 2026. Pasted text is a permanent input method; file selection, validation, extraction, and connecting extracted text remain planned for the second input method.

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
- [x] 2.2 — Design the home screen and resume-analysis entry point. *(Home screen and CTA are implemented and covered by the widget test; team review is still needed.)*
- [ ] 2.3 — Design the resume selection and upload screen.
- [ ] 2.4 — Design the analysis progress screen.
- [ ] 2.5 — Design the results and recommendations screen.
- [ ] 2.6 — Design error, retry, and unsupported-file states.
- [ ] 2.7 — Review the screens with the team before implementing the full workflow.

## Phase 3: Resume Input

- [ ] 3.1 — Choose supported resume formats and define file size limits.
- [ ] 3.2 — Implement resume file selection in Flutter.
- [ ] 3.3 — Display the selected filename and file details.
- [ ] 3.4 — Validate file types and file size.
- [ ] 3.5 — Allow the user to replace or remove the selected resume.
- [ ] 3.6 — Handle cancellation, invalid files, and permission errors.
- [ ] 3.7 — Add tests for resume selection and validation.

### File-upload handoff plan

These are proposals for the next teammate, not completed work:

- Connect a PDF/DOCX picker to `ResumeInputScreen` beside the existing pasted-text field. Keep cancellation non-destructive and show selected filename/size before continuing.
- Propose PDF and DOCX as the first supported formats with a 10 MB per-file limit. Confirm these choices before implementation; they are not yet a product contract.
- Keep extension/size validation at the input boundary. Give extraction its own service responsibility for converting valid files to plain text, reporting corrupt/unsupported files, and avoiding resume-content logs.
- On successful extraction, pass the resulting text and optional role to `ResumeChecker.check(...)`, then pass `ResumeFeedback` to `ResumeResultsScreen`. Uploaded and pasted resumes must share this flow.
- Define behavior for picker cancellation, invalid/oversized files, extraction errors, empty documents, and scanned PDFs without selectable text. Scanned PDFs require OCR or a clear unsupported state.
- Add picker, validation-boundary, extraction-failure, empty/scanned-document, and extracted-text-to-checker tests. Acceptance requires valid PDF/DOCX files to reach the same feedback screen as pasted text.

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
- [x] 9.2 — Add widget tests for the main screens and interactions. (The input-to-feedback flow, validation, sample resume, and feedback copy are covered.)
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
- **Workflow and input (Phases 2–3):** Get team agreement on 2.1 and screen review 2.7. Agree file formats and limits in 3.1 before choosing a picker or accepting files. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Finalize 4.1 and the privacy/data decisions in 8.3–8.6 before accepting real resumes. Upload handling, file validation, extraction, unsupported/scanned-document behavior, size limits, errors, and timeouts must be tested independently before integration.
- **AI analysis (Phase 5):** Confirm criteria and provider/model (5.1–5.2) before implementing prompts or requests. Keep credentials server-side. Define and validate the response schema; use mocked provider responses for routine tests and synthetic resumes for evaluation.
- **Flutter integration and results (Phases 6–7):** These depend on a stable API request/response contract, working backend analysis, and file input. End-to-end acceptance requires upload progress, response parsing, useful failures/retry, results display, and mocked success/error UI coverage.
- **Security and release (Phases 8–10):** Resolve privacy and retention decisions before live resume processing. Release acceptance requires passing local checks, Android device/emulator end-to-end verification, a teammate setup run, and an observed GitHub Actions run. Local CI-equivalent commands do not prove that GitHub CI passed.

## First incomplete task

**1.1 — Confirm the Flutter app runs from the repository root.** The debug APK builds and the widget test passes, but the app has not been launched on an emulator or physical device. Run `flutter run` from the repository root and verify the home screen on a device before checking this item.
