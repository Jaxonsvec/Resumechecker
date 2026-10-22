# Airesume project handover

Updated 22 October 2026. This describes the current checkout and separates implemented source from verified behavior.

## Purpose and status

Airesume is a Flutter-first app for AI-assisted resume feedback. Phase 3 selection, the Phase 4/5 backend analyzer, and the Phase 6 Flutter upload/result workflow are implemented in source on `codex/phase-3-resume-input`. Flutter formatting, static analysis, and automated tests pass locally. Backend syntax checks and eight mocked API/unit tests pass using the existing local `node_modules`. The original demo branch ref remains unchanged; work is uncommitted on this feature branch.

The Flutter app now requests explicit processing consent, uploads the selected PDF/DOCX and optional target role, shows a loading state, parses structured feedback, and supports retry after safe errors. No real resume, provider key, or live model request was used. Android emulator/device execution, live provider execution, npm clean-install/lockfile verification, and GitHub CI remain unverified.

## Current architecture

- **Flutter:** The app lives at the repository root. `lib/screens/resume_selection_screen.dart` selects PDF/DOCX files up to 10 MiB, requests processing consent, and gathers an optional target role. `lib/services/resume_analysis_api.dart` sends the multipart upload to `POST /api/v1/analyses`; progress, retryable errors, and structured result screens are implemented. The API base URL can be set with `--dart-define=API_BASE_URL=...`.
- **Backend:** `backend/` is an Express 5 / Zod 4 API. `GET /health` reports service status. `POST /api/v1/analyses` accepts one multipart `resume` file (PDF or DOCX, up to 10 MiB) and optional `targetRole` (up to 200 characters), validates extension/signature/size, extracts text in memory, and calls an injected analyzer. Extracted text is limited to 100,000 characters. Files are not written to disk or logged by application code. PDFs without embedded text return an explicit error; OCR is not implemented.
- **Provider:** `backend/src/providers/resume_analyzer.js` uses OpenAI Responses API with structured output and a configurable `OPENAI_MODEL` default. It reads `OPENAI_API_KEY` only on the backend, uses `store: false`, and has a 30-second SDK timeout. No real key or model call was used. Output has summary, evidence-based strengths and improvements, and missing-information notes; no numeric score or hiring prediction.
- **Tests and dependencies:** Flutter `dart format`, `flutter analyze`, and `flutter test` pass locally. Backend `npm run check` and eight mocked tests pass with installed dependencies. `backend/package-lock.json` has not been refreshed because npm registry DNS access failed; clean install is unverified. No commit is authorized.
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

Backend setup after restoring npm registry access:

```powershell
cd backend
npm install
npm run check
npm test
npm start
```

`npm start` loads an optional ignored `backend/.env`. Copy `.env.example` and set a server-side `OPENAI_API_KEY`; `OPENAI_MODEL` is optional and defaults to `gpt-5.6-terra`. Never put provider credentials in Flutter or commit a real `.env`. Real analysis requests can incur usage charges. Do not use a real resume for routine tests.

## Verification record

**Verified locally on 22 October 2026:** `dart format lib test` and format check, `flutter analyze`, all 15 Flutter tests, `flutter build apk --debug`, backend `npm run check`, and all eight mocked backend tests pass. The Flutter test suite covers request construction, safe API errors, consent, retry, and rendering returned analysis content.

**Not verified for the current backend source:** clean dependency installation/lockfile consistency, PDF/DOCX extraction against real synthetic files, or live provider access. Both the sandboxed and elevated npm install attempts failed because DNS lookup for `registry.npmjs.org` failed. The mocked API tests passed with current local packages. No live OpenAI call was made. `flutter devices` listed Windows and browser targets but no Android emulator/device; `flutter run` on Android and GitHub CI have not been verified.

## Next steps

1. Restore npm registry access, refresh `backend/package-lock.json`, and verify a clean `npm ci`.
2. Verify PDF/DOCX extraction with synthetic documents; do not use a live resume for this step.
3. Launch Flutter on an Android emulator/device and verify the server connection; inspect GitHub CI separately.
4. Resolve authentication, retention/deletion, provider data handling, and production deployment decisions before production use.

## Keeping the handover current

When architecture, verified behavior, environment requirements, test results, or the next task changes, update this file and the matching development checklist. Mark checklist items complete only after implementation and relevant verification; report local and GitHub CI results separately.
