import express from 'express';
import {
  AnalysisRequestSchema,
  ApiErrorSchema,
  HealthResponseSchema,
} from './schemas.js';

const MAX_JSON_BYTES = '300kb';

function sendError(res, status, code, message, fields) {
  const payload = ApiErrorSchema.parse({
    error: { code, message, ...(fields ? { fields } : {}) },
  });
  return res.status(status).json(payload);
}

export function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json({ limit: MAX_JSON_BYTES, strict: true }));

  app.get('/health', (_req, res) => {
    return res.status(200).json(HealthResponseSchema.parse({ status: 'ok' }));
  });

  app.post('/api/v1/analyses', (req, res) => {
    const parsed = AnalysisRequestSchema.safeParse(req.body);
    if (!parsed.success) {
      const fields = {};
      for (const issue of parsed.error.issues) {
        const field = String(issue.path[0] ?? 'body');
        (fields[field] ??= []).push(issue.message);
      }
      return sendError(
        res,
        400,
        'INVALID_REQUEST',
        'The request did not match the analysis request format.',
        fields,
      );
    }

    // Deliberately do not log or retain the submitted resume text. The provider
    // integration and document lifecycle are not implemented in this foundation.
    return sendError(
      res,
      501,
      'ANALYSIS_NOT_IMPLEMENTED',
      'Resume analysis is not available yet.',
    );
  });

  app.use((req, res) =>
    sendError(res, 404, 'NOT_FOUND', `No route for ${req.method} ${req.path}.`),
  );

  app.use((error, _req, res, _next) => {
    if (error?.type === 'entity.too.large') {
      return sendError(res, 413, 'REQUEST_TOO_LARGE', 'The JSON request exceeds 300 KB.');
    }
    if (error instanceof SyntaxError && 'body' in error) {
      return sendError(res, 400, 'INVALID_JSON', 'The request body must be valid JSON.');
    }
    return sendError(res, 500, 'INTERNAL_ERROR', 'An unexpected server error occurred.');
  });

  return app;
}
