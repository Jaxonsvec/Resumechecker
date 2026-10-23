# Airesume project handover

Updated 23 October 2026. This describes the current checkout and separates implemented source from verified behavior.

## Purpose and status

Airesume is a Flutter-first app for AI-assisted resume feedback. Phase 3 selection, the Phase 4/5 backend analyzer, and the Phase 6 Flutter upload/result workflow are implemented in source on `codex/phase-3-resume-input`. The backend supports OpenAI (default) and local Ollama selected by `AI_PROVIDER`; no provider key is required for local Ollama. The backend dependency update to OpenAI SDK 6.49.0 and the existing Zod 4 dependency are reflected in `package-lock.json`. Backend checks/tests and local Flutter checks pass. Existing uncommitted sprint changes were preserved; do not commit or push without authorization.

The Flutter app requests explicit processing consent, uploads the selected PDF/DOCX and optional target role, shows a loading state, parses structured feedback, and supports retry after safe errors. It also retains the pasted-text path, which uses local rule-based checks, and its standalone native file-selection preview, which only displays metadata and is not an upload. `backend/.env` is absent and ignored by Git. `AI_PROVIDER` is not set in this checkout, so the default OpenAI provider remains unconfigured without `OPENAI_API_KEY`. Local Ollama was installed and a synthetic analysis through the API route succeeded with `qwen3:8b`; the test used an injected synthetic text extractor, not a personal resume. A successful `/health` response only confirms the server is listening, not that the provider is configured.

## Current architecture

