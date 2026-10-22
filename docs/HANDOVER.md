# Airesume project handover

Updated 20 October 2026. This describes the files in the current checkout, not the intended future product.

## Purpose and status

Airesume is a Flutter-first mobile app foundation for AI-assisted resume feedback. It is not yet a working resume analyzer. The app has a home screen and navigable design previews for resume selection, analysis progress, results, and issues; each preview clearly states that the underlying feature is not implemented. The backend exposes health and request validation but deliberately returns 501 for valid analysis requests.

## Current architecture

- **Flutter app:** The Flutter project lives at the repository root. `lib/main.dart` starts the Material 3 app shell and applies the centralized theme from `lib/theme/app_theme.dart`. `lib/screens/home_screen.dart` introduces the workflow. `lib/screens/resume_selection_screen.dart`, `lib/screens/analysis_progress_screen.dart`, and `lib/screens/analysis_results_screen.dart` are UI previews only. `lib/screens/workflow_issues_screen.dart` presents proposed unsupported-file and retry states. `lib/widgets/feedback_state.dart` provides reusable loading, empty, error, and success states; `lib/widgets/workflow_components.dart` shares the preview banner and step header. `test/widget_test.dart` covers the flow, prototype actions, and state variants. The group has not approved the proposed user flow. There are no resume models, upload services, or working analysis screens yet.
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
- Established a shared theme, extracted the home and workflow preview screens, and added reusable loading/empty/error/success states. The previews explicitly do not select, upload, or analyze resumes.
- Added Phase 2 UX previews for resume selection, analysis progress, results sections, unsupported-file messaging, and connection retry. The flow is a proposal awaiting team approval; no underlying resume processing was added.
- Expanded widget tests to cover the Phase 2 screens and prototype actions.
- Documented and pinned the recommended Flutter 3.47.7 / Dart 3.13.5 toolchain in `pubspec.yaml` and `.fvmrc`.
- Added Flutter widget coverage for the home screen, workflow preview navigation, and each reusable feedback state.
- Added an Express/Zod backend foundation with health, request validation, consistent errors, size limit, and API tests.
- Added Flutter and backend CI jobs, architecture/API documentation, environment guidance, this handover, and a teammate checklist.
- The existing Git repository and history are intact. Check the live status, branch, and recent commits before working; this handover is not a substitute for Git inspection.

## Incomplete features

- Functional file picker, file validation/details, upload, and parsing/extraction.
- Live analysis progress, network retry and unsupported-file handling, and actual results from an API; the current screens are design previews only.
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

The following results combine the 20 October 2026 local foundation verification and the Phase 1 verification performed during this handover update. Environment: Flutter 3.47.7 stable, Dart 3.13.5, Node.js v24.21.0, npm 11.19.0. Flutter dependency resolution and backend dependency installation completed successfully.

| Check | Result |
| --- | --- |
| `flutter pub get` | Passed; lockfile resolved. Five packages have newer versions outside the current dependency constraints; no broad upgrade was made. |
| `dart format lib test` | Passed; current files formatted. |
| `dart format --output=none --set-exit-if-changed lib test` | Passed after formatting. |
| `flutter analyze` | Passed after Phase 2 changes; no issues found. |
| `flutter test` | Passed after Phase 2 changes; 5 widget tests cover selection, progress/results, issue previews, and reusable states. |
| `flutter build apk --debug` | Passed after Phase 2 changes; created `build/app/outputs/flutter-apk/app-debug.apk`. |
| `npm ci` | Passed; 66 packages installed, audit reported 0 vulnerabilities. |
| `npm run check` | Passed; backend syntax checks. |
| `npm test` | Passed; 4 API tests. |
| `git diff --check` | Passed for tracked changes. New files were also checked for trailing whitespace before handover. |

An initial test attempt exposed issues in the new tests and was corrected before the passing rerun. The backend tests require loopback access; they passed when run with it available. `flutter devices` currently lists Windows and browser targets but no Android emulator or connected Android device. `flutter run` on an Android emulator/device and GitHub CI were not part of that verification.

## Known issues and limitations

- The UI intentionally does not select a file or start analysis. The backend's 501 route is validation-only.
- The navigable resume-selection, analysis-progress, results, and issue screens are unapproved design previews, not an implemented end-to-end workflow.
- The primary workflow, file format/size policy, target-role behavior, scoring criteria, and retention decisions still need team agreement.
- The Android application ID is still Flutter's generated example ID.
- `flutter doctor -v`, `flutter run` on an emulator/device, and GitHub Actions have not been verified in the recorded setup checks.
- No real API key or resume data was used. There were no live OpenAI calls.
- Dependency notices report available newer versions, but the committed lockfiles currently resolve successfully.

## Prioritized next steps

1. **Development checklist 1.1:** launch the app with `flutter run` from the repository root on an Android emulator/device and verify the home screen. No Android target was connected at the latest check; APK compilation is not a substitute for a device launch.
2. **Development checklist 2.1 and 2.7:** review and approve or revise the UX flow and screen previews with the team.
3. **Development checklist 1.7:** have another teammate follow the setup guide and confirm a fresh clone can run.
4. Before accepting resumes, agree on authentication, supported formats, upload limits, retention, deletion, target-role behavior, and scoring criteria; record decisions in `docs/API.md` and `docs/ARCHITECTURE.md`.
5. Implement and test resume input, extraction, secure provider calls, and results in dependency order in `docs/DEVELOPMENT_CHECKLIST.md`.
6. Replace the Android example application ID, verify local Android setup, and confirm both CI jobs on GitHub before release.

## Keeping the handover current

When architecture, verified functionality, environment requirements, test results, or the next recommended task changes, update this document and the matching development checklist. Keep `SETUP_CHECKLIST.md` focused on machine setup and running the project. Mark roadmap items complete only after implementation and relevant verification; record CI status separately from local checks.
