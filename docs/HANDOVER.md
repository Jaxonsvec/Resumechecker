# Airesume project handover

Updated 22 October 2026. This describes the files in the current checkout, not the intended future product.

## Purpose and status

Airesume is a Flutter-first mobile app foundation for AI-assisted resume feedback. The current app supports pasted resume text through local, rule-based checks and a feedback screen. Pasted text is a permanent input method; planned file upload is a second input method that should feed the same checker and results flow. Server-side AI analysis is not implemented. Local PDF/DOCX selection and basic extension/size validation are implemented. Document extraction and connecting extracted text to the existing analysis flow are the next planned steps. The backend exposes health and request validation but deliberately returns 501 for valid analysis requests.

## Current architecture

- **Flutter app:** The Flutter project lives at the repository root. `lib/main.dart` contains the Material 3 app shell, theme, two input entry points, pasted-text input form, and navigation into the feedback screen. Paste resume is working; Upload resume opens `lib/resume_upload_screen.dart`, with native selection provided by `lib/resume_file_picker.dart` through Flutter's `file_selector`. It displays filename/size, supports replace/remove, and handles cancellation, invalid selections, and access errors. It does not extract text or run file-based checks. `lib/resume_checker.dart` accepts plain resume text independently of input widgets and returns a reusable `ResumeFeedback` model. `lib/resume_results_screen.dart` renders the same model that future PDF/DOCX extraction should use. `test/widget_test.dart` covers both input entry points and the feedback flow; `test/resume_checker_test.dart` covers passing and failing local checks.
- **Android:** `android/` is the generated Android host project. The current application ID is still `com.example.airesume`. `android/local.properties` is local machine configuration and is ignored.
- **Backend:** `backend/` is an Express 5 API using Zod 4 schemas. `src/server.js` validates `PORT` (default 3000, range 1–65535); `npm start` uses Node 22.9+'s `--env-file-if-exists` option to load an optional local `.env`. `GET /health` returns `{"status":"ok"}`. `POST /api/v1/analyses` accepts JSON with `resumeText` (1–100,000 trimmed characters) and optional `targetRole` (up to 200 characters); valid requests return HTTP 501. It does not analyze, retain, extract, or upload a resume. JSON request size is limited to 300 KB and errors use a shared JSON structure. No application-specific analysis timeout is configured.
- **Provider:** The initial decision remains OpenAI `gpt-5-mini`. `backend/src/providers/resume_analyzer.js` only documents the future interface. There is no OpenAI SDK, API call, provider key validation, or AI result today. `backend/.env.example` contains placeholder values only; `OPENAI_API_KEY` is currently unused. Never place a provider key in Flutter or commit a real `.env`.
- **CI and docs:** `.github/workflows/flutter.yml` runs Flutter checks, Android debug build, and backend checks on pushes and pull requests. CI has not been run on GitHub.

## Repository structure

- `lib/`, `test/` — root Flutter app and widget tests.
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

## Incomplete features

- File upload, parsing/extraction, upload progress, and connecting files to checks are not implemented. The local picker has cancellation, validation, and retry/error states, but does not verify document integrity or extract text.
- The current results screen reports only local rule-based checks; resume scoring, recommendations, history, and server-side AI analysis are not implemented.
- Authentication, API URL configuration in Flutter, and a production API contract for document uploads.
- Data retention/deletion policy and supported document limits.
- Real analysis endpoint and server-side OpenAI adapter using `gpt-5-mini`, structured output validation, timeouts, and mocked provider tests.
- Production Android application ID and emulator/physical-device run-through.
- Successful GitHub Actions run. Local checks passed, but GitHub CI has not been observed.

## Local file selection and next extraction work

Pasted text remains a permanent alternative. **Upload resume → Choose file** now opens the platform file dialog. The current local picker accepts PDF/DOCX filenames (case-insensitive) with a nonzero size up to 10 MiB (10,485,760 bytes), displayed as 10 MB in the UI. These are initial picker defaults from the earlier proposal; team confirmation and the future server-side upload contract remain open (checklist 3.1).

A selection shows filename and size. Replace/remove are available; cancellation and invalid replacement preserve the current selection. Errors offer retry or **Paste resume instead**. Selection state is held for the current screen session and not persisted by app code. The native plugin may read/copy files into platform app cache during selection; this is not a guarantee of metadata-only access or immediate cache deletion. No resume content or native error details are logged or sent to the backend/provider.

Extension/size validation does not detect corrupt or scanned documents. Next steps:

1. Give extraction a dedicated service boundary that converts valid PDF/DOCX to plain text without provider calls or content logs.
2. Reuse `ResumeChecker.check(resumeText, targetRole:)` and `ResumeFeedback`/`ResumeResultsScreen`; do not create another checker or results flow.
3. Handle corrupt, empty-extracted, and scanned documents with actionable errors and paste fallback. Scanned PDFs need OCR or an explicit unsupported result.
4. Add extraction and extraction-to-checker tests. File-based checking is accepted only when valid PDF/DOCX reach the same feedback screen as pasted text.
5. Confirm upload limits, authentication, cache/retention/deletion, and server responsibilities before live upload work.

The current local checks are deliberately different from the future AI product. `ResumeChecker` looks for common sections, bullet points, and measurable experience entirely on-device. It does not score hiring potential, claim ATS compatibility, or call a provider. The original server-side AI plan remains future work: secure backend credentials, a defined prompt and response schema, timeouts, provider error handling, and mocked provider tests must be completed before any live AI request.

