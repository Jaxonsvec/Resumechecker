import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { createServer } from 'node:http';
import { createApp } from '../src/app.js';

let server;
let baseUrl;

before(async () => {
  server = createServer(createApp());
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) =>
    server.close((error) => (error ? reject(error) : resolve())),
  );
});

test('health returns the validated service status', async () => {
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('analysis route clearly reports the unimplemented feature', async () => {
  const response = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ resumeText: 'Resume text', targetRole: 'Engineer' }),
  });
  assert.equal(response.status, 501);
  assert.deepEqual(await response.json(), {
    error: {
      code: 'ANALYSIS_NOT_IMPLEMENTED',
      message: 'Resume analysis is not available yet.',
    },
  });
});

test('analysis request schema rejects empty and unexpected fields', async () => {
  const response = await fetch(`${baseUrl}/api/v1/analyses`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ resumeText: '  ', apiKey: 'must-not-be-accepted' }),
  });
  assert.equal(response.status, 400);
  const body = await response.json();
  assert.equal(body.error.code, 'INVALID_REQUEST');
  assert.ok(body.error.fields.resumeText);
  assert.ok(body.error.fields.body);
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
