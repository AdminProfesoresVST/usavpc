import { test, expect } from '@playwright/test';

test.describe('Service Selection & Payment Flow', () => {

    test('Unauthenticated user selecting DIY plan should be redirected to Login', async ({ page }) => {
        // 1. Go to Services page (English)
        await page.goto('/en/services');

        // 2. Click "Get Strategy Report" (DIY - Option A)
        // We look for the link that contains ?plan=diy
        const diyButton = page.locator('a[href*="plan=diy"]');
        await expect(diyButton).toBeVisible();
        await diyButton.click();

        // 3. Should be redirected to Login with next param preserving the plan
        await expect(page).toHaveURL(/.*\/login\?next=.*plan%3Ddiy/);
    });

    test('Unauthenticated user selecting Full Service should be redirected to Login', async ({ page }) => {
        // 1. Go to Services page
        await page.goto('/en/services');

        // 2. Click "Start Full Service" (Option B)
        const fullButton = page.locator('a[href*="plan=full"]');
        await expect(fullButton).toBeVisible();
        await fullButton.click();

        // 3. Should be redirected to Login
        await expect(page).toHaveURL(/.*\/login/);
    });

    test('Create Account link should preserve next param', async ({ page }) => {
        // 1. Start at services
        await page.goto('/en/services');

        // 2. Click DIY
        const diyButton = page.getByRole('button', { name: 'Get Strategy Report' });
        await diyButton.click();

        // 3. Verify Login URL has next param
        await expect(page).toHaveURL(/.*\/login\?next=.*plan%3Ddiy/);

        // 4. Click Create Account
        const createAccountLink = page.getByRole('link', { name: 'Create Account' });
        await createAccountLink.click();

        // 5. Verify Register URL has next param
        await expect(page).toHaveURL(/.*\/register\?next=.*plan%3Ddiy/);
    });

    // Note: Testing the "Authenticated but Unpaid" flow requires mocking Supabase Auth state
    // or using a test user. For now, we verify the "Gate" works (redirects to login).

    test('Direct access to Assessment without auth should redirect to Login', async ({ page }) => {
        await page.goto('/en/assessment');
        await expect(page).toHaveURL(/.*\/login/);
    });

    test('Direct access to Assessment with plan param without auth should redirect to Login', async ({ page }) => {
        await page.goto('/en/assessment?plan=diy');
        await expect(page).toHaveURL(/.*\/login/);
    });

});
