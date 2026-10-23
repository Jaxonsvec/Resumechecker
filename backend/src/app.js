import express from 'express';
import multer from 'multer';
import {
  ApiErrorSchema,
  HealthResponseSchema,
} from './schemas.js';
import { extractResumeText, ResumeFileError } from './resume_text.js';
import { AnalysisResultSchema, createResumeAnalyzer } from './providers/resume_analyzer.js';

const MAX_JSON_BYTES = '300kb';
export const MAX_RESUME_BYTES = 10 * 1024 * 1024;
const DEFAULT_ALLOWED_ORIGINS = (process.env.CORS_ALLOWED_ORIGINS ?? '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_RESUME_BYTES, files: 1, fields: 1, fieldSize: 200 },
});

function sendError(res, status, code, message, fields) {
  const payload = ApiErrorSchema.parse({
    error: { code, message, ...(fields ? { fields } : {}) },
  });
  return res.status(status).json(payload);
}

export function createApp({
  analyzer = createResumeAnalyzer(),
  textExtractor = extractResumeText,
  allowedOrigins = DEFAULT_ALLOWED_ORIGINS,
} = {}) {
  const app = express();
  app.disable('x-powered-by');
  app.use((req, res, next) => {
    const origin = req.headers.origin;
    if (typeof origin === 'string' && allowedOrigins.includes(origin)) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Vary', 'Origin');
      if (req.method === 'OPTIONS') {
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'content-type');
        return res.sendStatus(204);
      }
    }
    return next();
  });
  app.use(express.json({ limit: MAX_JSON_BYTES, strict: true }));

  app.get('/health', (_req, res) => {
    return res.status(200).json(HealthResponseSchema.parse({ status: 'ok' }));
  });

  app.post('/api/v1/analyses', upload.single('resume'), async (req, res) => {
    if (!req.file) {
      return sendError(res, 400, 'INVALID_REQUEST', 'Attach a PDF or DOCX file in the resume field.', {
        resume: ['A resume file is required.'],
      });
    }

    const rawTargetRole = req.body?.targetRole;
    if (rawTargetRole !== undefined && typeof rawTargetRole !== 'string') {
      return sendError(res, 400, 'INVALID_REQUEST', 'The request did not match the analysis request format.', {
        targetRole: ['Must be a single text value.'],
      });
    }
    const targetRole = rawTargetRole?.trim() ?? '';
    if (targetRole.length > 200) {
      return sendError(res, 400, 'INVALID_REQUEST', 'The request did not match the analysis request format.', {
        targetRole: ['Must be 200 characters or fewer.'],
      });
    }

    const extension = req.file.originalname.toLowerCase().split('.').pop();
    if (!['pdf', 'docx'].includes(extension)) {
      return sendError(res, 415, 'UNSUPPORTED_FILE_TYPE', 'Upload a PDF or DOCX resume.');
    }

    try {
      const resumeText = await textExtractor(req.file);
      if (!resumeText.trim() || resumeText.length > 100_000) {
        return sendError(res, 422, 'INVALID_RESUME_TEXT', 'The resume must contain readable text and be 100,000 characters or fewer.');
      }
      const analysis = AnalysisResultSchema.parse(await analyzer.analyze({
        resumeText,
        ...(targetRole ? { targetRole } : {}),
      }, { signal: AbortSignal.timeout(analyzer.timeoutMs ?? 35_000) }));
      return res.status(200).json({ analysis });
    } catch (error) {
      if (error instanceof ResumeFileError) {
        return sendError(res, error.status, error.code, error.message);
      }
      if (error?.code === 'PROVIDER_NOT_CONFIGURED') {
        return sendError(res, 503, 'ANALYSIS_UNAVAILABLE', 'Set OPENAI_API_KEY in backend/.env or the server environment, then restart the backend.');
      }
      if (error?.code === 'OLLAMA_UNAVAILABLE') {
        return sendError(res, 503, 'OLLAMA_UNAVAILABLE', 'The local Ollama service is unavailable. Start Ollama and check OLLAMA_BASE_URL.');
      }
      if (error?.code === 'OLLAMA_MODEL_NOT_FOUND') {
        return sendError(res, 503, 'OLLAMA_MODEL_NOT_FOUND', 'The configured Ollama model is not installed. Pull OLLAMA_MODEL and retry.');
      }
      if (error?.name === 'TimeoutError' || error?.name === 'AbortError') {
        return sendError(res, 504, 'ANALYSIS_TIMEOUT', 'Resume analysis took too long. Please try again.');
      }
      if (error?.code === 'INVALID_PROVIDER_RESPONSE' || error instanceof Error && error.name === 'ZodError') {
        return sendError(res, 502, 'INVALID_ANALYSIS_RESPONSE', 'The analysis service returned an invalid result.');
      }
      if (error?.status === 429) {
        return sendError(res, 503, 'ANALYSIS_BUSY', 'The analysis service is busy. Please try again shortly.');
      }
      return sendError(res, 502, 'ANALYSIS_FAILED', 'Resume analysis could not be completed. Please try again.');
    }
  });

  app.use((req, res) =>
    sendError(res, 404, 'NOT_FOUND', `No route for ${req.method} ${req.path}.`),
  );

  app.use((error, _req, res, _next) => {
    if (error?.type === 'entity.too.large') {
      return sendError(res, 413, 'REQUEST_TOO_LARGE', 'The JSON request exceeds 300 KB.');
    }
    if (error instanceof multer.MulterError && error.code === 'LIMIT_FILE_SIZE') {
      return sendError(res, 413, 'FILE_TOO_LARGE', 'Resume files must be 10 MiB or smaller.');
    }
    if (error instanceof multer.MulterError) {
      return sendError(res, 400, 'INVALID_UPLOAD', 'Upload one resume file and an optional targetRole field.');
    }
    if (error instanceof SyntaxError && 'body' in error) {
      return sendError(res, 400, 'INVALID_JSON', 'The request body must be valid JSON.');
    }
    return sendError(res, 500, 'INTERNAL_ERROR', 'An unexpected server error occurred.');
  });

  return app;
}
