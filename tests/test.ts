import { expect, test } from '@playwright/test';

test("index page has heading", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "RememberIt" })).toBeVisible();
});
