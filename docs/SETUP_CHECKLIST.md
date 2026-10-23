# Airesume teammate setup checklist

Use this for a fresh Windows development machine. Leave items unchecked until you have completed them on your machine. If a step fails, see [README troubleshooting](../README.md#troubleshooting-powershell--android) and ask the team before changing pinned dependencies or project structure.

## 1. Install tools

- [ ] Install Git for Windows.
- [ ] Install Flutter **3.47.7 stable** (includes Dart 3.13.5), or another stable release compatible with `pubspec.yaml`.
- [ ] Install VS Code and the Flutter extension, or Android Studio with Flutter/Dart plugins.
- [ ] Install Android Studio Android SDK, SDK Platform Tools, and an Android emulator image, or prepare an Android device with USB debugging enabled.
- [ ] Install a Java 17 JDK for Android Gradle builds.
- [ ] If working on the backend, install Node.js 22.9 or newer (npm is included).

## 2. Configure Flutter and Android

- [ ] Add `<Flutter SDK>\bin` to your user PATH and open a new PowerShell terminal.
- [ ] Confirm `flutter --version` reports Flutter 3.47.7 and Dart 3.13.5; run `flutter doctor -v`.
- [ ] In VS Code, open the repository folder. If Flutter is not detected, run **Flutter: Change SDK** or set `dart.flutterSdkPath` in User Settings.
- [ ] In Android Studio Device Manager, create and start an emulator, or connect and authorize your Android device.
- [ ] Run `flutter doctor --android-licenses` and accept required Android SDK licenses.
- [ ] Confirm `flutter devices` lists the emulator or device you intend to use.
- [ ] Keep your personal SDK path in User Settings. Do not commit `android/local.properties` or machine-specific workspace settings.

## 3. Clone and install dependencies

- [ ] Clone the team's repository and enter the root Flutter project:

  ```powershell
  git clone https://github.com/Jaxonsvec/Resumechecker.git Airesume
  cd Airesume
  ```

- [ ] Run `flutter pub get` from the repository root.
- [ ] If contributing to the backend on this branch, run `npm install` from `backend/` to resolve the new dependencies and refresh `package-lock.json`; once refreshed, use `npm ci` for subsequent clean installs.
- [ ] Do not run broad dependency upgrades as part of routine setup. Keep `pubspec.lock` and `backend/package-lock.json` in sync with intentional dependency changes.

## 4. Environment variables and privacy

- [ ] No environment variable or API key is needed to browse Flutter screens or call the backend health route. A server-side `OPENAI_API_KEY` is required for actual analysis.
- [ ] The backend uses `PORT` (default `3000`). To use another port in PowerShell, set `$env:PORT = "3001"` before starting it.
- [ ] `backend/.env.example` contains placeholder values. To use the provider, copy it with `Copy-Item .env.example .env` inside `backend/` and add a server-side key.
- [ ] Never put an OpenAI key in Flutter, `--dart-define`, source control, issue comments, or logs.
- [ ] Do not use real resumes in tests. The backend sends uploaded extracted text to the configured provider; review privacy and provider terms before using real resumes.

## 5. Run the app and optional API

- [ ] From the repository root, run `flutter run` and select the running emulator/device. You can target a device with `flutter run -d <device-id>`.
- [ ] Confirm the Airesume home screen and workflow summary appear.
- [ ] Tap **Choose a resume** and select a PDF or DOCX up to 10 MiB. Confirm the filename and size appear, then try replacing and removing the selection.
- [ ] Configure `API_BASE_URL` if the backend is not at the platform default. Android emulator uses `http://10.0.2.2:3000`; Windows uses `http://localhost:3000`.
- [ ] Before real analysis, configure a server-side provider key and review the provider's privacy terms. The app requires processing acknowledgment before sending resume text.
- [ ] Follow [the README backend setup](../README.md#backend-optional-during-flutter-development) to enter the key without putting it in command history. A healthy `/health` route does not validate the provider key.
- [ ] Optional: from `backend/`, run `npm start`; verify `http://localhost:3000/health` returns `{"status":"ok"}`.
- [ ] Optional: after dependency installation and verification, send one synthetic PDF/DOCX multipart upload to `/api/v1/analyses`; confirm it returns the documented structured result when a backend provider key is configured.

## 6. Test and build before sharing work

- [ ] From the repository root, run `dart format lib test`.
- [ ] Run `dart format --output=none --set-exit-if-changed lib test`.
- [ ] Run `flutter analyze` and resolve issues.
- [ ] Run `flutter test` and confirm widget tests pass.
- [ ] Run `flutter build apk --debug` if Android tooling is configured.
- [ ] If you changed the backend, run `npm run check` and `npm test` from `backend/`.

## 7. Collaborate through Git

- [ ] Before editing, run `git status --short --branch` and preserve any existing local changes.
- [ ] Create or switch to a team-approved feature branch before implementation.
- [ ] Keep Flutter at the repository root; discuss changes to the API contract in `docs/API.md`.
- [ ] Check `git diff --check` and `git status` before committing.
- [ ] Do not commit `.env`, `android/local.properties`, build artifacts, API keys, or resume documents.
- [ ] Commit only your intended changes, push your own branch, and open a pull request for review. Do not push directly to the shared default branch unless the team explicitly asks.
