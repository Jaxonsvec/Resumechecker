# Airesume project handover

Updated 23 October 2026. This handover describes the current local checkout and distinguishes implementation from verified behavior.

## Current state

Airesume is a Flutter resume-analysis app with a Node.js/Express backend. Current work is on `codex/phase-3-resume-input`. The working tree contains uncommitted implementation changes for the resume scoring, examples, compare/edit/regrade, image OCR, and Ollama support phases. Do not reset, clean, or overwrite these changes; do not commit or push without authorization.

The app supports PDF/DOCX selection and backend analysis, pasted-text local checks, local fictional examples, score/category comparison, an editable draft with accepted/rejected rewrite suggestions and regrading, and JPG/PNG image resume input. Image OCR uses ML Kit on-device (Android/iOS); it is not a cloud OCR call. The backend supports OpenAI and local Ollama through `AI_PROVIDER`. Ollama can run without an OpenAI key. No OpenAI key is configured and no OpenAI or Ollama Cloud request was made.

**Current demo session:** `emulator-5554` is open on the analysis results screen. The app was launched with `API_BASE_URL=http://10.0.2.2:3001`; the current checkout's local Ollama backend is running on Windows port 3001 so another analysis can be tried. A pre-existing server on port 3000 was left untouched.

## Architecture

- **Flutter:** `lib/` and `test/` at repository root. `HttpResumeAnalysisApi` chooses Android emulator `http://10.0.2.2:3000`, Windows `http://localhost:3000`, or compile-time override `API_BASE_URL`. PDF/DOCX uploads use `POST /api/v1/analyses`; edited or OCR text uses `POST /api/v1/analyses/text`. The same five-category score schema is validated by Dart. Revision history and draft persist only while the current results/editor route session remains alive; they are not saved across app restarts.
- **Image input:** `ResumeImageInputScreen` selects/takes JPG/PNG, enforces a 15 MiB limit, runs local ML Kit OCR, lets the user edit extracted text, and asks consent before sending it to the backend. Text must be reviewed because OCR can be inaccurate.
- **Backend:** `backend/` is Express 5 / Zod 4. `POST /api/v1/analyses` validates one PDF/DOCX up to 10 MiB, extracts text in memory (up to 100,000 characters), and analyzes it. The text route accepts 1–100,000 characters and an optional target role. Uploads/resume text are not written to disk or logged by application code. PDFs without extractable embedded text need the image/OCR path.
- **Scoring:** five bounded category scores (clarity, impact, measurable results, skills/experience, formatting/organization); overall score is the rounded arithmetic mean. The rubric, examples, and limitations are documented in `docs/SCORING_RUBRIC.md`. Scores are guidance, not hiring or ATS predictions.
- **Provider:** default `AI_PROVIDER=openai` uses OpenAI Responses structured output, model `gpt-5.6-terra` by default, and server-only `OPENAI_API_KEY`. `AI_PROVIDER=ollama` uses Ollama's local `http://127.0.0.1:11434/api/chat`, JSON Schema output, default `qwen3:8b`, context 8192, and a 180-second timeout. Ollama thinking is disabled for concise output. Machine reported 16 GiB RAM and RTX 4070 Laptop GPU with 8 GiB VRAM; Qwen3 8B quantized model is installed locally. Local-only model inference does not require login or credentials. Do not configure cloud models without an explicit privacy/network/account/usage review.
- **Configuration:** `backend/.env.example` contains placeholders. `backend/.env` is ignored and absent. `npm start` reads optional `.env`. Never place provider keys in Flutter, Android resources, tracked files, or logs.

## Verified on 23 October 2026

- Backend: `npm run check` passed; `npm test` passed all 21 tests. Tests mock provider requests for automated tests.
- Flutter: Dart format check passed; `flutter analyze` reported no issues; `flutter test` passed 49 tests with one opt-in API override test skipped by default.
- Android: `flutter build apk --debug --no-pub` succeeded. Emulator `emulator-5554` was online and the app ran. A synthetic image was selected from gallery; ML Kit extracted its synthetic text on-device; after consent, the app sent the text through the Android emulator host URL to a temporary local Airesume backend on port 3001 and the local Ollama `qwen3:8b` model. The results screen showed a structured score and category feedback. This verifies actual local inference and app-to-backend connectivity with synthetic data, not analysis quality for real resumes.
- Separate provider check: a synthetic request through the API route returned HTTP 200 with structured results. No personal resume was used.
- OpenAI: not verified. No real `OPENAI_API_KEY` is configured or supplied. Cloud Ollama is not configured or tested.
- GitHub CI: local changes remain uncommitted/unpushed and have not been checked by GitHub Actions. Existing CI evidence applies to the previously committed revision only.

## Setup

Use Node.js 22.9+ and Flutter 3.47.7 stable/Dart 3.13.5, plus Android Studio/SDK and Java 17 for Android builds.

Backend from PowerShell:

```powershell
Set-Location C:\Users\jaxon\OneDrive\Documents\GitHub\Airesume\backend
npm install
Copy-Item .env.example .env
# Edit .env and select AI_PROVIDER=ollama for local Ollama, or AI_PROVIDER=openai with your own server-side key.
npm run check
npm test
npm start
```

For OpenAI, enter your own key into the ignored local `backend/.env` file; never paste it into Flutter or commit it. For Ollama, install/start Ollama, then run `ollama pull qwen3:8b`, set `AI_PROVIDER=ollama`, and leave `OLLAMA_BASE_URL=http://127.0.0.1:11434`. Set `OLLAMA_MODEL` if using a different local model. A successful `/health` only indicates the API server is listening.

Check health and launch the Android app in another PowerShell window:

```powershell
Invoke-RestMethod http://localhost:3000/health
Set-Location C:\Users\jaxon\OneDrive\Documents\GitHub\Airesume
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Android emulator uses `10.0.2.2` to reach the Windows host. For a different URL, pass `--dart-define=API_BASE_URL=http://10.0.2.2:3000` at `flutter run`. If port 3000 is busy, stop the old server or choose a different `PORT` and matching API URL. If Ollama is unavailable, check `ollama list`, service status, `/api/tags`, and that configured model is pulled. Do not use `/health` to infer provider readiness.

## Remaining work

- 6.8 and 11.8 remain open: verify the complete PDF/DOCX upload plus editor/regrade flow on a real device/emulator. The image OCR → local Ollama flow is verified.
- 5.3 and 5.10 remain open: provide a valid OpenAI key if OpenAI is desired and perform an authorized live request; otherwise local Ollama is a functioning option. Do not fabricate a key.
- 9.8 teammate setup/review and production acceptance/privacy tasks remain open. Review retention, provider data handling, and deployment controls before real personal resumes are processed in production.
- Update the docs/checklist whenever verification or implementation changes. Checklist totals currently show 74 complete and 15 open; complete only after its stated verification passes.

No commit, push, merge, or branch change was made.
