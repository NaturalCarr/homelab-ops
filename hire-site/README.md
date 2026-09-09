# B.Ross Home IT

Source for [`bross.naturalcarr.com`](https://bross.naturalcarr.com), my public
Home IT and smart-home service page.

The site is a React/Vinext project that builds to a static page for SWAG. It has
no database, account system, or form backend. Service buttons open a prefilled
email instead.

## What the page includes

- Home Assistant setup and support plans.
- Network and service monitoring options.
- Remote and onsite support tiers.
- A short three-step service process.
- Responsive desktop, tablet, and mobile layouts.
- Reduced-motion behavior.
- Social preview metadata and `public/og.png`.

## Stack

- Node.js 22.13 or newer.
- React 19 and TypeScript.
- Vinext/Vite.
- Tailwind CSS 4.

Cloudflare and Drizzle packages remain in the project from the original starter,
but the current static landing page doesn't use D1, R2, or database behavior.

## Source map

| Path | Purpose |
|---|---|
| `app/page.tsx` | Page copy, service details, and pricing |
| `app/layout.tsx` | Metadata and social-card settings |
| `app/globals.css` | Layout, visuals, responsive rules, and reduced motion |
| `public/og.png` | Social preview image |
| `static-site/index.html` | Generated static page copied to SWAG |

## Build and test

```sh
npm install
npm test
```

`npm test` builds the project and checks the rendered HTML. For local
development:

```sh
npm run dev
```

## Static publish

The live SWAG directory is:

```text
/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/hire
```

After a successful test:

1. Inspect `static-site/index.html` and `public/og.png`.
2. Back up the deployed copies.
3. Copy only those two files to the live directory.
4. Compare SHA-256 hashes.
5. Test every mail link at desktop and mobile widths.

Static replacements don't need an nginx reload. Full deployment notes are in
[`docs/BROSS-NATURALCARR.md`](../docs/BROSS-NATURALCARR.md).
