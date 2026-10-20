import { z } from 'zod';

export const HealthResponseSchema = z.object({
  status: z.literal('ok'),
});

export const AnalysisRequestSchema = z.object({
  resumeText: z.string().trim().min(1).max(100_000),
  targetRole: z.string().trim().max(200).optional(),
}).strict();

export const ApiErrorSchema = z.object({
  error: z.object({
    code: z.string(),
    message: z.string(),
    fields: z.record(z.string(), z.array(z.string())).optional(),
  }),
});
