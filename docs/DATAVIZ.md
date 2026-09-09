# B.Ross Dataviz

Verified: 2026-09-07

## Purpose

Dataviz is a standalone static dashboard for the B.Ross platform. It combines fixed Docker/Tautulli snapshots with the live values available from the B.Ross API.

## Location and route state

- Windows: `R:\dockers\appdata\swag\www\dataviz`
- UNC: `\\TOWER\addonfiles\dockers\appdata\swag\www\dataviz`
- Unraid: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/dataviz`

Files:

- `index.html`
- `dataviz.css`
- `dataviz.js`

No active SWAG host or location serves this root.

- `dataviz.naturalcarr.com` did not resolve during the 2026-09-07 check.
- `naturalcarr.com/dataviz/` serves the main Natural Carr page because of its fallback rule.
- `bross.cloud/dataviz/` serves the main B.Ross page because of its fallback rule.

Open `index.html` locally for now. A public version needs its own nginx route.

## Data sources

### Embedded data

`dataviz.js` ships these fixed values:

- Docker state snapshot from 2026-08-13: 105 total, 57 running, 22 created, and 26 exited.
- Manual container categories based on that snapshot.
- Plex daily plays for 2026-07-16 through 2026-08-14.
- Plex all-time library plays from the 2026-08-14 Tautulli pull.
- Storage and several platform fallback values.

These numbers stay fixed until `dataviz.js` is regenerated or edited.

### Live data

The dashboard requests:

- `GET /api/stats` for the current Plex account count.
- `GET /api/uptime` for long-term uptime and monitor detail.

When opened from `file://` or a blob URL, the API base is:

`https://bross.cloud/api`

When opened from HTTP or HTTPS, the API base is the same origin:

`/api`

A future dataviz host must proxy `/api` to port 3100 or point the client directly at the B.Ross API.

If a live request fails, the dashboard keeps the embedded fallback.

## Uptime behavior

The main uptime tile uses:

1. `uptimeMean` when present.
2. `uptime` as a fallback.

`uptimeMean` gives each service equal weight. Hovering the uptime tile shows every monitor that has a numeric uptime value. The API returns the monitor list with the lowest value first.

## Visualizations

### Platform overview

The KPI row shows:

- Containers.
- Movies.
- Episodes.
- Total storage.
- Plex users.
- Peak concurrent sessions.
- Uptime.
- Storage under management.
- Years operated.

### Container states

A proportional-width stacked bar shows running, created, and exited containers. A table toggle exposes the exact values.

### Container roles

Horizontal stacked bars show running and stopped counts for:

- Cloud and apps.
- Arr services and indexers.
- Media tooling.
- Media servers.
- Infrastructure and networking.
- Utilities.
- Monitoring.
- VPN downloaders.
- AI and ML.

Categories are manual. State totals come from the Docker snapshot.

### Plex usage

The Plex chart has two SVG series:

- TV in blue.
- Movies in orange.

When the card is revealed:

1. Both lines draw over 1.1 seconds.
2. A bright dot follows each completed line from left to right over 2.8 seconds.
3. The runner has a core, white spark, round halo, and vertical glare.
4. It rests for 1.5 seconds before the next pass.
5. Animation stops when the chart is off screen or the tab is hidden.

Pointer movement adds a crosshair and exact TV, movie, and total values. Horizontal bars below show all-time plays by library.

## Interaction and accessibility

- Tables can be shown for exact values.
- Tooltips adjust to viewport edges.
- Reveal animation uses `IntersectionObserver`.
- A light/dark button overrides the operating-system theme for the current page session.
- Reduced-motion users receive static charts without runner animation.
- SVG has a descriptive ARIA label.

## Maintenance

When refreshing the dashboard:

1. Generate a current Docker state snapshot.
2. Update the snapshot date, totals, and categories together.
3. Pull a new, fixed 30-day Tautulli series.
4. Update the date labels, TV values, movie values, totals, and summary text together.
5. Check that the Y-axis maximum can hold the new peak.
6. Test the page from `file://`.
7. If a public route is added, test same-origin `/api` calls.

## Known issues

- The page calls old embedded values “live” in several labels. Only account count and uptime are fetched at page load.
- The HTML provenance comments and footer contain dates from August 2026 and must be updated with the embedded data.
- No public route serves this root.
- A future public route needs a deliberate CORS or same-origin API design.
