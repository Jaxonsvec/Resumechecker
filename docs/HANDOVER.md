# Airesume project handover

Updated 22 October 2026. This describes the current checkout and separates implemented source from verified behavior.

## Purpose and status

Airesume is a Flutter-first app for AI-assisted resume feedback. Phase 3 selection, the Phase 4/5 backend analyzer, and the Phase 6 Flutter upload/result workflow are implemented in source on `codex/phase-3-resume-input`. The backend dependency update to OpenAI SDK 6.49.0 and the existing Zod 4 dependency are reflected in `package-lock.json`; `npm install` reports up to date. Backend configuration tests and local Flutter/backend checks pass. No real OpenAI key has been supplied. Existing local changes must be preserved; do not commit or push without authorization.

The Flutter app requests explicit processing consent, uploads the selected PDF/DOCX and optional target role, shows a loading state, parses structured feedback, and supports retry after safe errors. Android emulator networking to the host backend was verified by requesting `/health` at `10.0.2.2:3000`; a full resume analysis on-device and live provider request were not made. `backend/.env` is absent and ignored by Git. The current server reports `ANALYSIS_UNAVAILABLE` if it starts without `OPENAI_API_KEY`; the Flutter message now tells the developer how to configure it. A successful `/health` response only confirms the server is listening, not that the provider is configured.

## Current architecture

- **Flutter:** The app lives at the repository root. `lib/screens/resume_selection_screen.dart` selects PDF/DOCX files up to 10 MiB, requests processing consent, and gathers an optional target role. `lib/services/resume_analysis_api.dart` sends the multipart upload to `POST /api/v1/analyses`; progress, retryable errors, and structured result screens are implemented. The API base URL can be set with `--dart-define=API_BASE_URL=...`.
- **Backend:** `backend/` is an Express 5 / Zod 4 API. `GET /health` reports service status. `POST /api/v1/analyses` accepts one multipart `resume` file (PDF or DOCX, up to 10 MiB) and optional `targetRole` (up to 200 characters), validates extension/signature/size, extracts text in memory, and calls an injected analyzer. Extracted text is limited to 100,000 characters. Files are not written to disk or logged by application code. PDFs without embedded text return an explicit error; OCR is not implemented.
- **Provider:** `backend/src/providers/resume_analyzer.js` uses OpenAI Responses API with structured output and a configurable `OPENAI_MODEL` default. OpenAI's model page lists `gpt-5.6-terra` as supporting Responses and Structured Outputs. It reads `OPENAI_API_KEY` only on the backend, uses `store: false`, and has a 30-second SDK timeout. No real key or model call was used. Output has summary, evidence-based strengths and improvements, and missing-information notes; no numeric score or hiring prediction.
- **Configuration:** `npm start` runs Node's `--env-file-if-exists=.env` from `backend/`; this was verified with a temporary sentinel value and no real secret. `backend/.gitignore` excludes `.env`; no local `backend/.env` exists. Keep keys out of Flutter and Android.
- **Tests and dependencies:** `npm install` succeeded and reported the lockfile up to date; `npm run check` and all ten backend tests pass. `flutter analyze` and all 16 Flutter tests pass; the compile-time `API_BASE_URL` test also passes when run with a `--dart-define`. Clean `npm ci` was not run. No commit is authorized.
- **Privacy/production:** Authentication, consent, retention/deletion, provider data handling, and deployment controls remain open before processing real resumes in production. `store: false` does not replace a review of current provider terms and project privacy requirements.
- **CI:** `.github/workflows/flutter.yml` runs Flutter and backend CI on pushes and pull requests. GitHub Actions has not been observed for this branch.

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

**Verified locally on 22 October 2026:** `npm install` (up to date, zero audit findings), `npm run check`, ten backend tests, Dart formatting, `flutter analyze`, 16 Flutter tests, and a separate passing `API_BASE_URL` override test. A test confirmed Node loads env files without printing their values. `git check-ignore` confirms `backend/.env` is ignored. Windows and Android emulator both reached the host health endpoint; emulator request to `http://10.0.2.2:3000/health` returned `{"status":"ok"}`.

**Not verified:** `npm ci`, PDF/DOCX extraction against synthetic documents, live OpenAI credentials/provider request, full Android upload/analysis flow, and GitHub CI. The active port 3000 listener was already running; a second `npm start` reported `EADDRINUSE`, so preserve that process and restart it from the intended terminal after setting a developer-owned key.

## Next steps

1. Add the developer's own `OPENAI_API_KEY` to the backend process environment or ignored `backend/.env`, restart the server, and verify one intentional test analysis. Never paste the key into Flutter or commit it.
2. Verify PDF/DOCX extraction with synthetic documents and finish the full upload flow on the emulator.
3. Run `npm ci` from the current lockfile, then inspect GitHub CI separately.
4. Resolve authentication, retention/deletion, provider data handling, and production deployment decisions before production use.

## Keeping the handover current

When architecture, verified behavior, environment requirements, test results, or the next task changes, update this file and the matching development checklist. Mark checklist items complete only after implementation and relevant verification; report local and GitHub CI results separately.
