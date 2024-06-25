import { test, expect } from '@playwright/test';
import { v4 as uuidv4 } from 'uuid';

test('has title', async ({ page }) => {
  await page.goto("/");

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/RememberIt/);
});

test('adding entry', async ({ page }) => {
  await page.goto("/");
  const content = `test ${uuidv4()}`;
  await page.getByLabel("Entry").fill(content);
  await page.getByRole("button", { name: "Add entry" }).click();

  const entry = page.getByText(content);
  await expect(entry).toBeVisible();
});
