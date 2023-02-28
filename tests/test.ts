import { expect, test } from '@playwright/test';

test("add an entry", async ({ page }) => {
  await page.goto("/");
  const input = page.getByLabel("entry");
  await input.fill("abc");
  await input.press("Enter");

  const entry = page.locator("span.entry-content").first();
  expect(await entry.innerText()).toEqual("abc");
});
