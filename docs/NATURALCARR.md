# Natural Carr

Verified: 2026-09-07

## Purpose

`naturalcarr.com` is my professional portfolio. It presents the same experience for several hiring audiences:

- Infrastructure and DevOps.
- IT operations and management.
- IT service desk and systems operations.
- General systems administration.
- Individual job listings.

Every route shares one visual system and one live statistics feed. The copy, skill emphasis, and resume download change for the target role.

## Deployment

| Layer | Path |
|---|---|
| Windows live root | `R:\dockers\appdata\swag\www\natural` |
| UNC live root | `\\TOWER\addonfiles\dockers\appdata\swag\www\natural` |
| Unraid live root | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural` |
| SWAG container root | `/config/www/natural` |
| nginx host | `naturalcarr.com` |

SWAG uses a directory-first `try_files` rule with a root-page fallback. A missing path can return the main portfolio instead of a 404. Verify the page title when testing a route.

## General pages

| Route | Positioning | Main heading |
|---|---|---|
| `/` | Infrastructure and DevOps | Technical enough to build it. Experienced enough to run it. |
| `/devops/` | Infrastructure and DevOps | Technical enough to build it. Experienced enough to run it. |
| `/it-manager/` | IT operations and management | Technical enough to build it. Experienced enough to run it. |
| `/sysadmin/` | IT service desk and operations | Technical enough to build it. Experienced enough to run it. |
| `/systems/` | General IT and systems | Hi, I'm Natural. I keep systems running and build things meant to last. |

The root page is the main DevOps page. The root and `/devops/` are separate files, not redirects.

## Page structure

Each page uses the same shell:

- Fixed brand and navigation.
- Home panel.
- About panel.
- Skills panel.
- Experience panel.
- Projects panel.
- Contact panel.
- Resume download actions.

`assets/js/main.js` implements:

- Full-viewport panel navigation.
- Hash deep links.
- Keyboard, mouse-wheel, click, and touch navigation.
- Internal panel scrolling.
- Crossfade transitions.
- A pulsing navigation highlight.
- Reduced-motion behavior.
- The Natural Carr brand link back to the root.
- Live statistics loading.
- Per-monitor uptime detail on hover.

`assets/css/main.css` provides the shared visual and responsive system.

## Role-specific content

### Infrastructure and DevOps

The root and `/devops/` focus on:

- Platform and automation.
- Reliability and observability.
- Infrastructure and networking.
- Security and access.
- End-to-end ownership of the B.Ross platform.

### IT manager

`/it-manager/` focuses on:

- IT operations and leadership.
- Infrastructure and systems.
- Networking and security.
- Automation and development.
- Multi-site support, client management, escalation, documentation, and process improvement.

### Sysadmin and service desk

`/sysadmin/` is tailored to an NHL IT Service Desk Manager listing. It focuses on:

- ITIL-aligned service management.
- Tier 1-3 enterprise support.
- Incident, request, and escalation management.
- Jira, Incident IQ, and ConnectWise.
- Azure, Microsoft 365, Active Directory, Google Workspace, Apple School Manager, Jamf, Windows Autopilot, CrowdStrike Falcon, and Cisco Meraki.
- Process development, SOPs, automation, and multi-party escalation.

It downloads `/sysadmin/natural-carr-nhl-it-service-desk-manager-resume.json`.

### Systems

`/systems/` preserves the broader IT and systems presentation. It has technology-first skill groups for development, systems and virtualization, networking and security, and automation and operations.

## Job-specific pages

Job pages live at `/js/<job-identifier>/`. Each page has role-specific metadata, a tailored opening, tailored skills and experience emphasis, and a matching Reactive Resume JSON.

| Identifier | Target |
|---|---|
| `branch-cloud-ops` | Cloud operations and reliability |
| `cuny-infra-ops` | Infrastructure operations and observability |
| `datadog-service-management` | Service management and DevOps advocacy |
| `kalshi-it-admin` | IT systems, endpoint, and identity |
| `my-it-crew-senior-support` | Senior IT support and systems |
| `orveon-infrastructure` | Azure and infrastructure operations |
| `plaid-techops` | TechOps and endpoint engineering |

The matching JSON files are listed in [Routes and access](ROUTES-AND-ACCESS.md).

## Live metrics

The pages load:

`/assets/data/stats.json`

The B.Ross API rewrites that file every five minutes. The browser bypasses cache and replaces each `data-metric` fallback with the current value.

Current fields include:

- `generatedAt`
- `sources`
- `observedSince`
- `uptimeWindowDays`
- `uptimeDaysCovered`
- `uptimeWindowComplete`
- `uptimeChecks`
- `uptimeOk`
- `peakSessions`
- `uptime`
- `uptimePooled`
- `uptimeServices`
- `uptimeMonitors`
- `uptime24h`
- `uptime30d`
- `accounts`
- `sessionsPeak`
- `libraryItems`

The uptime card shows the percentage with the word “Uptime.” Hovering the card shows each tracked service's uptime.

`stats.json.uptime` is the current 24-hour Kuma mean. The accumulated equal-weight result comes from `GET /api/uptime` as `uptimeMean`, but that field is not written to `stats.json`. Align the publisher and browser mapping before showing the accumulated value on the portfolio.

## Uptime data file

`assets/data/uptime-history.json` is a private-operational data file placed in a public static directory so the publisher can retain history. The API returns aggregates, but the raw JSON is also reachable if a visitor knows the URL.

On 2026-09-07 it had:

- Version 1.
- Data since 2026-02-19.
- 135 daily rows.
- 11 monitor records.
- Last update on 2026-09-07.

Do not place secrets, private URLs, or user data in this file.

## Resume source library

The private working library is:

- Windows: `Q:\resumes`
- UNC: `\\TOWER\Files\Documents\resumes`

Key directories:

- `Q:\resumes\json\cv-master.json` - master CV data.
- `Q:\resumes\json\natural-carr-devops-resume.json`
- `Q:\resumes\json\natural-carr-it-manager-resume.json`
- `Q:\resumes\json\natural-carr-sys-admin-resume.json`
- `Q:\resumes\json\job specific` - tailored job resumes.
- `Q:\resumes\reactive` - Reactive Resume working output.
- `Q:\resumes\old resumes` - historical documents; do not use as current facts without review.

Published job JSON files are copies. Update the private source first, copy the approved file to its site directory, then compare hashes.

## Known deployment gaps

- The root, DevOps, IT manager, and systems pages link to `/Carr, Natural B - Resume -Current.pdf`. That file was not present in the live Natural Carr root on 2026-09-07. Those downloads are broken until a current PDF is published or the links are changed.
- The root and DevOps pages duplicate content but have no canonical link metadata.
- The root copy contains “I'm an Systems & Infrastructure Specialist.” It should be “I'm a Systems & Infrastructure Specialist.”
- Some targeted headings contain a space before terminal punctuation in the rendered source.
- A missing route can silently show the root page because of the nginx fallback. Test both status and title.
- The raw uptime-history file is under a public web root.

## Static deployment

Back up and copy only the changed files. HTML, CSS, JavaScript, JSON, and resume updates under this root do not need a container rebuild. Hard-refresh after deployment.
