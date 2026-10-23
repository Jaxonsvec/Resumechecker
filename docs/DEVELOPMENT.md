# Development and handover

## Toolchain

The toolchain verified for this foundation is Flutter 3.47.7 stable with Dart 3.13.5. The Flutter SDK reports those versions from `C:\Users\jaxon\flutter`; `pubspec.yaml` requires Dart `^3.13.5`. `android/local.properties` is machine-specific and must not be committed.

On Windows, use a stable Flutter SDK at version 3.47.7 or a compatible newer stable release. Select the SDK using Flutter's official installation instructions, add `<flutter-sdk>\bin` to PATH, and restart terminals and VS Code. In VS Code, install the Flutter extension and either let it discover the SDK or set `dart.flutterSdkPath` in User Settings to the local SDK directory. Do not commit a personal absolute SDK path in workspace settings.

## Environment configuration

The Flutter app accepts a non-secret API base URL with `--dart-define=API_BASE_URL=...`; it defaults to `http://10.0.2.2:3000` on Android and `http://localhost:3000` elsewhere. Tests cover both defaults and the compile-time override. Android INTERNET permission is present, and cleartext HTTP is enabled only in the debug manifest. Never put provider credentials in Flutter configuration. Backend-only settings belong in an ignored local `.env`; Node's env-file loading is verified. Set `AI_PROVIDER=openai` to use `OPENAI_API_KEY` and `OPENAI_MODEL`, or `AI_PROVIDER=ollama` to use `OLLAMA_BASE_URL`, `OLLAMA_MODEL`, `OLLAMA_NUM_CTX`, and `OLLAMA_TIMEOUT_MS` without an OpenAI key. Local Ollama uses its own machine's service; cloud inference is not configured. Do not make live provider calls in tests.

The backend accepts PDF/DOCX files (10 MiB maximum) and edited resume text (100,000 characters maximum). It returns score explanations under the five-category rubric, strengths, prioritized improvements, source-grounded rewrite suggestions, and optional job relevance. `SCORING_RUBRIC.md` documents score bands and the equally weighted average. Flutter includes a fictional examples library, score comparison, revision editor, and regrade history; revisions use the same backend provider. JPG/PNG OCR uses ML Kit on Android/iOS and previews editable text before submission. Automated tests mock providers and OCR and do not verify live inference or recognition accuracy. Authentication, retention/deletion, production provider-data review, and deployment controls remain open decisions.

## Handover board

### Completed

- Root Flutter scaffold retained and replaced with the Airesume foundation screen.
- Flutter/Dart toolchain requirement documented from the local SDK metadata.
- Architecture and API boundary documented; local mocked verification is distinguished from live provider behavior.
- Express/Zod API with PDF/DOCX upload, signature and size validation, in-memory text extraction, selectable structured OpenAI/local Ollama analysis, safe errors, and mocked tests are implemented. Synthetic text-only PDF and DOCX extraction passed; local qwen3:8b API inference also succeeded with synthetic text.
- GitHub Actions workflow added for Flutter analysis, tests, and Android debug build.
- Phase 3 selection and Phase 6 integration: after processing acknowledgment, the selected resume is uploaded to the configured backend and structured feedback is rendered with retryable errors. Automated tests use fake responses only.

### Incomplete / next decisions

- Confirm authentication, user consent, retention/deletion, provider data handling, and deployment controls before processing real resumes in production.
- Run the connected workflow on an Android emulator/device.
- A clean `npm ci` passed in a temporary source snapshot. Inspect GitHub CI separately; current Ollama changes have not been pushed or run in CI.
- The pasted-text path runs basic local rule-based checks. The separate file-selector preview only selects and displays metadata; the connected upload path remains the `Choose a resume` workflow.
- Configure an Android application ID and test on an emulator or device.
- Debug and release APK builds passed locally with Java and Android SDK installed; emulator installation/launch remains unverified because the AVD is offline.

## Team workflow

Work on a feature branch, keep Flutter at the repository root, and avoid committing machine-specific SDK paths, secrets, generated build output, or resumes. Run formatting, analysis, and widget tests before opening a pull request. Changes to API behavior should update `docs/API.md` and include tests.
