# Airesume — Development Checklist

Before taking a task, start with the current [project handover](HANDOVER.md), then follow the onboarding sequence in [README.md](../README.md). AI coding agents must follow [AGENTS.md](../AGENTS.md), which requires reading the handover first. Use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) for machine setup; this file tracks feature work.

Use this checklist as the team's source of truth for building the application. Work through tasks in order and check items only when implemented and tested.

## Current progress

- **Task count:** 74 checklist items are complete and 15 remain open, including the new resume-improvement work in Phase 11.
- **Completed:** 1.1–1.6, 2.1–2.6, 3.1–3.7, 4.1–4.8, 5.1–5.9, 6.1–6.7, 7.1–7.4, 7.8, 8.1–8.3, 8.5–8.7, 9.1–9.7, and 10.1–10.7. Evidence is noted beside each checked item. The merged local-workflow branch also provides pasted-text rule checks and a separate metadata-only local file-selection preview.
- **In progress:** 2.7 — screen review is waiting for team feedback.
- **Next:** Have another teammate verify a fresh clone/setup (1.7) and review the screens (2.7). The local Ollama provider completed a synthetic live score-schema request; a live OpenAI request still needs a developer-owned API key. The Pixel 7 AVD must come online before device end-to-end verification.
- **Remaining:** All unchecked items below; see dependency and acceptance gates near the end. Device OCR/upload flow, retention/cache policy, teammate review, and final acceptance remain open. GitHub CI passed for committed code before this local change; it does not cover the current working tree.

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

- [x] 3.1 — Choose supported resume formats and define file size limits. *(Connected and local selection flows accept PDF and DOCX files from 1 byte through 10 MiB; the backend also validates the upload limit. Confirm this policy with the team.)*
- [x] 3.2 — Implement resume file selection in Flutter. *(The connected `file_picker` path reads selected bytes and uploads only after consent; the separate `file_selector` preview retains metadata and does not upload.)*
- [x] 3.3 — Display the selected filename and file details. *(Shows filename, extension, and formatted file size.)*
- [x] 3.4 — Validate file types and file size. *(Checks extension and byte length, including empty and unmeasurable files.)*
- [x] 3.5 — Allow the user to replace or remove the selected resume. *(Invalid replacements preserve the previous valid selection.)*
- [x] 3.6 — Handle cancellation, invalid files, and permission errors. *(Cancellation preserves the current selection; validation and picker failures show safe messages without local paths.)*
- [x] 3.7 — Add tests for resume selection and validation. *(Unit and widget tests cover format/size boundaries, selection details, replace/remove, cancellation, rejected replacements, and picker failures.)*

## Phase 4: Backend and Resume Processing

