# Airesume project handover

Updated 22 October 2026. This describes the current checkout and separates implemented source from verified behavior.

## Purpose and status

Airesume is a Flutter-first app for AI-assisted resume feedback. Phase 3 selection, the Phase 4/5 backend analyzer, and the Phase 6 Flutter upload/result workflow are implemented in source on `codex/phase-3-resume-input`. The backend dependency update to OpenAI SDK 6.49.0 and the existing Zod 4 dependency are reflected in `package-lock.json`; `npm install` reports up to date. Backend configuration tests and local Flutter/backend checks pass. No real OpenAI key has been supplied. Existing local changes must be preserved; do not commit or push without authorization.

The Flutter app requests explicit processing consent, uploads the selected PDF/DOCX and optional target role, shows a loading state, parses structured feedback, and supports retry after safe errors. It also retains the other branch's pasted-text path, which uses local rule-based checks, and its standalone native file-selection preview, which only displays metadata and is not an upload. Android emulator networking to the host backend was verified by requesting `/health` at `10.0.2.2:3000`; a full resume analysis on-device and live provider request were not made. `backend/.env` is absent and ignored by Git. The current server reports `ANALYSIS_UNAVAILABLE` if it starts without `OPENAI_API_KEY`; the Flutter message now tells the developer how to configure it. A successful `/health` response only confirms the server is listening, not that the provider is configured.

## Current architecture

- **Flutter:** The app lives at the repository root. `lib/screens/resume_selection_screen.dart` selects PDF/DOCX files up to 10 MiB, requests processing consent, and gathers an optional target role. `lib/services/resume_analysis_api.dart` sends the multipart upload to `POST /api/v1/analyses`; progress, retryable errors, and structured result screens are implemented. `lib/screens/resume_input_screen.dart` accepts pasted text for local `ResumeChecker` feedback. `lib/resume_upload_screen.dart` is the separate file-selector preview only; it does not submit files. The API base URL can be set with `--dart-define=API_BASE_URL=...`.
- **Backend:** `backend/` is an Express 5 / Zod 4 API. `GET /health` reports service status. `POST /api/v1/analyses` accepts one multipart `resume` file (PDF or DOCX, up to 10 MiB) and optional `targetRole` (up to 200 characters), validates extension/signature/size, extracts text in memory, and calls an injected analyzer. Extracted text is limited to 100,000 characters. Files are not written to disk or logged by application code. PDFs without embedded text return an explicit error; OCR is not implemented.
- **Provider:** `backend/src/providers/resume_analyzer.js` uses OpenAI Responses API with structured output and a configurable `OPENAI_MODEL` default. OpenAI's model page lists `gpt-5.6-terra` as supporting Responses and Structured Outputs. It reads `OPENAI_API_KEY` only on the backend, uses `store: false`, and has a 30-second SDK timeout. No real key or model call was used. Output has summary, evidence-based strengths and improvements, and missing-information notes; no numeric score or hiring prediction.
- **Configuration:** `npm start` runs Node's `--env-file-if-exists=.env` from `backend/`; this was verified with a temporary sentinel value and no real secret. `backend/.gitignore` excludes `.env`; no local `backend/.env` exists. Keep keys out of Flutter and Android.
- **Tests and dependencies:** `npm install` succeeded and reported the lockfile up to date; `npm run check` and all eleven backend tests pass. Tests cover shared API errors, upload limits, the route timeout signal, and safe timeout/rate-limit mappings. Synthetic text-only PDF and DOCX documents both extracted their expected text through the production extractor. During this merge, `flutter pub get` resolved the union of `file_picker`, `file_selector`, and `http`; `flutter analyze` passed and all 38 Flutter tests passed (one opt-in API override test is skipped unless its define is supplied). Clean `npm ci` was not run. No commit is authorized.
- **Privacy/production:** Authentication, consent, retention/deletion, provider data handling, and deployment controls remain open before processing real resumes in production. `store: false` does not replace a review of current provider terms and project privacy requirements.
- **CI:** `.github/workflows/flutter.yml` runs Flutter and backend CI on pushes and pull requests. GitHub Actions has not been observed for this branch.

## Repository structure

