# Development and handover

## Toolchain

The toolchain verified for this foundation is Flutter 3.47.7 stable with Dart 3.13.5. The Flutter SDK reports those versions from `C:\Users\jaxon\flutter`; `pubspec.yaml` requires Dart `^3.13.5`. `android/local.properties` is machine-specific and must not be committed.

On Windows, use a stable Flutter SDK at version 3.47.7 or a compatible newer stable release. Select the SDK using Flutter's official installation instructions, add `<flutter-sdk>\bin` to PATH, and restart terminals and VS Code. In VS Code, install the Flutter extension and either let it discover the SDK or set `dart.flutterSdkPath` in User Settings to the local SDK directory. Do not commit a personal absolute SDK path in workspace settings.

## Environment configuration

The Flutter app currently has no environment variables and does not connect to an API. When API integration is added, provide non-secret per-developer configuration (for example an API base URL via `--dart-define=API_BASE_URL=...`). Never put an OpenAI key in Flutter configuration. Backend-only settings belong in an ignored local `.env`; commit only placeholder names in `.env.example`. Actual OpenAI requests require a valid key and may incur usage charges. Do not make live provider calls in tests.

## Handover board

### Completed

- Root Flutter scaffold retained and replaced with the Airesume foundation screen.
- Flutter/Dart toolchain requirement documented from the local SDK metadata.
- Architecture and API boundary documented without claiming analysis is working.
- Express and Zod backend foundation with a tested health check, validated placeholder analysis request, and consistent JSON errors.
- GitHub Actions workflow added for Flutter analysis, tests, and Android debug build.

### Incomplete / next decisions

- Implement a native PDF/DOCX picker and accessible upload progress, empty, failure, and result screens.
- Decide authentication, upload size/retention/deletion, supported formats, and text extraction library.
- Build the secure backend and OpenAI provider adapter for `gpt-5-mini`; validate output and mock provider calls in tests.
- Configure an Android application ID and test on an emulator or device.
- Verify Android APK build in an environment with Java and Android SDK installed.

## Team workflow

Work on a feature branch, keep Flutter at the repository root, and avoid committing machine-specific SDK paths, secrets, generated build output, or resumes. Run formatting, analysis, and widget tests before opening a pull request. Changes to API behavior should update `docs/API.md` and include tests.
