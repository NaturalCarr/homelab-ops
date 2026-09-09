# bross.naturalcarr.com

Verified: 2026-09-07

## Purpose

`bross.naturalcarr.com` is my public Home IT and smart-home service page. It is
separate from the career portfolio on `naturalcarr.com`.

## Current offer

| Service | Price | Scope |
|---|---:|---|
| Home Assistant deployment | $50 one time | Core installation, initial device pairing, secure local setup |
| Monitoring and management | $10 per month | Network or Home Assistant health checks and alerts |
| Remote assistance | $20 per month | Remote troubleshooting, configuration help, priority scheduling |
| Remote plus onsite | $50 per month | Remote support, one onsite visit per month, preventive checkup |

Every service button opens a prefilled email to `hello@naturalcarr.com`. The page
has no form processor, scheduler, account system, or payment processor.

## Source

- Windows: `O:\homelab-ops\hire-site`
- UNC: `\\TOWER\flash\homelab-ops\hire-site`
- Unraid: `/boot/homelab-ops/hire-site`

Main files:

- `app/page.tsx` - page copy and service data.
- `app/layout.tsx` - metadata and social-card settings.
- `app/globals.css` - visuals, layout, and responsive rules.
- `public/og.png` - social preview.
- `static-site/index.html` - generated deployment file.

## Stack

- React 19.2.6.
- TypeScript 5.9.3.
- Vinext 1.0 beta and Vite 8.
- Tailwind 4.
- Cloudflare Vite plugin and Wrangler from the original target.
- Drizzle installed but unused by the current static page.

Node.js 22.13 or newer is required.

## Deployment

| View | Path |
|---|---|
| Windows | `R:\dockers\appdata\swag\www\hire` |
| Unraid | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/hire` |
| SWAG container | `/config/www/hire` |

SWAG serves the directory at `bross.naturalcarr.com` with a static fallback to
`index.html`. The deployed `index.html` matched
`hire-site/static-site/index.html` by SHA-256 on 2026-09-07. The deployed folder
also contains `og.png`.

## Page sections

- Navigation for Services, How it works, and Book a call.
- “Home tech, handled.” hero.
- Decorative system-status console.
- Four service and pricing cards.
- Three-step process.
- Contact call to action and footer.

The layout covers desktop, tablet, and mobile. Reduced-motion CSS removes
nonessential animation.

## Build and test

```sh
cd /boot/homelab-ops/hire-site
npm test
```

The test builds the project and checks the rendered HTML. The source README now
contains project-specific setup and deployment notes.

## Static publish

After a successful test:

1. Inspect `static-site/index.html` and `public/og.png`.
2. Back up the live copies.
3. Copy only those two files to SWAG `www/hire`.
4. Compare SHA-256 hashes.
5. Test every mail link at desktop and mobile widths.

Static replacements don't need an SWAG reload.
