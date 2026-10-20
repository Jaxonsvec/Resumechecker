# Airesume project handover

Updated 20 October 2026. This describes the files in the current checkout, not the intended future product.

## Purpose and status

Airesume is a Flutter-first mobile app foundation for AI-assisted resume feedback. It is not yet a working resume analyzer. The current user-facing app introduces the intended workflow and supports local PDF/DOCX selection up to 5 MiB; upload and analysis remain unavailable. The backend exposes health and request validation but deliberately returns 501 for valid analysis requests.

## Current architecture

- **Flutter app:** The Flutter project lives at the repository root. `lib/main.dart` currently contains the Material 3 app shell, theme, home screen, three-step workflow introduction, and resume input widget. `lib/resume_input.dart` owns the native picker adapter, local document reference, extension/size validation, and selection UI. `test/widget_test.dart` covers home copy, validation, selection, replacement, removal, cancellation, errors, and disposal.
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
- Added a widget test for the initial screen and upload-unavailable state.
- Added an Express/Zod backend foundation with health, request validation, consistent errors, size limit, and API tests.
- Added Flutter and backend CI jobs, architecture/API documentation, environment guidance, this handover, and a teammate checklist.
- The existing Git repository and history are intact. Check the live status, branch, and recent commits before working; this handover is not a substitute for Git inspection.

## Incomplete features

- Resume upload, parsing/extraction, analysis progress, network retry/error states, and results screen. Native picker device verification is outstanding.
- Resume scoring, recommendations, and history are not implemented.
- Authentication, API URL configuration in Flutter, and a production API contract for document uploads.
- Data retention/deletion policy and supported document limits.
- Real analysis endpoint and server-side OpenAI adapter using `gpt-5-mini`, structured output validation, timeouts, and mocked provider tests.
- Production Android application ID and emulator/physical-device run-through.
- Successful GitHub Actions run. Local checks passed, but GitHub CI has not been observed.

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
| `dart format lib test` | Passed; files formatted. |
| `dart format --output=none --set-exit-if-changed lib test` | Passed after formatting. |
| `flutter analyze` | Passed; no issues found. |
| `flutter test` | Passed; 1 widget test. |
| `flutter build apk --debug` | Passed; created `build/app/outputs/flutter-apk/app-debug.apk`. |
| `npm ci` | Passed; 66 packages installed, audit reported 0 vulnerabilities. |
| `npm run check` | Passed; backend syntax checks. |
| `npm test` | Passed; 4 API tests. |
| `git diff --check` | Passed for tracked changes. New files were also checked for trailing whitespace before handover. |

An initial test attempt exposed issues in the new tests and was corrected before the passing rerun. The backend tests require loopback access; they passed when run with it available. `flutter run` on an emulator/device and GitHub CI were not part of that verification.

## Known issues and limitations

- The UI selects a local file but does not upload it or start analysis. The backend's 501 route is validation-only.
- The documented three-step flow is a concept shown on the home screen, not an implemented end-to-end workflow.
- The Android application ID is still Flutter's generated example ID.
- `flutter doctor -v`, `flutter run` on an emulator/device, and GitHub Actions have not been verified in the recorded setup checks.
- No real API key or resume data was used. There were no live OpenAI calls.
- Dependency notices report available newer versions, but the committed lockfiles currently resolve successfully.

## Prioritized next steps

1. **Development checklist 1.1:** launch the app with `flutter run` from the repository root on an emulator/device and verify the home screen. APK compilation is not a substitute for a device launch.
2. **Development checklist 1.7:** have another teammate follow the setup guide and confirm a fresh clone can run.
3. Before accepting resumes, agree on the workflow, authentication, supported formats, upload limits, retention, and deletion; record the decisions in `docs/API.md` and `docs/ARCHITECTURE.md`.
4. Implement and test resume input, extraction, secure provider calls, and results in dependency order in `docs/DEVELOPMENT_CHECKLIST.md`.
5. Replace the Android example application ID, verify local Android setup, and confirm both CI jobs on GitHub before release.

## Keeping the handover current

When architecture, verified functionality, environment requirements, test results, or the next recommended task changes, update this document and the matching development checklist. Keep `SETUP_CHECKLIST.md` focused on machine setup and running the project. Mark roadmap items complete only after implementation and relevant verification; record CI status separately from local checks.

## Local file selection update — 20 October 2026

Added `file_picker` 13.1.0, PDF/DOCX extension and positive size validation (maximum 5 MiB), selected filename/type/size, replace/remove, cancellation preservation, busy state, and safe access failures. Selection is held only in widget memory. No content inspection, upload, extraction, persistence, or provider calls were added. Native pickers may cache documents locally; removing the selection only clears the app reference. These initial local limits can be revised by the team before upload integration.

Verification results for this update are recorded below; prior foundation results above are historical. Branch creation was blocked by read-only Git metadata, so changes remain uncommitted on `main`.

- Passed: offline `flutter pub get`, Dart format check (3 files), `flutter analyze` (no issues), and `git diff --check`. Flutter ran from a writable temporary SDK copy with analytics suppressed.
- Blocked: `flutter test` could not bind its loopback server (OS permission denied); no tests executed. `flutter build apk --debug` could not write the Gradle wrapper cache lock. Android native picker/device behavior and GitHub CI remain unverified. Backend was unchanged and its tests were not rerun.