## Setup and run

Use Flutter 3.47.7 stable with Dart 3.13.5, Git, VS Code with the Flutter extension, Android Studio/SDK, an emulator or Android device, and Java 17 for Android builds. On a fresh Windows clone:

```powershell
git clone https://github.com/Jaxonsvec/Resumechecker.git Airesume
cd Airesume
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run
```

If Flutter is not on PATH, call `<Flutter SDK>\bin\flutter.bat`. In VS Code, run **Flutter: Change SDK** or configure `dart.flutterSdkPath` in User Settings. Keep that personal path and `android/local.properties` out of Git.

To run the optional backend, install Node.js 22.9 or newer, then:

```powershell
cd backend
npm ci
npm start
```

The backend defaults to port 3000. Set `$env:PORT = "3001"` before starting to choose another port. `npm start` loads `backend/.env` if present; `backend/.env.example` contains placeholders, not usable credentials. The server currently validates `PORT` only. No key is needed for its routes. The `OPENAI_API_KEY` placeholder is unused until provider integration exists; any eventual key belongs on the backend only and may incur usage charges.

For a step-by-step teammate flow, use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md).

## Verification performed locally

The following results were recorded during local foundation verification on 20 October 2026 (not rerun during later documentation-only updates). Environment: Flutter 3.47.7 stable, Dart 3.13.5, Node.js v24.21.0, npm 11.19.0. Flutter dependency resolution and backend dependency installation completed successfully.

| Check | Result |
| --- | --- |
| `flutter pub get` | Passed; lockfile resolved. Five packages have newer versions outside the current dependency constraints; no broad upgrade was made. |
| `dart format lib test` | Passed for the current app; five Dart files formatted with no changes on the final verification. |
| `dart format --output=none --set-exit-if-changed lib test` | Passed after formatting. |
| `flutter analyze` | Passed; no issues found. |
| `flutter test` | Passed; 5 tests covering the pasted input, feedback screen, and independent checker behavior. |
| `flutter build apk --debug` | Passed; created `build/app/outputs/flutter-apk/app-debug.apk`. |
| `npm ci` | Passed; 66 packages installed, audit reported 0 vulnerabilities. |
| `npm run check` | Passed; backend syntax checks. |
| `npm test` | Passed; 4 API tests. |
| `git diff --check` | Passed for tracked changes. New files were also checked for trailing whitespace before handover. |

Milestone 2 verification was rerun locally on 22 October 2026 after the checker/results refactor: `dart format lib test`, `flutter analyze`, `flutter test` (5 passed), and `git diff --check` passed. The emulator workflow was manually reported as working by the teammate; this session did not launch `flutter run` itself.

File-selection verification on 22 October 2026 used an isolated Flutter 3.47.7 / Dart 3.13.5 SDK because the system SDK was older than this repository requires. `dart format`, `flutter analyze`, and the 19 tests covering existing checks and file selection passed. `flutter build apk --debug` also passed with the native selector plugin. The native file dialog has not been exercised manually on a device. GitHub CI has not been observed.

An initial test attempt exposed issues in the milestone-2 tests and was corrected before the passing rerun. The backend tests require loopback access; they passed when run with it available. `flutter run` on an emulator/device and GitHub CI were not part of that verification.

## Known issues and limitations

- The UI accepts pasted text for checks and selects PDF/DOCX locally, but does not parse files, upload them, or start server-side analysis. The backend's 501 route is validation-only.
- The current results are local rule-based checks, not an AI result, hiring score, ATS score, recommendation engine, or history feature.
- Future file-based checks must add extraction, handle empty/corrupt/scanned documents, and pass extracted text into the existing checker/results flow. Extension/size validation alone does not establish document validity.
- The Android application ID is still Flutter's generated example ID.
- `flutter doctor -v`, `flutter run` on an emulator/device, and GitHub Actions have not been verified in the recorded setup checks.
- No real API key or resume data was used. There were no live OpenAI calls.
- Dependency notices report available newer versions, but the committed lockfiles currently resolve successfully.

## Prioritized next steps

1. **Development checklist 3.1:** confirm initial PDF/DOCX picker defaults and limits with the team; local selection/validation tests now pass (3.2–3.7). Native dialog/device verification is tracked separately.
2. **Development checklist 4.3–4.6:** decide whether extraction is local or backend-owned, handle corrupt/empty/scanned documents, and connect successful extracted text to `ResumeChecker` and `ResumeResultsScreen`.
3. **Development checklist 1.1 and 1.7:** launch the app on an emulator and have another teammate follow the setup guide and confirm a fresh clone can run.
4. Before accepting real resumes, agree on authentication, upload limits, retention, and deletion; record decisions in `docs/API.md` and `docs/ARCHITECTURE.md`.
5. Complete the separate server-side AI plan in Phase 5 before claiming AI analysis; then replace the Android example ID and confirm GitHub CI before release.

## Keeping the handover current

When architecture, verified functionality, environment requirements, test results, or the next recommended task changes, update this document and the matching development checklist. Keep `SETUP_CHECKLIST.md` focused on machine setup and running the project. Mark roadmap items complete only after implementation and relevant verification; record CI status separately from local checks.
