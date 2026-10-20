# Airesume project handover

Updated 20 October 2026. This describes the files in the current checkout, not the intended future product.

## Current architecture

- **Flutter app:** The Flutter project lives at the repository root. `lib/main.dart` contains the Airesume Material 3 shell, home screen, three-step workflow introduction, and an upload-unavailable dialog. `test/widget_test.dart` covers those behaviors.
- **Android:** `android/` is the generated Android host project. The current application ID is still `com.example.airesume`. `android/local.properties` is local machine configuration and is ignored.
- **Backend:** `backend/` is an Express 5 API using Zod 4 schemas. `GET /health` returns `{"status":"ok"}`. `POST /api/v1/analyses` validates JSON `resumeText` (1–100,000 trimmed characters) and optional `targetRole` (up to 200 characters); valid requests return HTTP 501. It does not analyze, retain, extract, or upload a resume. JSON request size is limited to 300 KB and errors use a shared JSON structure.
- **Provider:** The initial decision remains OpenAI `gpt-5-mini`. `backend/src/providers/resume_analyzer.js` only documents the future interface. There is no OpenAI SDK, API call, live key requirement, or AI result today. `backend/.env.example` contains placeholder values only. Never place a provider key in Flutter or commit a real `.env`.
- **CI and docs:** `.github/workflows/flutter.yml` runs Flutter checks, Android debug build, and backend checks on pushes and pull requests. CI has not been run on GitHub.

More detail: [architecture](ARCHITECTURE.md), [API contract](API.md), [development notes](DEVELOPMENT.md), and [setup checklist](SETUP_CHECKLIST.md).

## Completed

- Retained the root Flutter scaffold and replaced the counter demo with the Airesume foundation screen.
- Documented and pinned the recommended Flutter 3.47.7 / Dart 3.13.5 toolchain in `pubspec.yaml` and `.fvmrc`.
- Added a widget test for the initial screen and upload-unavailable state.
- Added an Express/Zod backend foundation with health, request validation, consistent errors, size limit, and API tests.
- Added Flutter and backend CI jobs, architecture/API documentation, environment guidance, this handover, and a teammate checklist.
- Preserved the existing Git repository and branch state. No commit, push, or merge was made.

## Incomplete features

- Resume file picker, upload, parsing/extraction, progress, retry/error states, and results screen.
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

The backend defaults to port 3000. Set `$env:PORT = "3001"` before starting to choose another port. No key is needed for its current routes. The OpenAI placeholder is unused until provider integration exists; any eventual key belongs on the backend only and may incur usage charges.

For a step-by-step teammate flow, use [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md).

## Verification performed locally

Environment checked: Flutter 3.47.7 stable, Dart 3.13.5, Node.js v24.21.0, npm 11.19.0. Flutter dependency resolution and backend dependency installation completed successfully.

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

An initial test attempt exposed issues in the new tests and was corrected before the passing rerun. The backend tests require loopback access; they passed when run with it available.

## Known issues and limitations

- The UI intentionally does not select a file or start analysis. The backend's 501 route is validation-only.
- The Android application ID is still Flutter's generated example ID.
- `flutter doctor -v`, `flutter run` on an emulator/device, and GitHub Actions have not been completed as part of this setup.
- No real API key or resume data was used. There were no live OpenAI calls.
- Dependency notices report available newer versions, but the committed lockfiles currently resolve successfully.

## Prioritized next steps

1. Agree on privacy, authentication, supported formats, upload limits, retention, and deletion before accepting actual resumes.
2. Choose and implement PDF/DOCX text extraction, then add the Flutter file picker, API client, loading/retry states, and structured result screens.
3. Implement the backend provider adapter and analysis result schema with mocked provider tests; keep secrets server-side and avoid sensitive logs.
4. Replace the Android example application ID, validate Android setup with `flutter doctor -v`, and test on an emulator and physical device.
5. Push a reviewed branch/PR and confirm both CI jobs pass on GitHub.
