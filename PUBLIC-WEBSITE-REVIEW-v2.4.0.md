# Public Website Comparison & QA — v2.4.0

## Reference used
Compared against the newly supplied `Brightlife1-main` source archive. The original public page renderer and its `.sb-*` layout styles were used as the reference. The private member/admin application was retained from the current split project.

## What was restored
- All 8 main public page templates: Home, About Us, Our Projects, Water Project, Governance, Partner With Us, Support Us / Donate, and Contact Us.
- Original page-level header, navigation, breadcrumbs, footer, page banners, section layouts, project grids, governance sections, partner/support panels and contact layout.
- Individual project-detail layouts for all original programme profiles, plus matching fallback profiles for additional published programme cards.
- Public project publishing integration through the existing `getPublishedSiteContent` API function.
- Generated reference photographs under `assets/images/generated/` and the original project photographs under `assets/images/`.
- The original public `.sb-*` style selectors. A selector comparison confirmed that the public stylesheet includes all `.sb-*` selectors present in the reference stylesheet.

## Public/private separation
- Removed Member Login and Register buttons from the public navigation.
- Removed the member-only Savings & Loan Information page and its public footer link.
- Public `index.html` loads `public-pages.js`, not the private `assets/app.js` bundle.
- `/login` continues to route to the private `portal.html`; registration and password reset remain inside that private application.
- Existing `noindex` protection for the private portal and public sitemap/robots setup were retained.

## Workflow corrections
- Project-card Learn More actions now open the matching public project-detail layout instead of falling through to a missing page.
- Additional published project cards also route into the public project-detail page workflow.
- Public navigation supports direct hash routes and browser back/forward navigation.
- The current page title is updated when visitors navigate between public pages.

## Automated checks completed
- `npm run check` passes, including syntax checks for server, API, private app assets, service worker and public renderer.
- A route-render test verifies all 8 main pages and 12 project-detail routes render with the shared header/footer and without login/registration UI.
- Static HTTP checks returned 200 for `/`, `/public-pages.js`, `/public-reference.css`, generated reference images, `/login`, `/portal.html`, `/robots.txt` and `/sitemap.xml` on the local Node server.
- `getPublishedSiteContent` is present in the API and included in the API's public-function allowlist.

## Important behaviour retained from the reference
- Contact and partner forms hand off to the visitor's default email application using `mailto:`; they do not persist submissions in the database.
- The Support / Donate page requests official giving instructions by email; it is not an online payment gateway.
- Live project text/photos depend on the existing published-site-content API and configured production data source.

## Deployment verification boundary
Local syntax, route-render and HTTP checks passed. A live Vercel deployment, production database response, external email application and real-device visual review have not been verified from this environment.
