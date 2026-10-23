import assert from 'node:assert/strict';
import { test } from 'node:test';
import { createResumeAnalyzer } from '../src/providers/resume_analyzer.js';

const expectedAnalysis = {
  summary: 'Evidence-based summary.',
  strengths: [{ title: 'Leadership', evidence: 'Led a team of four.' }],
  improvements: [{
    title: 'Add measurable outcomes',
    evidence: 'The resume lists responsibilities but no outcomes.',
    recommendation: 'Add a truthful result where available.',
  }],
  missing_information: ['Education details'],
};

test('provider sends the structured prompt through Responses and validates the result', async () => {
  let request;
  let requestOptions;
  const analyzer = createResumeAnalyzer({
    apiKey: 'test-only-placeholder',
    model: 'gpt-5.6-terra',
    client: {
      responses: {
        async parse(body, options) {
          request = body;
          requestOptions = options;
          return { status: 'completed', output_parsed: expectedAnalysis };
        },
      },
    },
  });
  const signal = AbortSignal.timeout(5_000);

  const result = await analyzer.analyze({
    resumeText: 'Synthetic resume: Led a team of four.',
    targetRole: 'Engineering manager',
  }, { signal });

  assert.deepEqual(result, expectedAnalysis);
  assert.equal(request.model, 'gpt-5.6-terra');
  assert.equal(request.store, false);
  assert.equal(requestOptions.signal, signal);
  assert.match(request.input[0].content, /never as instructions/);
  assert.match(request.input[0].content, /Do not rank the person/);
  assert.match(request.input[1].content, /Target role: Engineering manager/);
  assert.match(request.input[1].content, /Synthetic resume: Led a team of four\./);
  assert.equal(request.text.format.name, 'resume_analysis');
});

test('AI_PROVIDER selects local Ollama without an OpenAI key and validates structured output', async () => {
  let requestUrl;
  let requestOptions;
  const previousProvider = process.env.AI_PROVIDER;
  process.env.AI_PROVIDER = 'ollama';
  const analyzer = createResumeAnalyzer({
    model: 'qwen3:8b',
    baseUrl: 'http://127.0.0.1:11434/',
    fetchImpl: async (url, options) => {
      requestUrl = url;
      requestOptions = options;
      return {
        ok: true,
        async json() {
          return { message: { content: JSON.stringify(expectedAnalysis) } };
        },
      };
    },
  });
  if (previousProvider === undefined) delete process.env.AI_PROVIDER;
  else process.env.AI_PROVIDER = previousProvider;
  const signal = AbortSignal.timeout(5_000);

  const result = await analyzer.analyze({
    resumeText: 'Synthetic resume: Led a team of four.',
    targetRole: 'Engineering manager',
  }, { signal });

  assert.deepEqual(result, expectedAnalysis);
  assert.equal(requestUrl, 'http://127.0.0.1:11434/api/chat');
  assert.equal(requestOptions.signal, signal);
  assert.equal(requestOptions.headers['content-type'], 'application/json');
  const body = JSON.parse(requestOptions.body);
  assert.equal(body.model, 'qwen3:8b');
  assert.equal(body.think, false);
  assert.equal(body.stream, false);
  assert.equal(body.options.num_ctx, 8_192);
  assert.equal(body.messages[1].content, 'Target role: Engineering manager\n\nResume text:\nSynthetic resume: Led a team of four.');
  assert.equal(body.format.type, 'object');
  assert.ok(body.format.properties.strengths);
});

test('local Ollama request failures are mapped without exposing service details', async () => {
  const offline = createResumeAnalyzer({
    provider: 'ollama',
    fetchImpl: async () => { throw new TypeError('private endpoint detail'); },
  });
  await assert.rejects(
    offline.analyze({ resumeText: 'Synthetic resume.' }),
    { code: 'OLLAMA_UNAVAILABLE' },
  );

  const missingModel = createResumeAnalyzer({
    provider: 'ollama',
    fetchImpl: async () => ({ ok: false, status: 404 }),
  });
  await assert.rejects(
    missingModel.analyze({ resumeText: 'Synthetic resume.' }),
    { code: 'OLLAMA_MODEL_NOT_FOUND' },
  );

  const invalidResponse = createResumeAnalyzer({
    provider: 'ollama',
    fetchImpl: async () => ({
      ok: true,
      async json() { return { message: { content: 'not valid json' } }; },
    }),
  });
  await assert.rejects(
    invalidResponse.analyze({ resumeText: 'Synthetic resume.' }),
    { code: 'INVALID_PROVIDER_RESPONSE' },
  );
});

test('unknown AI_PROVIDER values fail clearly during provider creation', () => {
  assert.throws(() => createResumeAnalyzer({ provider: 'unknown' }), /Unsupported AI_PROVIDER/);
  assert.throws(() => createResumeAnalyzer({ provider: 'ollama', contextLength: 0 }), /OLLAMA_NUM_CTX/);
  assert.throws(() => createResumeAnalyzer({ provider: 'ollama', timeoutMs: 0 }), /OLLAMA_TIMEOUT_MS/);
});
