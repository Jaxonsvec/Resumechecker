import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { createServer } from 'node:http';
import { createApp } from '../src/app.js';
import { ResumeFileError } from '../src/resume_text.js';
import { createResumeAnalyzer } from '../src/providers/resume_analyzer.js';

let server;
let baseUrl;
let seenInput;
const expectedAnalysis = {
  summary: 'Clear, concise resume with relevant experience.',
  strengths: [{ title: 'Relevant experience', evidence: 'Led a team of four.' }],
  improvements: [{
    title: 'Add measurable impact',
    evidence: 'The role description has no outcome metrics.',
    recommendation: 'Add a truthful result or scale where available.',
  }],
  missing_information: ['Education details'],
};

before(async () => {
  const app = createApp({
    textExtractor: async () => 'Synthetic resume text. Led a team of four.',
    analyzer: {
      async analyze(input) {
        seenInput = input;
        return expectedAnalysis;
      },
    },
  });
  server = createServer(app);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) =>
    server.close((error) => (error ? reject(error) : resolve())),
  );
});

function uploadForm({ filename = 'resume.pdf', bytes = '%PDF-test', targetRole } = {}) {
  const form = new FormData();
  form.append('resume', new Blob([bytes], { type: 'application/octet-stream' }), filename);
  if (targetRole !== undefined) form.append('targetRole', targetRole);
  return form;
}

test('health returns the validated service status', async () => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('analysis uploads a resume, passes extracted text to the analyzer, and validates output', async () => {
  const response = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    body: uploadForm({ targetRole: 'Product engineer' }),
  });
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { analysis: expectedAnalysis });
  assert.deepEqual(seenInput, {
    resumeText: 'Synthetic resume text. Led a team of four.',
    targetRole: 'Product engineer',
  });
});

test('analysis requires a resume and rejects unsupported extensions', async () => {
  const missing = await fetch(`${baseUrl}/api/v1/analyses`, { method: 'POST', body: new FormData() });
  assert.equal(missing.status, 400);
  assert.equal((await missing.json()).error.code, 'INVALID_REQUEST');

  const unsupported = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    body: uploadForm({ filename: 'resume.txt' }),
  });
  assert.equal(unsupported.status, 415);
  assert.equal((await unsupported.json()).error.code, 'UNSUPPORTED_FILE_TYPE');
});

test('analysis rejects uploads larger than 10 MiB', async () => {
  const response = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    body: uploadForm({ bytes: Buffer.alloc(10 * 1024 * 1024 + 1) }),
  });
  assert.equal(response.status, 413);
  assert.equal((await response.json()).error.code, 'FILE_TOO_LARGE');
});

test('analysis protects provider and text extraction errors with stable responses', async () => {
  const missingProvider = createServer(createApp({
    textExtractor: async () => 'Synthetic resume.',
    analyzer: { async analyze() { const error = new Error(); error.code = 'PROVIDER_NOT_CONFIGURED'; throw error; } },
  }));
  await new Promise((resolve) => missingProvider.listen(0, '127.0.0.1', resolve));
  const unavailable = await fetch(`http://127.0.0.1:${missingProvider.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  assert.equal(unavailable.status, 503);
  assert.equal((await unavailable.json()).error.code, 'ANALYSIS_UNAVAILABLE');
  await new Promise((resolve) => missingProvider.close(resolve));

  const badDocumentApp = createServer(createApp({
    textExtractor: async () => { throw new ResumeFileError('NO_EXTRACTABLE_TEXT', 'No text could be extracted.'); },
    analyzer: { async analyze() { assert.fail('Analyzer must not receive empty document text.'); } },
  }));
  await new Promise((resolve) => badDocumentApp.listen(0, '127.0.0.1', resolve));
  const unreadable = await fetch(`http://127.0.0.1:${badDocumentApp.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  assert.equal(unreadable.status, 422);
  assert.equal((await unreadable.json()).error.code, 'NO_EXTRACTABLE_TEXT');
  await new Promise((resolve) => badDocumentApp.close(resolve));

  const invalidResultApp = createServer(createApp({
    textExtractor: async () => 'Synthetic resume.',
    analyzer: { async analyze() { return { summary: 'Incomplete result' }; } },
  }));
  await new Promise((resolve) => invalidResultApp.listen(0, '127.0.0.1', resolve));
  const invalidResult = await fetch(`http://127.0.0.1:${invalidResultApp.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  assert.equal(invalidResult.status, 502);
  assert.equal((await invalidResult.json()).error.code, 'INVALID_ANALYSIS_RESPONSE');
  await new Promise((resolve) => invalidResultApp.close(resolve));
});

test('analysis maps provider timeouts and rate limits to stable errors', async () => {
  let timeoutSignal;
  let requestedTimeout;
  const originalTimeout = AbortSignal.timeout;
  AbortSignal.timeout = (milliseconds) => {
    requestedTimeout = milliseconds;
    return originalTimeout(milliseconds);
  };
  const timeoutServer = createServer(createApp({
    textExtractor: async () => 'Synthetic resume.',
    analyzer: {
      async analyze(_input, { signal }) {
        timeoutSignal = signal;
        const error = new Error('provider details must not escape');
        error.name = 'TimeoutError';
        throw error;
      },
    },
  }));
  await new Promise((resolve) => timeoutServer.listen(0, '127.0.0.1', resolve));
  let timedOut;
  try {
    timedOut = await fetch(`http://127.0.0.1:${timeoutServer.address().port}/api/v1/analyses`, {
      method: 'POST', body: uploadForm(),
    });
  } finally {
    AbortSignal.timeout = originalTimeout;
  }
  const timeoutPayload = await timedOut.json();
  assert.equal(timedOut.status, 504);
  assert.equal(timeoutPayload.error.code, 'ANALYSIS_TIMEOUT');
  assert.doesNotMatch(JSON.stringify(timeoutPayload), /provider details/);
  assert.ok(timeoutSignal instanceof AbortSignal);
  assert.equal(requestedTimeout, 35_000);
  await new Promise((resolve) => timeoutServer.close(resolve));

  const rateLimitServer = createServer(createApp({
    textExtractor: async () => 'Synthetic resume.',
    analyzer: {
      async analyze() {
        const error = new Error('provider details must not escape');
        error.status = 429;
        throw error;
      },
    },
  }));
  await new Promise((resolve) => rateLimitServer.listen(0, '127.0.0.1', resolve));
  const busy = await fetch(`http://127.0.0.1:${rateLimitServer.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  const busyPayload = await busy.json();
  assert.equal(busy.status, 503);
  assert.equal(busyPayload.error.code, 'ANALYSIS_BUSY');
  assert.doesNotMatch(JSON.stringify(busyPayload), /provider details/);
  await new Promise((resolve) => rateLimitServer.close(resolve));
});

test('unexpected provider failures do not expose resume text or secret-like details', async () => {
  const failureServer = createServer(createApp({
    textExtractor: async () => 'SYNTHETIC_RESUME_SENTINEL',
    analyzer: {
      async analyze() {
        throw new Error('SYNTHETIC_RESUME_SENTINEL sk-test-secret-sentinel');
      },
    },
  }));
  await new Promise((resolve) => failureServer.listen(0, '127.0.0.1', resolve));
  const response = await fetch(`http://127.0.0.1:${failureServer.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  const payload = await response.json();
  assert.equal(response.status, 502);
  assert.equal(payload.error.code, 'ANALYSIS_FAILED');
  assert.doesNotMatch(JSON.stringify(payload), /SYNTHETIC_RESUME_SENTINEL|sk-test-secret-sentinel/);
  await new Promise((resolve) => failureServer.close(resolve));
});