- [x] 4.1 — Finalize the API contract and analysis request/response models. *(Multipart contract and structured response schema are documented in `docs/API.md`; mocked API success/error cases pass.)*
- [x] 4.2 — Configure backend environment variables and local development instructions. *(Node's `--env-file-if-exists` loaded a temporary sentinel env file; `.env` is ignored by Git; README documents local key setup and restart steps. No real key was used.)*
- [x] 4.3 — Implement and test resume upload handling. *(In-memory multipart upload success, missing file, unsupported extension, and oversized file cases pass mocked API tests.)*
- [x] 4.4 — Validate uploaded files on the server. *(Extension/signature rejection and the 10 MiB limit pass tests; extracted text is capped at 100,000 characters.)*
- [x] 4.5 — Implement text extraction for supported resume formats. *(Verified both extractors using generated, text-only PDF and DOCX documents; no real resume or provider request was used.)*
- [x] 4.6 — Handle scanned PDFs and unsupported documents appropriately. *(Unsupported types and PDFs without extractable text return explicit errors; route behavior is tested. OCR is not implemented.)*
- [x] 4.7 — Add consistent API errors, request limits, and timeouts. *(Backend suite verifies shared error responses, malformed/oversized inputs, the 10 MiB upload limit, 35-second route timeout signal, and timeout/rate-limit mappings.)*
- [x] 4.8 — Test the backend independently of the Flutter application. *(Verified locally: `npm run check` and all thirteen `npm test` API/unit tests passed. `npm install` reports the lockfile is up to date; clean `npm ci` passed in a temporary source snapshot.)*

## Phase 5: AI Resume Analysis

- [x] 5.1 — Confirm the analysis criteria and expected output with the team. *(User directed us to proceed without waiting for design preferences; default output is a summary, evidence-based strengths/improvements, and missing information, without scores or hiring predictions.)*
- [x] 5.2 — Finalize the AI provider and model configuration. *(OpenAI Responses API is configured with `gpt-5.6-terra`; official model documentation confirms Responses and Structured Outputs support. Account-level access still requires the developer's key.)*
- [ ] 5.3 — Securely configure the provider API key on the backend. *(Reads only `OPENAI_API_KEY` from backend environment; no actual key was supplied or used. The app now shows local setup steps when it is missing.)*
- [x] 5.4 — Create a structured analysis prompt. *(Prompt requires resume-grounded feedback, treats resume/role text as untrusted data, and prohibits invented facts, protected-trait inference, ranking, and hiring predictions; request fields are covered by a mocked adapter test.)*
- [x] 5.5 — Implement the server-side AI request. *(OpenAI Responses API adapter sends structured output requests with `store: false`; a mocked provider test verifies the payload and schema parsing. No live request was made.)*
- [x] 5.6 — Validate the AI response against a defined schema. *(Structured output schema and server-side Zod validation are implemented; malformed analysis results return a tested safe error.)*
- [x] 5.7 — Return actionable feedback, strengths, weaknesses, and improvement suggestions. *(Mocked success returns summary, evidence-backed strengths/improvements, and missing information; no numeric score.)*
- [x] 5.8 — Handle provider errors, rate limits, invalid responses, and timeouts. *(Mocked API tests verify safe responses for missing configuration, rate limiting, invalid results, and timeouts; no live provider request was made.)*
- [x] 5.9 — Add automated tests using mocked AI responses. *(All thirteen backend tests pass, including an injected Responses client; no live calls are made.)*
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

- [x] 7.1 — Display an overall resume assessment, if supported by the agreed analysis design. *(The agreed default returns and displays a concise text summary; the design does not use a numeric score.)*
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
- [x] 8.3 — Define whether uploaded resumes and analysis results are stored. *(The current app/API have no persistent database or result history; upload bytes/text are request-scoped in memory and the provider request sets `store: false`. This documents current behavior, not a production privacy approval.)*
- [ ] 8.4 — Implement appropriate retention and deletion behavior if storage is used.
- [x] 8.5 — Verify upload validation and backend request limits. *(Tests verify PDF/DOCX signatures, unsupported extensions, the 10 MiB upload limit, text and target-role constraints, and safe errors.)*
- [x] 8.6 — Document how resume data is processed and sent to any AI provider. *(README, API, and architecture docs describe in-memory extraction, provider submission after consent, `store: false`, and the absence of app persistence.)*
- [x] 8.7 — Test that failures do not expose secrets or sensitive document contents. *(Backend and Flutter tests verify generic safe messages for synthetic resume text and secret-like provider/connection details.)*

## Phase 9: Testing and Quality Assurance

- [x] 9.1 — Add Flutter unit tests for models and services. *(Checker, file-picker, and API-client tests pass as part of the Flutter suite.)*
- [x] 9.2 — Add widget tests for the main screens and interactions. *(Connected selection, paste checks, local file selection, scrolling, and feedback states are covered by passing widget tests.)*
- [x] 9.3 — Add backend unit and API integration tests. *(Thirteen backend tests pass, covering extraction, provider request construction, API health, uploads, limits, and error responses.)*
- [x] 9.4 — Test invalid uploads, network failures, and AI provider errors. *(Backend tests cover unsupported/oversized uploads and provider errors; Flutter API-client tests cover unreachable-server and provider-failure messages.)*
- [x] 9.5 — Run formatting, static analysis, and all automated tests. *(Verified locally on 23 October 2026: repository-wide Dart format check, Flutter analysis, all 49 Flutter tests (one opt-in URL override test skipped by default), backend syntax check, and all 21 backend tests passed.)*
- [x] 9.6 — Build a release-mode Android APK. *(Built successfully with Flutter 3.47.7; output is `build/app/outputs/flutter-apk/app-release.apk`.)*
- [x] 9.7 — Perform end-to-end testing on a real device or emulator. *(Android emulator verified gallery selection, on-device ML Kit OCR for a synthetic resume image, consent, and successful analysis through the local Express backend and qwen3:8b Ollama provider. PDF/DOCX upload and editor/regrade device flows remain open under 6.8 and 11.8.)*
- [ ] 9.8 — Have a teammate test the app using the documented setup guide.
- [ ] 9.9 — Resolve release-blocking defects.

## Phase 10: CI, Documentation, and Delivery

- [x] 10.1 — Verify GitHub Actions runs on pushes and pull requests. *(Read-only GitHub Actions API showed successful push and pull-request runs for `bf7d895` on 23 October 2026; current local changes are newer and unpushed.)*
- [x] 10.2 — Ensure CI runs Flutter tests, analysis, and the Android build. *(Workflow includes `flutter test`, `flutter analyze`, format verification, and Android debug APK build; the run for `bf7d895` succeeded.)*
- [x] 10.3 — Ensure CI runs backend checks and tests. *(Workflow runs clean `npm ci`, `npm run check`, and `npm test`; the run for `bf7d895` succeeded.)*
- [x] 10.4 — Update the README with accurate setup and execution instructions. *(README commands and links were reviewed against the current project.)*
- [x] 10.5 — Update the API contract and architecture documentation. *(Docs describe the implemented analysis API, Flutter integration, consent, and current verification limits.)*
- [x] 10.6 — Update the developer handover and setup checklist. *(Both documents exist and were checked against the current files.)*
- [x] 10.7 — Confirm no credentials, real resumes, or build artifacts are committed. *(Tracked-file path and secret-pattern scans found no real key, resume document, `.env`, or generated build artifact; `.env` is ignored.)*
- [ ] 10.8 — Review outstanding tasks and known limitations with the team.
- [ ] 10.9 — Complete final acceptance testing.
- [ ] 10.10 — Prepare the final demonstration and project submission.

## Phase 11: Resume rating and improvement features

- [x] 11.1 — Define and validate the shared five-category scoring rubric and derived overall score. *(The backend derives the overall score from the five bounded category scores; Dart validates all score bounds and the same arithmetic mean. Rubric documented in `SCORING_RUBRIC.md`.)*
- [x] 11.2 — Return evidence-based score explanations, optional job relevance, and factual rewrite suggestions through OpenAI and Ollama. *(Mocked OpenAI/Ollama tests pass. A real local qwen3:8b text API request returned 200 with five scores, rewrites, and job relevance using synthetic text.)*
- [x] 11.3 — Add five fictional local resume examples with rubric-consistent precomputed scores. *(Flutter model/widget tests validate five entries, fictional labels, score bounds, and average calculation.)*
- [x] 11.4 — Add resume-to-example category comparison and guidance that avoids copying fictional claims. *(Widget test covers category comparison, results suggestions, and editor navigation.)*
- [x] 11.5 — Add an editable working revision, individual suggestion decisions, explicit regrade consent, text-based reanalysis, and score history. *(Widget tests verify accept/reject, exact revised text sent to the API, score delta, and draft retention while navigating.)*
- [x] 11.6 — Add local JPG/PNG OCR with editable preview, empty/error handling, and shared analysis submission. *(Uses on-device ML Kit on Android/iOS; mocked widget tests cover extracted text editing and no-text handling. On the Android emulator, a synthetic image was OCR’d, reviewed, consented, and analyzed successfully through local Ollama.)*
- [x] 11.7 — Verify Flutter/backend tests, analysis, Android debug build, and provider schema behavior after the expansion. *(Final results recorded in `HANDOVER.md`; 49 Flutter tests, 21 backend tests, analysis, format check, debug APK build, and local model responses passed.)*
- [ ] 11.8 — Complete emulator/device end-to-end tests for document upload, image OCR, editing, and regrading.

## Definition of Done

A task can be checked off only when:

- The implementation is present in the repository.
- Relevant tests pass.
- The change has been reviewed by the team when appropriate.
- Documentation is updated if behavior or setup instructions changed.

Do not mark planned features as completed. If a task is blocked, record the blocker and leave the checkbox unchecked.

## Dependencies and acceptance gates

- **Foundation (Phase 1):** Use the [setup checklist](SETUP_CHECKLIST.md) first. Phase 1.1 is accepted after `flutter run` from the repository root reaches the home screen on an emulator or device. Phase 1.7 requires a teammate to complete a fresh clone/setup/run without relying on this machine's local paths.
- **Workflow and input (Phases 2–3):** The user approved proceeding with the default 2.1 workflow; screen review 2.7 still needs team feedback. Phase 3 implements PDF/DOCX selection up to 10 MiB for both the connected analysis path and the metadata-only preview; confirm that policy. Acceptance includes filename/details, replace/remove, validation, cancellation/error behavior, and widget tests.
- **Backend processing (Phase 4):** Backend upload/extraction/API source and mocked tests are implemented. PDF/DOCX extraction passed with synthetic files, and clean `npm ci` passed in a temporary source snapshot. Complete authentication, retention/deletion, provider data handling, and deployment controls before production use.
- **AI analysis (Phase 5):** `gpt-5.6-terra` supports Responses and Structured Outputs per [official model documentation](https://developers.openai.com/api/docs/models/gpt-5.6-terra). The request adapter, prompt, schema, and mocked request are verified. A developer API key is still needed to verify account access and a live request.
- **Flutter integration and results (Phases 6–7):** The connected upload, progress, response parsing, retry, results display, and mocked success/error UI coverage are implemented and locally tested. Android emulator/device verification remains open.
- **Security and release (Phases 8–10):** Current in-memory/no-persistent-storage behavior is documented; decide cache retention and production privacy controls before live resume processing. Release acceptance still requires Android device/emulator end-to-end verification and a teammate setup run. GitHub CI passed for `bf7d895`, not for current uncommitted changes.

## First incomplete task

**1.7 — Verify the project can be cloned and run by another team member.** This requires a teammate to follow the documented setup on a fresh checkout. The integrated app home screen has now been verified on the Pixel 7 emulator for item 1.1.
