# Brightlife CBO app-first deployment

## 1. Back up the live database

Before changing the production database, create a Supabase backup or export the existing tables. The migration below is additive and does not delete the existing member, loan, savings or repayment records

## 2. Run the supplied additive migration

In Supabase Dashboard → SQL Editor, run:

`supabase/migrations/20261115_app_first_loan_history.sql`

Do not run the entire uploaded SQL text file against production. It contains a fresh-install section with `DROP TABLE` statements that would remove existing application tables and data. The included migration is the safe update path for the existing database.

## 3. Deploy to Vercel

Upload the contents of this project folder to the existing GitHub repository or deploy it to the existing Vercel project. Keep the existing production environment variables unchanged. The Node runtime remains Node.js 20+ and the application uses the existing Supabase service-role connection on the server only.

After deployment, confirm:

- `/` opens the Brightlife sign-in page, not a public homepage.
- Registration is available from the sign-in screen.
- Existing member and administrator logins still work.
- The install prompt is available in supported Chrome/Edge browsers after the site is served over HTTPS.
- The app manifest and `/service-worker.js` return successfully.

## 4. Configure the loan rates

Open Administration → Admin Settings → Organization Controls. The five loan product rates are editable there:

| Product | Default rate | Term |
|---|---:|---:|
| Emergency Loan | 20% | 7 days |
| 1–7 Days Loan | 12% | 7 days |
| 8–14 Days Loan | 16% | 14 days |
| 15–20 Days Loan | 18% | 20 days |
| 21–30 Days Loan | 20% | 30 days |

Rates are stored as fractions in PostgreSQL (for example, `0.20` means 20%). The calculation is flat per loan: `interest = principal × rate`, `total repayable = principal + interest`, and the default daily installment is `total repayable ÷ term days`.

## 5. Import the Excel history

Sign in as Super Admin and open Administration → Data Importation. Choose **Brightlife Excel Workbook**, then select the workbook containing these sheet names:

- `Members`
- `Loans`
- `Repayment` or `Repayments`
- `Saving` or `Savings`

The importer processes the sheets in this order: members, loans, repayments, savings and withdrawals. It retains source member codes (`CDO...`), loan IDs (`L...`), repayment IDs (`RP...`) and savings transaction IDs (`SAV...`) as source references. Blank repayment and savings amounts are skipped. Missing joining dates are left blank rather than invented; members without a joining date start with zero account-age months until their original date is supplied.

The workbook importer supports up to 2,000 rows per sheet section and 8,000 records total. It is additive. If a section reports errors, inspect the row details before retrying; earlier successful rows are already saved, and duplicate source references are protected by unique indexes.

## 6. Financial calculation notes

- Principal and interest balances are available through `brightlife_loan_balances`.
- Repayment splits and running balances are available through `brightlife_repayment_ledger`.
- Savings/withdrawal running balances are available through `brightlife_savings_ledger`.
- If the workbook supplies Principal Paid and Interest Paid per repayment, those source allocations are preserved. New KCB repayments use interest-first allocation.
- Penalty amounts are retained when supplied, but the application does not invent or apply new penalties. A penalty rate, grace-period rule and any cap/compounding rule must be approved before automated penalty charging is enabled.
- Arrears are retained from the workbook. A complete automatic arrears schedule requires confirmation of the daily/weekly installment due-date rule; it is not inferred from the sample columns alone.

## 7. Installing the app

- **Android / Chrome:** open the HTTPS website, then use the browser's Install app prompt or menu → Install app / Add to Home screen.
- **Windows / Edge or Chrome:** use the Install icon in the address bar or browser menu → Apps → Install this site as an app.
- **iPhone / iPad:** open in Safari → Share → Add to Home Screen.

The app shell can be cached for offline opening, but authentication, member data, payments and other server operations require an internet connection.