- **Flutter:** The app lives at the repository root. `lib/screens/resume_selection_screen.dart` selects PDF/DOCX files up to 10 MiB, requests processing consent, and gathers an optional target role. `lib/services/resume_analysis_api.dart` sends the multipart upload to `POST /api/v1/analyses`; progress, retryable errors, and structured result screens are implemented. `lib/screens/resume_input_screen.dart` accepts pasted text for local `ResumeChecker` feedback. `lib/resume_upload_screen.dart` is the separate file-selector preview only; it does not submit files. The API base URL can be set with `--dart-define=API_BASE_URL=...`.
- **Backend:** `backend/` is an Express 5 / Zod 4 API. `GET /health` reports service status. `POST /api/v1/analyses` accepts one multipart `resume` file (PDF or DOCX, up to 10 MiB) and optional `targetRole` (up to 200 characters), validates extension/signature/size, extracts text in memory, and calls an injected analyzer. Extracted text is limited to 100,000 characters. Files are not written to disk or logged by application code. PDFs without embedded text return an explicit error; OCR is not implemented.
- **Provider:** `AI_PROVIDER=openai` (default) uses the OpenAI Responses API with structured output, `OPENAI_MODEL` default `gpt-5.6-terra`, server-only `OPENAI_API_KEY`, `store: false`, and a 30-second SDK timeout. `AI_PROVIDER=ollama` uses the local `http://127.0.0.1:11434/api/chat` API, JSON Schema format, `OLLAMA_MODEL` default `qwen3:8b`, `OLLAMA_NUM_CTX` default 8192, no OpenAI key, and a 180-second timeout. Ollama thinking is disabled for concise structured feedback. The installed `qwen3:8b` Q4_K_M model is 5.2 GB; this machine reports 16 GiB RAM and an NVIDIA RTX 4070 Laptop GPU with 8 GiB VRAM. A synthetic real local inference through the Express route returned HTTP 200. No OpenAI call or cloud inference was made. [Ollama API documentation](https://docs.ollama.com/api/introduction) documents the local base URL; [structured outputs](https://docs.ollama.com/capabilities/structured-outputs) documents JSON Schema; [thinking controls](https://docs.ollama.com/capabilities/thinking) documents disabling thinking.
- **Configuration:** `npm start` runs Node's `--env-file-if-exists=.env` from `backend/`; this was verified with a temporary sentinel value and no real secret. `backend/.gitignore` excludes `.env`; no local `backend/.env` exists. Keep keys out of Flutter and Android.
- **Tests and dependencies:** Current backend `npm run check` passed and all 17 backend tests passed, including mocked OpenAI/Ollama structured success and provider failure coverage. Current Flutter analysis passed, all 39 Flutter tests passed (one opt-in API override test skipped), and the Android debug APK built successfully. The real local Ollama API-route request also passed with synthetic extracted text. A separate clean archive of commit `bf7d895` passed `npm ci` (102 packages, zero vulnerabilities), backend checks/tests, Flutter dependency resolution, formatting, analysis, and all 38 Flutter tests. No commit or push was made.
- **Privacy/production:** Authentication, consent, retention/deletion, provider data handling, and deployment controls remain open before processing real resumes in production. `store: false` does not replace a review of current provider terms and project privacy requirements.
- **CI:** `.github/workflows/flutter.yml` runs Flutter and backend CI on pushes and pull requests. GitHub Actions passed for the latest committed revision `bf7d895`; local sprint changes made after that run have not been pushed or run in CI.

## Repository structure

- `lib/`, `test/` — root Flutter app and widget tests.
- `android/` — generated Android host project; application ID is still `com.example.airesume`.
- `backend/src/`, `backend/test/` — Express API, PDF/DOCX extraction, provider adapter, and mocked API tests.
- `docs/` — setup, development, architecture, API contract, handover, and checklists.
- `.github/workflows/flutter.yml` — Flutter and backend CI.
- `AGENTS.md` — required onboarding and working instructions; read `docs/HANDOVER.md` first on each project task.

## Setup and run

Use Flutter 3.47.7 stable with Dart 3.13.5, Node.js 22.9 or newer, Git, VS Code/Flutter extension, Android Studio/SDK, an emulator/device, and Java 17 for Android builds. Flutter setup from a fresh clone:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Backend setup (see README for secure PowerShell key entry):

```powershell
cd backend
npm install
npm run check
npm test
npm start
```

`npm start` loads an optional ignored `backend/.env`. Copy `.env.example` and set a server-side `OPENAI_API_KEY`; `OPENAI_MODEL` is optional and defaults to `gpt-5.6-terra`. Never put provider credentials in Flutter or commit a real `.env`. Real analysis requests can incur usage charges. Do not use a real resume for routine tests.

## Verification record

**Verified locally on 23 October 2026:** backend syntax checks and 17 tests; Flutter analysis, 39 passing tests with one opt-in test skipped, and `flutter build apk --debug`. Ollama CLI 0.40.9 installed successfully; its local service returned model-list responses and `qwen3:8b` downloaded (5.2 GB). A synthetic PDF multipart request passed through a temporary Airesume Express API using the real local Ollama model and returned HTTP 200 with a schema-valid summary, strengths, improvements, and missing-information list. The test extractor was injected to return synthetic text, so it verified the provider and API integration without exercising PDF parsing in that request. `backend/.env` is ignored and absent; no OpenAI key is configured, and no OpenAI or cloud request was made. An earlier clean snapshot passed `npm ci` (102 packages; zero vulnerabilities) and Flutter checks. GitHub Actions passed for commit `bf7d895`; current changes are local and unpushed.

**Emulator status:** The Pixel 7 AVD was launched, reconnected, ADB was restarted, and the AVD was cold-booted without wiping data. ADB continued to report `emulator-5554` offline, so the app was not installed/launched and the Android upload flow was not verified in this sprint. The debug/release APK builds are local build checks only.

**Not verified:** A teammate's fresh-clone run, screen review, live OpenAI request, Android emulator upload/analysis flow, production retention/cache policy, and GitHub CI for the current uncommitted work. CI passed for `bf7d895`; current changes were not pushed.

## Next steps

1. Ask another teammate to follow the README fresh-clone steps, run Flutter/backend setup, and report whether the app launches (checklist item 1.7).
2. Restart the Pixel 7 AVD from Android Studio Device Manager until `flutter devices` shows it online, then run `flutter run -d emulator-5554` and verify selection, consent, upload, progress, and safe missing-key behavior.
3. To use local inference, set `AI_PROVIDER=ollama`, `OLLAMA_MODEL=qwen3:8b`, and start the Ollama service before `npm start`; no OpenAI key is needed. To use OpenAI, add the developer's own `OPENAI_API_KEY` to the backend process environment or ignored `backend/.env`. Never paste provider keys into Flutter or commit them.
4. Review local changes, then push only with authorization and observe CI for that new commit; current `bf7d895` CI was successful.
5. Resolve native-picker cache retention, provider data handling, and production deployment decisions before processing real resumes in production.

## Keeping the handover current

When architecture, verified behavior, environment requirements, test results, or the next task changes, update this file and the matching development checklist. Mark checklist items complete only after implementation and relevant verification; report local and GitHub CI results separately.
