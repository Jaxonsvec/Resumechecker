# Development and handover

## Toolchain

The toolchain verified for this foundation is Flutter 3.47.7 stable with Dart 3.13.5. The Flutter SDK reports those versions from `C:\Users\jaxon\flutter`; `pubspec.yaml` requires Dart `^3.13.5`. `android/local.properties` is machine-specific and must not be committed.

On Windows, use a stable Flutter SDK at version 3.47.7 or a compatible newer stable release. Select the SDK using Flutter's official installation instructions, add `<flutter-sdk>\bin` to PATH, and restart terminals and VS Code. In VS Code, install the Flutter extension and either let it discover the SDK or set `dart.flutterSdkPath` in User Settings to the local SDK directory. Do not commit a personal absolute SDK path in workspace settings.

## Environment configuration

The Flutter app accepts a non-secret API base URL with `--dart-define=API_BASE_URL=...`; it defaults to `http://10.0.2.2:3000` on Android and `http://localhost:3000` elsewhere. Tests cover both defaults and the compile-time override. Android INTERNET permission is present, and cleartext HTTP is enabled only in the debug manifest. Never put an OpenAI key in Flutter configuration. Backend-only settings belong in an ignored local `.env`; Node's env-file loading is verified. `.env.example` lists `PORT`, `OPENAI_API_KEY`, `OPENAI_MODEL`, and the exact browser origin allowlist `CORS_ALLOWED_ORIGINS`. Actual OpenAI requests require a valid key and may incur usage charges. Do not make live provider calls in tests.

The backend analysis endpoint accepts one PDF or DOCX file (10 MiB maximum) as multipart field `resume`, plus optional `targetRole`. It extracts text in memory, then calls the configured OpenAI model and returns schema-validated feedback. The Flutter app requests consent, uploads the selected file, shows progress, and renders actual result fields; tests use fake responses only. `npm install` succeeded with OpenAI SDK 6.49.0 and Zod 4.6.7; `npm run check` and ten mocked API/unit tests pass. No key is set in this checkout, and no live provider request was made. Never use a real resume for routine tests.

## Handover board

### Completed

- Root Flutter scaffold retained and replaced with the Airesume foundation screen.
- Flutter/Dart toolchain requirement documented from the local SDK metadata.
- Architecture and API boundary documented; local mocked verification is distinguished from live provider behavior.
- Express/Zod API with PDF/DOCX upload, signature and size validation, in-memory text extraction, structured OpenAI analysis, safe errors, and mocked tests are implemented in source. Local mocked checks pass; clean dependency installation and synthetic-document extraction verification remain pending because npm registry DNS resolution failed in this environment.
- GitHub Actions workflow added for Flutter analysis, tests, and Android debug build.
- Phase 3 selection and Phase 6 integration: after processing acknowledgment, the selected resume is uploaded to the configured backend and structured feedback is rendered with retryable errors. Automated tests use fake responses only.

### Incomplete / next decisions

- Confirm authentication, user consent, retention/deletion, provider data handling, and deployment controls before processing real resumes in production.
- Verify PDF/DOCX extraction with synthetic documents and run the connected workflow on an Android emulator/device.
- Verify the backend dependency installation, extraction library behavior, mocked provider tests, and API behavior in a network-enabled environment; no live model request has been made.
- The pasted-text path runs basic local rule-based checks. The separate file-selector preview only selects and displays metadata; the connected upload path remains the `Choose a resume` workflow.
- Configure an Android application ID and test on an emulator or device.
- Verify Android APK build in an environment with Java and Android SDK installed.

## Team workflow

Work on a feature branch, keep Flutter at the repository root, and avoid committing machine-specific SDK paths, secrets, generated build output, or resumes. Run formatting, analysis, and widget tests before opening a pull request. Changes to API behavior should update `docs/API.md` and include tests.
