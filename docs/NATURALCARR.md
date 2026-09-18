# Natural Carr

Verified: 2026-09-15

## Purpose

`naturalcarr.com` is my professional portfolio. It presents the same experience for several hiring audiences:

- Infrastructure and DevOps.
- IT operations and management.
- IT service desk and systems operations.
- General systems administration.
- Individual job listings.

Every route shares one visual system and one live statistics feed. The copy, skill emphasis, and resume download change for the target role.

## Deployment

### Protected admin sign-out (2026-09-17)

https://admin.naturalcarr.com/ serves /config/www/natural-admin/index.html, not the public portfolio root. A styled keyboard-focusable Sign Out link is published in its header at /outpost.goauthentik.io/sign_out through the existing Authentik server include. No restart/proxy/policy change needed. Live HTML SHA-25652be682bc40f3ee1bd2534f01f9afb188c12156ab29a955133ac712ea4cd6e8f; exact original backup /mnt/cache_addons/addonfiles/dockers/appdata/swag/admin-ui-backups/natural-admin-index.before-signout-20260918T0255Z.html (original hashde79c982bd74865613b575738ab78fd0bb7967f2cb875f7bc51c0540b4bda72b). Structural/link/hash checks pass; signed-out admin/logout path302 observed. The operator reports browser checks complete; authenticated session clearing was not independently tested. Don't claim global SSO logout from a route probe alone.

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

It downloads `/sysadmin/natural-carr-nhl-it-service-desk-manager-resume.pdf`. The matching JSON remains published as the editable resume source.

### Systems

`/systems/` preserves the broader IT and systems presentation. It has technology-first skill groups for development, systems and virtualization, networking and security, and automation and operations.

## Tailored profile pages

Tailored pages live at `/js/<capability-profile>/`. Each page has candidate-focused metadata, a tailored opening, tailored skills and experience emphasis, and a matching Reactive Resume JSON.

| Identifier | Target |
|---|---|
| `cloud-ops` | Cloud operations and reliability |
| `infra-ops` | Infrastructure operations and observability |
| `service-ops` | Service management and technical communication |
| `endpoint-id` | IT systems, endpoint, and identity |
| `systems-support` | Senior IT support and systems |
| `azure-infra` | Azure and infrastructure operations |
| `endpoint-auto` | TechOps and endpoint engineering |
| `network-infra` | Network and infrastructure engineering |
| `linux-systems` | Linux systems and operational troubleshooting |
| `ops-process` | IT operations, asset records, and process automation |

The matching JSON files are listed in [Routes and access](ROUTES-AND-ACCESS.md).

The network-infra and linux-systems versions use Kalshi gray. The ops-process version uses NHL dark. The ops-process page is positioned around verified transferable operations experience and does not claim unverified ServiceNow, CMDB, Discovery, or service-mapping experience.

Public portfolio copy must describe Natural Carr. The eyebrow line and browser title must use verified capabilities, outcomes, or professional positioning. Never put the target employer, exact job title, requisition number, or other application-tracking metadata in those fields.

Public route names and published filenames must also be capability-based. Do not use employer names, exact job titles, requisition numbers, or application IDs anywhere in a public NaturalCarr.com URL. The Website profile label in Reactive Resume must match the destination route. Internal canonical JSON filenames may retain application identifiers when needed for source tracking.

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

For approved job-specific resumes, `Q:\resumes\json\job specific` is the canonical library. The `json\generated` directory is a working area; copy an approved generated file into `job specific` before publishing it.

The current 2026 job-specific resume standard uses:

- The Ditgar template.
- A 33% sidebar.
- Summary, experience, and projects in the main column.
- Profiles, skills, and education in the sidebar.
- US Letter, Inter, visible icons, and a one-page target.
- Only the Kalshi gray (`#4B5563`) or NHL dark (`#111827`) primary color. Use gray for technical and infrastructure resumes. Use dark for IT management, service desk, and service-management resumes.
- Profile labels that fit inside the sidebar. When a route is too long, shorten both the public route and its displayed label instead of showing a different label for the same destination. Routes and labels must describe a capability profile, not a target employer or specific job.
- Inspect the live Reactive Resume profile order before editing it. Locate the Website entry by its profile type or stable ID, not by a fixed array index; preserve the LinkedIn and GitHub entries and verify the exported PDF.

Keep retired employer- or job-specific routes as compatibility redirects to the current capability-based route.

On 2026-09-15 the Branch, Kalshi, Plaid, CUNY, and Datadog job pages and resume sources were refreshed with newly verified scope and operational outcomes. The master CV is the source of truth for those facts.

## Known deployment gaps

- The root and DevOps pages duplicate content but have no canonical link metadata.
- The root copy contains “I'm an Systems & Infrastructure Specialist.” It should be “I'm a Systems & Infrastructure Specialist.”
- Some targeted headings contain a space before terminal punctuation in the rendered source.
- A missing route can silently show the root page because of the nginx fallback. Test both status and title.
- The raw uptime-history file is under a public web root.

## Static deployment

Back up and copy only the changed files. HTML, CSS, JavaScript, JSON, and resume updates under this root do not need a container rebuild. Hard-refresh after deployment.

## Resume download contract

Every public portfolio route must have a role-matched PDF resume stored with that page. The primary resume button and the footer resume button must download that PDF, not the editable JSON source.

The JSON remains the canonical editable resume source. After it is approved:

1. Import or update the matching resume in Reactive Resume.
2. Export and visually verify a one-page PDF.
3. Store the PDF in the page's own directory with a stable role-specific filename.
4. Point every visible resume download on that page to the local PDF.
5. Verify the public URL returns `Content-Type: application/pdf` and begins with the `%PDF` file signature. A `200` response by itself is insufficient because the nginx fallback can return the portfolio HTML for a missing file.
