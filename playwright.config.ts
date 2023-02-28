import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    launchOptions: {
      executablePath: process.env.PLAYWRIGHT_CHROMIUM,
    },
  },
  webServer: {
    command: 'npm run build && npm run preview',
    port: 4173,
  },
  testDir: 'tests'
});
