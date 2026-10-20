/**
 * Future server-side provider boundary. Implementations should accept validated
 * resume text and a target role, then return a structured result. Do not log the
 * input or expose provider credentials to clients. No provider is implemented.
 *
 * @typedef {{ overall: string, suggestions: Array<{ category: string, evidence: string, recommendation: string }> }} AnalysisResult
 * @typedef {{ analyze(input: { resumeText: string, targetRole?: string }, options?: { signal?: AbortSignal }): Promise<AnalysisResult> }} ResumeAnalyzer
 */
