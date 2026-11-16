# Brightlife public website and private app routes (v2.4.1)

## Public/private URL structure
- `/` serves the public, donor- and partner-facing multi-page website.
- `/login` serves the existing private member and administrator application (including registration and password reset).
- `/portal.html` is the private application document and is marked `noindex`; use `/login` as the user-facing URL.
- The installed web app starts at `/login`.

The public website contains no member sign-in or registration controls, forms, or links. Member-only Savings & Loan information has also been removed from the public sitemap. The private application remains available through `/login` and is not loaded by the public homepage.

## Public pages and visitor journey
The original public page layouts and content are restored:
1. Home
2. About Us
3. Our Projects
4. Water Project
5. Governance
6. Partner With Us
7. Support Us / Donate
8. Contact Us

The programme cards also open dedicated project-detail pages. The 12 supported route keys cover Education Support, Health & Wellbeing, Economic Empowerment, Community Development (including the legacy alias), Poultry, Bike Repair & Vocational Skills, Entrepreneurship & Small Business, Youth Empowerment, Financial Literacy, Other Community Projects, and Training & Capacity Building. The main visitor journey is Home → Projects → Project Detail → Partner / Support → Contact.

Project filters, breadcrumbs, page navigation, published project content, and mobile navigation are handled by `public-pages.js`. Public programme photographs, including the five generated reference images, are stored under `assets/images/` and `assets/images/generated/`.

## Public form behaviour
The Contact Us and Partner With Us forms prepare an email in the visitor's default mail application. They do not save enquiries to a database or send them through a server-side mail service. The Support / Donate page asks visitors to contact the organization for official giving instructions; it does not process payments online.

## Deployment
1. Upload the complete contents of this project folder to the existing GitHub repository.
2. Commit and push; Vercel applies the `/login` rewrite from `vercel.json`.
3. Confirm `/` loads the public multi-page website and `/login` loads the private application.
4. Test public navigation, project filters and detail pages, contact/partner email handoff, and separately test sign-in, registration, password reset, logout and app installation from `/login`.
5. In Google Search Console, verify `https://brightlifesnd.com/` and submit `https://brightlifesnd.com/sitemap.xml`. Indexing is controlled by search engines and is not immediate or guaranteed.