test('missing OpenAI key returns actionable setup steps without exposing credentials', async () => {
  const missingKeyServer = createServer(createApp({
    textExtractor: async () => 'Synthetic resume.',
    analyzer: createResumeAnalyzer({ apiKey: '' }),
  }));
  await new Promise((resolve) => missingKeyServer.listen(0, '127.0.0.1', resolve));

  const response = await fetch(`http://127.0.0.1:${missingKeyServer.address().port}/api/v1/analyses`, {
    method: 'POST', body: uploadForm(),
  });
  const payload = await response.json();
  assert.equal(response.status, 503);
  assert.equal(payload.error.code, 'ANALYSIS_UNAVAILABLE');
  assert.match(payload.error.message, /OPENAI_API_KEY/);
  assert.match(payload.error.message, /backend\/\.env/);
  assert.doesNotMatch(JSON.stringify(payload), /sk-[a-z0-9]+/i);
  await new Promise((resolve) => missingKeyServer.close(resolve));
});

test('the untouched example-key placeholder is treated as missing configuration', async () => {
  const analyzer = createResumeAnalyzer({ apiKey: 'replace-with-a-server-side-key' });
  await assert.rejects(
    analyzer.analyze({ resumeText: 'Synthetic resume.' }),
    { code: 'PROVIDER_NOT_CONFIGURED' },
  );
});

test('Ollama availability failures return safe setup messages', async () => {
  for (const [code, expectedText] of [
    ['OLLAMA_UNAVAILABLE', /Start Ollama/],
    ['OLLAMA_MODEL_NOT_FOUND', /Pull OLLAMA_MODEL/],
  ]) {
    const localFailureServer = createServer(createApp({
      textExtractor: async () => 'Synthetic resume.',
      analyzer: {
        async analyze() {
          const error = new Error('private local service detail');
          error.code = code;
          throw error;
        },
      },
    }));
    await new Promise((resolve) => localFailureServer.listen(0, '127.0.0.1', resolve));
    const response = await fetch(`http://127.0.0.1:${localFailureServer.address().port}/api/v1/analyses`, {
      method: 'POST', body: uploadForm(),
    });
    const payload = await response.json();
    assert.equal(response.status, 503);
    assert.equal(payload.error.code, code);
    assert.match(payload.error.message, expectedText);
    assert.doesNotMatch(JSON.stringify(payload), /private local service detail/);
    await new Promise((resolve) => localFailureServer.close(resolve));
  }
});

test('malformed JSON and unknown routes use the shared error shape', async () => {
  const malformed = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: '{',
  });
  assert.equal(malformed.status, 400);
  assert.equal((await malformed.json()).error.code, 'INVALID_JSON');

  const unknown = await fetch(`${baseUrl}/missing`);
  assert.equal(unknown.status, 404);
  assert.equal((await unknown.json()).error.code, 'NOT_FOUND');
});

test('CORS preflight is limited to configured development origins', async () => {
  const corsServer = createServer(createApp({ allowedOrigins: ['http://localhost:5000'] }));
  await new Promise((resolve) => corsServer.listen(0, '127.0.0.1', resolve));
  const url = `http://127.0.0.1:${corsServer.address().port}/api/v1/analyses`;

  const allowed = await fetch(url, {
    method: 'OPTIONS',
    headers: { origin: 'http://localhost:5000' },
  });
  assert.equal(allowed.status, 204);
  assert.equal(allowed.headers.get('access-control-allow-origin'), 'http://localhost:5000');

  const denied = await fetch(url, {
    method: 'OPTIONS',
    headers: { origin: 'https://unapproved.example' },
  });
  assert.equal(denied.status, 404);
  assert.equal(denied.headers.get('access-control-allow-origin'), null);
  await new Promise((resolve) => corsServer.close(resolve));
});