- `lib/`, `test/` — root Flutter app and widget tests.
<<<<<<< HEAD
- `android/` — generated Android host project.
- `backend/src/`, `backend/test/` — Express/Zod service, provider interface placeholder, and HTTP API tests.
- `docs/` — setup, development, architecture, API contract, handover, and roadmap.
- `.github/workflows/flutter.yml` — Flutter and backend CI jobs.
- `AGENTS.md` — required onboarding and working instructions for AI coding agents.

More detail: [architecture](ARCHITECTURE.md), [API contract](API.md), [development notes](DEVELOPMENT.md), [setup checklist](SETUP_CHECKLIST.md), and [development checklist](DEVELOPMENT_CHECKLIST.md).

## Completed

- Retained the root Flutter scaffold and replaced the counter demo with the Airesume foundation screen.
- Documented and pinned the recommended Flutter 3.47.7 / Dart 3.13.5 toolchain in `pubspec.yaml` and `.fvmrc`.
- Added widget tests for the initial screen and both resume input entry points.
- Added an Express/Zod backend foundation with health, request validation, consistent errors, size limit, and API tests.
- Added Flutter and backend CI jobs, architecture/API documentation, environment guidance, this handover, and a teammate checklist.
- The existing Git repository and history are intact. Check the live status, branch, and recent commits before working; this handover is not a substitute for Git inspection.
- Added the working text-input workflow: pasted resume text, optional target role, sample resume convenience action, local rule-based checks, editable input, and a reusable results screen.
- Added the visible Upload resume entry point, later replaced by local native PDF/DOCX selection with filename/size, replace/remove, non-destructive cancellation, validation, and paste-text fallback.
- Verified that the checker accepts plain text independently of the input widgets and that the widget flow responds to the supplied resume content.
- Removed overscroll stretching across the app; Android home top/bottom drag regression tests also verify normal scrolling, and a Windows test verifies the scrollbar remains.

## Incomplete features

- File upload, parsing/extraction, upload progress, and connecting files to checks are not implemented. The local picker has cancellation, validation, and retry/error states, but does not verify document integrity or extract text.
- The current results screen reports only local rule-based checks; resume scoring, recommendations, history, and server-side AI analysis are not implemented.
- Authentication, API URL configuration in Flutter, and a production API contract for document uploads.
- Data retention/deletion policy and supported document limits.
- Real analysis endpoint and server-side OpenAI adapter using `gpt-5-mini`, structured output validation, timeouts, and mocked provider tests.
- Production Android application ID and emulator/physical-device run-through.
- Successful GitHub Actions run. Local checks passed, but GitHub CI has not been observed.

## Local file selection and next extraction work

Pasted text remains a permanent alternative. **Upload resume → Choose file** now opens the platform file dialog. The current local picker accepts PDF/DOCX filenames (case-insensitive) with a nonzero size up to 5 MiB (5,242,880 bytes), displayed as 5 MiB in the UI. These are initial picker defaults from the earlier proposal; team confirmation and the future server-side upload contract remain open (checklist 3.1).

A selection shows filename and size. Replace/remove are available; cancellation and invalid replacement preserve the current selection. Errors offer retry or **Paste resume instead**. Selection state is held for the current screen session and not persisted by app code. The native plugin may read/copy files into platform app cache during selection; this is not a guarantee of metadata-only access or immediate cache deletion. No resume content or native error details are logged or sent to the backend/provider.

Extension/size validation does not detect corrupt or scanned documents. Next steps:

1. Give extraction a dedicated service boundary that converts valid PDF/DOCX to plain text without provider calls or content logs.
2. Reuse `ResumeChecker.check(resumeText, targetRole:)` and `ResumeFeedback`/`ResumeResultsScreen`; do not create another checker or results flow.
3. Handle corrupt, empty-extracted, and scanned documents with actionable errors and paste fallback. Scanned PDFs need OCR or an explicit unsupported result.
4. Add extraction and extraction-to-checker tests. File-based checking is accepted only when valid PDF/DOCX reach the same feedback screen as pasted text.
5. Confirm upload limits, authentication, cache/retention/deletion, and server responsibilities before live upload work.

