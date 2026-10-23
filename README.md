# Airesume

A Flutter-first AI resume-feedback app. The connected flow selects PDF/DOCX files up to 10 MiB, gets user consent, uploads a selected file and optional target role to the Express backend, shows request progress, and renders structured feedback. A second input lets users paste text for local rule-based checks, and a local file-selection preview demonstrates native selection without analyzing that file. The backend extracts text in memory and calls the selected server-side provider: OpenAI or local Ollama. Provider credentials remain on the backend, never in Flutter. Automated provider tests use mocks. A real local Ollama structured-analysis request with synthetic resume text returned HTTP 200 on this machine; no live OpenAI request was made.

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
- Node.js 22.9 or newer when developing the backend.

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
- `backend/` — Express API, PDF/DOCX extraction, and OpenAI/local Ollama analysis adapters
- `docs/` — architecture, proposed API contract, and team handover
- [Development checklist](docs/DEVELOPMENT_CHECKLIST.md) — feature-by-feature team work plan
- `.github/workflows/` — Flutter CI

The **Choose a resume** action opens the connected PDF/DOCX analysis flow. After you accept the processing notice and press **Analyze resume**, the app uploads the document to the configured backend, which extracts text and sends it to the configured analysis provider. The backend does not store the uploaded file. The API and results UI show a summary, evidence-based strengths, improvements, and missing information. **Paste resume** runs local rule-based checks on the entered text; **Select a file locally** only demonstrates native PDF/DOCX selection and does not upload or analyze that selected file. See [architecture](docs/ARCHITECTURE.md), [API contract](docs/API.md), and [development notes](docs/DEVELOPMENT.md) for setup and limitations.

## Backend (optional during Flutter development)

Install Node.js 22.9 or newer. In a PowerShell window, install dependencies and create the ignored local environment file:

```powershell
Set-Location C:\Users\jaxon\OneDrive\Documents\GitHub\Airesume\backend
npm install
Copy-Item .env.example .env
```

Choose one provider. To use local Ollama, install it with Winget (or use the [official download](https://ollama.com/download)), then open Ollama so its local service is running:

```powershell
winget install --id Ollama.Ollama -e
ollama --version
ollama pull qwen3:8b
ollama list
```

If the desktop app is not running the service, start `ollama serve` in a separate PowerShell window.

In the same PowerShell window used to start the backend, select local Ollama (no OpenAI key is required):

```powershell
$env:AI_PROVIDER = 'ollama'
$env:OLLAMA_BASE_URL = 'http://127.0.0.1:11434'
$env:OLLAMA_MODEL = 'qwen3:8b'
$env:OLLAMA_NUM_CTX = '8192'
```

To keep the selection across sessions, set `AI_PROVIDER=ollama`, `OLLAMA_BASE_URL`, and `OLLAMA_MODEL` in the ignored `backend/.env`. The backend contacts Ollama locally at `/api/chat`; the Flutter app still talks only to the Airesume backend. The 8B Q4 model download is about 5.2 GB. This development machine reports 16 GiB system RAM and an RTX 4070 Laptop GPU with 8 GiB VRAM; that makes `qwen3:8b` a reasonable starting point, not a verified performance guarantee. If memory is tight, choose a smaller model such as `qwen3:4b`.

To use OpenAI instead, leave `AI_PROVIDER` unset or set it to `openai`, then provide your own OpenAI API key to the backend PowerShell session without putting it in command history:

```powershell
$secureKey = Read-Host 'Enter your OpenAI API key' -AsSecureString
$env:OPENAI_API_KEY = [System.Net.NetworkCredential]::new('', $secureKey).Password
```

Then start the backend and check its health from the same window:

```powershell
npm run check
npm test
npm start
```

In a second PowerShell window, check the health endpoint and launch Flutter on the running Android emulator:

```powershell
Invoke-RestMethod http://localhost:3000/health
Set-Location C:\Users\jaxon\OneDrive\Documents\GitHub\Airesume
flutter devices
flutter run -d emulator-5554
```

The service listens on port 3000 by default; set `$env:PORT = "3001"` before `npm start` to change it. `npm start` loads `backend/.env` via Node's `--env-file-if-exists` support. Flutter uses `http://10.0.2.2:3000` by default on Android emulator and `http://localhost:3000` on Windows desktop. Override with `--dart-define=API_BASE_URL=http://10.0.2.2:3000` when needed. For Flutter Web, allow its exact origin with `CORS_ALLOWED_ORIGINS` (for example `http://localhost:5000`) and start Chrome using `--web-port=5000`. Never commit a local `.env` or send a provider key to Flutter. Local Ollama inference needs no provider key; `/health` does not test provider availability.

### Backend configuration troubleshooting

- **The app says analysis is not configured:** check `AI_PROVIDER`. For OpenAI, set your own `OPENAI_API_KEY` in the backend environment or ignored `.env`. For Ollama, set `AI_PROVIDER=ollama`, start the Ollama app/service, and confirm `OLLAMA_BASE_URL` and `OLLAMA_MODEL`; install a missing model with `ollama pull <model>`. Restart the backend after changing settings. A successful `/health` response only confirms the backend is listening.
- **Ollama is unavailable or the model is missing:** run `ollama list`, start Ollama, and verify `http://127.0.0.1:11434/api/tags` responds. Pull the configured `OLLAMA_MODEL`. Ollama model inference stays on the local host when `OLLAMA_BASE_URL` uses the local address.
- **`npm start` reports `EADDRINUSE` on port 3000:** a backend is already listening. Stop that instance in the PowerShell window where it was started, then launch one instance with the key configured.
- **The emulator cannot reach the backend:** leave `npm start` running on Windows, confirm `Invoke-RestMethod http://localhost:3000/health` succeeds on Windows, then confirm the app uses `http://10.0.2.2:3000` (the default). Do not use `localhost` as the emulator's host address.
- **OpenAI analysis fails:** verify your API account can use the configured `OPENAI_MODEL` and that the key has API access/billing enabled. Provider errors are intentionally returned without secret values.
- **Cloud models:** this project does not configure Ollama Cloud. Cloud inference requires an Ollama account/sign-in or API key, network access, and is subject to its usage terms; resume text leaves the machine. Choose it only after reviewing data handling and costs.

## Checks

The locally verified commands and outcomes are recorded in [the handover](docs/HANDOVER.md). [GitHub Actions](https://github.com/Jaxonsvec/Resumechecker/actions) is configured for Flutter and backend checks; the latest observed runs passed for commit `bf7d895`. Changes made after that commit have not been pushed or checked by GitHub CI.
