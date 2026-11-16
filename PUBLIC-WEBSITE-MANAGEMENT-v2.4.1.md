# Brightlife v2.4.1 — Website Management

## Included
- Public favicon declaration: `<link rel="icon" type="image/png" href="/favicon.png">`.
- Sticky public header with a higher stacking order and scroll offset.
- Admin Portal → Operations → Website Management.
- Full content manager with 16 sections: Projects introduction, Home hero, Home about, Home featured update, and 12 project/programme areas. Each section supports title, description, image URL, and publish/draft status.
- The editor uses the existing authenticated `getSiteContentAdmin` and `saveSiteContent` backend functions.
- The backend accepts only authenticated `admin` and `super_admin` roles for website content operations.
- Published content continues to be read publicly through `getPublishedSiteContent`; drafts are excluded.

## Database requirement
The backend already uses a Supabase table named `site_content`. If it does not yet exist in the Supabase project, run `supabase/migrations/202611170001_site_content.sql` in the Supabase SQL Editor. The API uses the configured server-side Supabase service key; do not expose that key in browser code.

## Publishing workflow
1. Sign in to `/login` with an administrator account.
2. Open **Website Management** in the Operations section.
3. Find the relevant content card (Home, Projects introduction, or one of the programme areas).
4. Edit its heading, description and optional public image URL.
5. Leave **Publish this content** checked to make it visible, or uncheck to save a draft.
6. Select **Save & Publish**, then use **View Public Website** to review the changes.

## Validation boundary
Static syntax, route, markup, and ZIP checks can be run locally. Saving and retrieving live content requires the production Supabase environment and a real administrator session; this cannot be certified from a local source-only check.