The current local checks are deliberately different from the future AI product. `ResumeChecker` looks for common sections, bullet points, and measurable experience entirely on-device. It does not score hiring potential, claim ATS compatibility, or call a provider. The original server-side AI plan remains future work: secure backend credentials, a defined prompt and response schema, timeouts, provider error handling, and mocked provider tests must be completed before any live AI request.
=======
- `android/` — generated Android host project; application ID is still `com.example.airesume`.
- `backend/src/`, `backend/test/` — Express API, PDF/DOCX extraction, provider adapter, and mocked API tests.
- `docs/` — setup, development, architecture, API contract, handover, and checklists.
- `.github/workflows/flutter.yml` — Flutter and backend CI.
- `AGENTS.md` — required onboarding and working instructions; read `docs/HANDOVER.md` first on each project task.
>>>>>>> bf7d89571cc4492edd42705af50c5564a64c57d5

## Setup and run

Use Flutter 3.47.7 stable with Dart 3.13.5, Node.js 22.9 or newer, Git, VS Code/Flutter extension, Android Studio/SDK, an emulator/device, and Java 17 for Android builds. Flutter setup from a fresh clone:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Backend setup (see README for secure PowerShell key entry):

```powershell
cd backend
npm install
npm run check
npm test
npm start
```

`npm start` loads an optional ignored `backend/.env`. Copy `.env.example` and set a server-side `OPENAI_API_KEY`; `OPENAI_MODEL` is optional and defaults to `gpt-5.6-terra`. Never put provider credentials in Flutter or commit a real `.env`. Real analysis requests can incur usage charges. Do not use a real resume for routine tests.

## Verification record

**Verified locally on 22 October 2026:** `npm install` (up to date, zero audit findings), `npm run check`, eleven backend tests, Dart formatting, `flutter pub get`, `flutter analyze`, all 38 Flutter tests (one opt-in API override test skipped in the default run), and a separate passing `API_BASE_URL` override test. A test confirmed Node loads env files without printing their values. `git check-ignore` confirms `backend/.env` is ignored. Windows and Android emulator both reached the host health endpoint; emulator request to `http://10.0.2.2:3000/health` returned `{"status":"ok"}`. After the merge, the current app also built, installed, and launched on Pixel 7; the resumed activity and Android UI hierarchy confirmed the integrated home screen and its connected analysis, pasted-text, and local file-selection actions.

**Not verified:** `npm ci`, live OpenAI credentials/provider request, full Android upload/analysis flow, and GitHub CI. The active port 3000 listener was already running; a second `npm start` reported `EADDRINUSE`, so preserve that process and restart it from the intended terminal after setting a developer-owned key.

## Next steps

1. Have another teammate follow the fresh-clone setup and confirm the app runs (checklist item 1.7).
2. Add the developer's own `OPENAI_API_KEY` to the backend process environment or ignored `backend/.env`, restart the server, and verify one intentional test analysis. Never paste the key into Flutter or commit it.
3. Finish the full upload flow on the emulator.
4. Run `npm ci` from the current lockfile, then inspect GitHub CI separately.
5. Resolve authentication, retention/deletion, provider data handling, and production deployment decisions before production use.

## Keeping the handover current

<<<<<<< HEAD
When architecture, verified functionality, environment requirements, test results, or the next recommended task changes, update this document and the matching development checklist. Keep `SETUP_CHECKLIST.md` focused on machine setup and running the project. Mark roadmap items complete only after implementation and relevant verification; record CI status separately from local checks.

## Fileupload integration review — 22 October 2026

Reconciled Fileupload with origin/main at dde7a38. Kept main’s paste/check/results navigation, scroll behavior, file_selector adapter and selection screen; retained Fileupload’s 5 MiB local limit. Removed the superseded inline ResumeInput widget and file_picker dependency. Existing main tests cover selection, validation, cancellation, replacement, removal, errors and disposal. No upload, parsing or AI calls were added. Original checkout Git metadata is read-only; merge preparation and verification occurred in a temporary clone.

Review verification: Dart format check passed for 11 files and whitespace/conflict-marker checks passed. Dependency resolution was blocked: file_selector is absent from the offline cache and online retrieval did not complete. Analysis, tests, APK build and native device behavior are therefore unverified for this merge.
=======
When architecture, verified behavior, environment requirements, test results, or the next task changes, update this file and the matching development checklist. Mark checklist items complete only after implementation and relevant verification; report local and GitHub CI results separately.
>>>>>>> bf7d89571cc4492edd42705af50c5564a64c57d5
