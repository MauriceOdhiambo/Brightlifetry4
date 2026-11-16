# SND Brightlife CBO — Public Website & Private Member Portal

Version **2.4.0** combines the restored public multi-page website with the existing private member and administrator application. The two experiences are separated at the entry-point level: public visitors see the organization website, while members and administrators use the private portal.

## Public and private routes

| URL | Purpose |
|---|---|
| `/` | Public organization website |
| `/#about`, `/#projects`, `/#water`, `/#governance`, `/#partner`, `/#donate`, `/#contact` | Public website pages |
| `/#project-education` and other `/#project-*` routes | Programme detail pages |
| `/login` | Private member/admin application entry point |
| `/portal.html` | Private application document; `noindex` |

The public website has eight main pages: Home, About Us, Our Projects, Water Project, Governance, Partner With Us, Support Us / Donate, and Contact Us. Programme cards open their dedicated project profiles. The main visitor journey is Home → Projects → Project Detail → Partner / Support → Contact.

The public navigation and pages do not include member sign-in or registration controls. The public HTML does not load the private application bundle. Member registration and password reset remain available inside the private application at `/login`.

## Public website files

- `index.html` — public entry document and SEO metadata.
- `public-pages.js` — public page renderer, navigation, project detail pages and published-content loading.
- `public-reference.css` — original public `.sb-*` page layouts and styling.
- `assets/images/` — client project photographs and Brightlife brand assets.
- `assets/images/generated/` — five generated reference images used by the public project photography mapping.
- `robots.txt` and `sitemap.xml` — public search-engine directives.

Contact and partnership forms prepare an email in the visitor's default email application; they do not save submissions to the database. The Support / Donate page requests official giving instructions by email and does not process payments online. Published project text and photos use the existing `getPublishedSiteContent` API function.

## Private application and stack

The private portal is a Node.js application using Vercel serverless functions, Supabase/PostgreSQL, HTML, CSS and browser JavaScript. It provides member records, savings, lending, repayments, approvals, reporting and system administration. Messaging integrations and scheduled operations remain configured through the existing environment variables and Vercel Cron setup.

The browser application calls the Node.js API at `/api/server`. The standalone Node server provides the same API locally while Vercel continues to run the production serverless functions.

## Run locally

```bash
npm install
node --env-file=.env server.mjs
```

The application is available at `http://localhost:3000`.

## Environment and security

Copy `.env.example` to `.env` and provide the required Supabase, cron authentication and enabled messaging/payment integration values. Never expose server secrets in browser code or commit `.env` files.

## Project structure

```text
/
├── index.html                 # Public website entry
├── public-pages.js            # Public page renderer and navigation
├── public-reference.css       # Public website styles
├── portal.html                # Private application document
├── assets/
│   ├── app.css                 # Private application styles
│   ├── app.js                  # Private application logic
│   └── images/                 # Brand and project photographs
├── api/
│   ├── server.js               # Vercel API
│   └── cron/[job].js           # Scheduled jobs
├── scripts/
│   └── check-public-pages.mjs  # Public route and separation checks
├── server.mjs                  # Local Node server
├── service-worker.js
├── vercel.json                 # /login → /portal.html rewrite
└── package.json
```

## Validation

Run:

```bash
npm run check
```

This runs JavaScript syntax checks and automated checks for the eight main public pages, programme detail routes, shared page layout, and absence of public login/registration UI. It does not replace production testing against the live Vercel deployment and configured database.

## Production deployment

1. Upload the complete contents of this project folder to the existing GitHub repository.
2. Commit and push; Vercel applies the `/login` rewrite from `vercel.json`.
3. Confirm `/` loads the public website and `/login` loads the private application.
4. Test public navigation, project filters and detail pages, email handoff, and separately test private sign-in, registration, password reset, logout and app installation.
5. In Google Search Console, verify `https://brightlifesnd.com/` and submit `https://brightlifesnd.com/sitemap.xml`. Search-engine indexing is not immediate or guaranteed.

## Database migration note

Run `supabase/migrations/20261115_app_first_loan_history.sql` in Supabase SQL Editor against the existing production database before deploying a release that requires this migration. This migration is additive. Do not run the supplied all-in-one fresh-install SQL file against production because it contains destructive `DROP TABLE` statements.

## Excel import notes

Import members first, then loans, repayments, and savings. The importer maps source member codes and loan references; blank repayment/savings amounts are skipped. A workbook import may complete some sections before a later section fails, so inspect the import summary and database before retrying a partially completed workbook.
