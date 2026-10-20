# Instructions for AI coding agents

## Required onboarding order

After discovering these instructions, make reading `docs/HANDOVER.md` completely your first project-specific action. Do this before editing files, installing or updating dependencies, running setup scripts, or beginning implementation.

After the handover, read these files:

1. `README.md`
2. `docs/SETUP_CHECKLIST.md`
3. `docs/DEVELOPMENT_CHECKLIST.md`

Then inspect Git status, the current branch, recent commits, repository structure, and the code relevant to the task. Review implementation directly instead of relying on documentation alone. Before implementation, summarize the project state, any discrepancies you found, and the proposed next steps in a concise user-facing update.

## Project context

Airesume is a Flutter-first AI resume-analysis application with a supporting Express/Zod backend. The repository is a starter foundation, not a complete resume-analysis product. Verify the current code before claiming any capability exists. In particular, check whether resume file selection, upload, parsing, AI analysis, scoring, recommendations, or history have actually been implemented.

The Flutter app belongs at the repository root (`lib/`, `test/`, `android/`). Keep backend code in `backend/`. Follow the established structure, dependency constraints, environment configuration, and documentation conventions.

## Working rules

- Preserve all existing user and teammate changes. Do not reset, clean, overwrite, or remove unrelated work.
- Use a feature branch for new work when appropriate.
- Never commit, push, merge, or open a pull request without explicit user authorization.
- Never claim a feature, test, build, or CI check works unless you verified it. Distinguish local results from GitHub CI results.
- Protect credentials and personal resume data. Never place provider secrets in Flutter or commit real `.env` files. Avoid exposing sensitive values in logs or test output, and avoid live provider requests or unnecessary external costs.
- Update relevant documentation and development checklist items as implementation changes. Check a task only when it is implemented and its relevant verification passes; leave incomplete or unverified work unchecked.
- At the end of a session, report files changed, checks actually run and their results, failures, remaining work, and Git status.
