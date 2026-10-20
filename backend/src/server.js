import { createServer } from 'node:http';
import { z } from 'zod';
import { createApp } from './app.js';

const ConfigSchema = z.object({
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
});

const config = ConfigSchema.safeParse(process.env);
if (!config.success) {
  console.error('Invalid server configuration: PORT must be an integer from 1 to 65535.');
  process.exitCode = 1;
} else {
  const server = createServer(createApp());
  server.listen(config.data.PORT, '0.0.0.0', () => {
    console.log(`Airesume API listening on port ${config.data.PORT}`);
  });
}
