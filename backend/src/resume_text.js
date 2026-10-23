import mammoth from 'mammoth';
import { PDFParse } from 'pdf-parse';

const PDF_MAGIC = Buffer.from('%PDF-');
const DOCX_MAGIC = Buffer.from([0x50, 0x4b, 0x03, 0x04]);

export class ResumeFileError extends Error {
  constructor(code, message, status = 422) {
    super(message);
    this.code = code;
    this.status = status;
  }
}

export async function extractResumeText(file) {
  const name = file.originalname.toLowerCase();
  if (name.endsWith('.pdf')) {
    if (!file.buffer.subarray(0, PDF_MAGIC.length).equals(PDF_MAGIC)) {
      throw new ResumeFileError('INVALID_FILE', 'The selected file is not a valid PDF.');
    }

    const parser = new PDFParse({ data: file.buffer });
    try {
      const result = await parser.getText();
      const text = result.text.trim();
      if (!text) {
        throw new ResumeFileError(
          'NO_EXTRACTABLE_TEXT',
          'No text could be extracted. This PDF may be scanned or image-only.',
        );
      }
      return text;
    } catch (error) {
      if (error instanceof ResumeFileError) throw error;
      throw new ResumeFileError(
        'INVALID_FILE',
        'The PDF could not be read. It may be corrupt or password-protected.',
      );
    } finally {
      await parser.destroy();
    }
  }

  if (name.endsWith('.docx')) {
    if (!file.buffer.subarray(0, DOCX_MAGIC.length).equals(DOCX_MAGIC)) {
      throw new ResumeFileError('INVALID_FILE', 'The selected file is not a valid DOCX document.');
    }
    try {
      const result = await mammoth.extractRawText({ buffer: file.buffer });
      const text = result.value.trim();
      if (!text) {
        throw new ResumeFileError('NO_EXTRACTABLE_TEXT', 'No text could be extracted from this document.');
      }
      return text;
    } catch (error) {
      if (error instanceof ResumeFileError) throw error;
      throw new ResumeFileError('INVALID_FILE', 'The selected DOCX document could not be read.');
    }
  }

  throw new ResumeFileError('UNSUPPORTED_FILE_TYPE', 'Upload a PDF or DOCX resume.');
}
