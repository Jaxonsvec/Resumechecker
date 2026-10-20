# Airesume

A Flutter-first foundation for an AI-assisted resume feedback app. The app supports local resume selection (PDF/DOCX up to 5 MiB), file details, replacement, and removal. Resume upload, API analysis, results, and OpenAI calls are not implemented yet. The original provider/model decision is OpenAI `gpt-5-mini`; any future provider key must live on a backend, never in the Flutter app.

## Start here

Recommended onboarding order:

1. Read [the project handover](docs/HANDOVER.md) for the current architecture, implementation, decisions, and limitations.
2. Follow [the setup checklist](docs/SETUP_CHECKLIST.md) to configure your environment.
3. Review [the development checklist](docs/DEVELOPMENT_CHECKLIST.md) to see verified work and remaining tasks.
4. Before starting a task, inspect the current code, Git status, branch, and recent commits.

AI coding agents must follow [AGENTS.md](AGENTS.md) and read the handover completely before modifying files, installing dependencies, or beginning implementation.

## Requirements

- Flutter 3.47.7 stable and Dart 3.13.5 (or a compatible newer stable Flutter release satisfying `pubspec.yaml`). The project-local `.fvmrc` records the recommended version for teams using FVM; FVM is optional and its SDK symlink behavior can require extra Windows setup. The SDK itself is installed separately.
- Git and VS Code with the Flutter extension (or Android Studio).
- Android Studio Android SDK and an Android emulator or USB-debuggable device to run/build Android. Java 17 is needed by the Android Gradle build.
- Node.js 22.9 or newer when developing the optional backend.

The Flutter and Dart versions were confirmed by the SDK and CLI. The available checks and exact results are recorded in [the handover](docs/HANDOVER.md).

## Fresh Windows setup

1. Install Git, Android Studio (including Android SDK Platform Tools and an emulator), and Flutter 3.47.7 stable. Follow [Flutter's Windows install guide](https://docs.flutter.dev/get-started/install/windows/mobile) and install the Android licenses with `flutter doctor --android-licenses`.
2. Add `<your Flutter SDK>\bin` to your user PATH, then open a new PowerShell window. Check `flutter --version` and `flutter doctor -v`.
3. Clone and enter the project:

   ```powershell
   git clone https://github.com/Jaxonsvec/Resumechecker.git Airesume
   cd Airesume
   ```

   If the repository's default branch changes, use the branch the team has agreed to develop from.
4. In VS Code, open this repository folder. Install the Flutter extension. If it does not find Flutter, run **Flutter: Change SDK** from the command palette or set `dart.flutterSdkPath` in User Settings to the full local Flutter SDK path (for example `C:\src\flutter`). Do not commit that personal path.
5. In the repository root, run:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

   Select a running Android emulator or connected device when prompted. To target a device explicitly, run `flutter devices`, then `flutter run -d <device-id>`.

The dependency lockfile is committed. Use `flutter pub get` for normal setup; do not routinely run broad dependency upgrades.

## Troubleshooting (PowerShell / Android)

- **`flutter` is not recognized:** add `<sdk>\bin` to PATH and start a new terminal, or invoke `<sdk>\bin\flutter.bat` by its full path.
- **VS Code reports no Flutter SDK:** run Flutter: Change SDK or configure `dart.flutterSdkPath` in User Settings. `android/local.properties` is generated locally and intentionally ignored by Git.
- **Android licenses or SDK components missing:** install the components reported by `flutter doctor -v`, then run `flutter doctor --android-licenses` and accept the required licenses.
- **No devices found:** start an emulator from Android Studio Device Manager or enable USB debugging and authorize the computer on the phone; check `flutter devices`.
- **Gradle/Java errors:** install a supported JDK (Java 17 for this project), verify `java -version`, and restart the terminal. A clean dependency fetch may require network access to pub.dev and Google's/Maven's artifact repositories.
- **Dependency resolution fails:** check network/proxy access to pub.dev and try `flutter pub get` again. Keep `pubspec.lock` intact unless intentionally changing dependencies.
- **Build artifacts behave oddly after an SDK switch:** run `flutter clean`, then `flutter pub get`.

## Project layout

- `lib/` — Flutter app
- `test/` — Flutter widget tests
- `android/` — Android project configuration
- `backend/` — Express API foundation (health check and a clearly unimplemented analysis route)
- `docs/` — architecture, proposed API contract, and team handover
- [Development checklist](docs/DEVELOPMENT_CHECKLIST.md) — feature-by-feature team work plan
- `.github/workflows/` — Flutter CI

The resume action opens the native file picker. Selection is local to the current session; nothing is sent to the backend. The backend has a health route and an analysis request validator that returns 501; it does not analyze resumes and no AI provider is connected. See [architecture](docs/ARCHITECTURE.md), [API contract](docs/API.md), and [development notes](docs/DEVELOPMENT.md) for additional detail.

## Backend (optional during Flutter development)

Install Node.js 22.9 or newer, then from `backend/` run:

```powershell
npm ci
npm test
npm start
```

The service listens on port 3000 by default; set `$env:PORT = "3001"` before `npm start` to change it. The server reads a local `backend/.env` file if present. `backend/.env.example` documents the future server-side OpenAI setting, which is currently unused. Never commit a local `.env` or send a key to Flutter. No key is needed for the current health endpoint or placeholder route.

## Checks

The locally verified commands and outcomes are recorded in [the handover](docs/HANDOVER.md). GitHub Actions is configured for Flutter and backend checks, but has not yet been run on GitHub.
