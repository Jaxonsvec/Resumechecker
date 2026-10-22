import assert from 'node:assert/strict';
import { test } from 'node:test';
import { extractResumeText, ResumeFileError } from '../src/resume_text.js';

test('resume extraction rejects fake PDF and DOCX files by signature', async () => {
  await assert.rejects(
    extractResumeText({ originalname: 'resume.pdf', buffer: Buffer.from('not a PDF') }),
    (error) => error instanceof ResumeFileError && error.code === 'INVALID_FILE',
  );
  await assert.rejects(
    extractResumeText({ originalname: 'resume.docx', buffer: Buffer.from('not a ZIP document') }),
    (error) => error instanceof ResumeFileError && error.code === 'INVALID_FILE',
  );
});
