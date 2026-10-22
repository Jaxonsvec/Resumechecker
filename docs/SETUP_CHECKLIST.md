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
- [ ] If contributing to the backend, run `npm ci` from `backend/`.
- [ ] Do not run broad dependency upgrades as part of routine setup. Keep `pubspec.lock` and `backend/package-lock.json` in sync with intentional dependency changes.

## 4. Environment variables and privacy

- [ ] No environment variable or API key is needed to run the current Flutter screen or backend health route.
- [ ] The backend uses `PORT` (default `3000`). To use another port in PowerShell, set `$env:PORT = "3001"` before starting it.
- [ ] `backend/.env.example` contains placeholder values. For future local provider work, copy it with `Copy-Item .env.example .env` inside `backend/`; replace placeholders only when authorized to use a real backend key.
- [ ] Never put an OpenAI key in Flutter, `--dart-define`, source control, issue comments, or logs. The placeholder key is not used by the current server.
- [ ] Do not use real resumes in tests or send any resume to a live provider. File selection and pasted-text local checks are implemented; file upload, extraction, and provider analysis are not.

## 5. Run the app and optional API

- [ ] From the repository root, run `flutter run` and select the running emulator/device. You can target a device with `flutter run -d <device-id>`.
- [ ] Confirm the Airesume home screen and workflow summary appear. Scroll normally and drag past the top/bottom edges; content should not stretch on Android.
- [ ] Tap **Paste resume**, load the synthetic sample, and confirm **Check resume** opens basic feedback.
- [ ] Tap **Upload resume**, then **Choose file**. Select a synthetic PDF/DOCX (up to 10 MB) and confirm filename/size, replacement, removal, and cancellation work. Files are selected locally only; extraction and upload are not implemented.
- [ ] Optional: from `backend/`, run `npm start`; verify `http://localhost:3000/health` returns `{"status":"ok"}`.
- [ ] Optional: send valid JSON to `/api/v1/analyses` and confirm it returns HTTP 501. This route validates request shape but does not analyze or store resume text.

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
