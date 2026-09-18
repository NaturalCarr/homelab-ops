# B.Ross Identity Rollout

Verified: 2026-09-18 (read-only gateway inspection, source and installed admin files).

## Current status

Owner login-link review and signed-in recovery are enabled. The gateway is healthy, has no host port bindings and retains the dedicated edge/internal database networks. Member lookup remains `legacy_email`; enforcement remains `dry_run`. Production migrations 008/009 were applied and registered at operator-confirmed checkpoints; one externally verified pilot link was confirmed (not a fresh row count).

Use `https://supporter.bross.cloud/` and its `GET/POST /identity-recovery` form. Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links/recovery remain embedded views; renderer/API paths are internal, not standalone operator pages. Supporter admin paths remain denied.

The operator reports the browser checks complete; this isn't independent live CSRF/replay/approval evidence. Earlier signed-out forged-header probes returned protected-entry302, Supporter-admin403 and public-support200. The latest recorded source run passed96 focused checks, zero failures/skips; prior isolated PostgreSQL/HTTP tests passed before the latest raw-field hardening. No fresh full-suite/dependency audit or real mutation test was run for this update.

Fresh running image: `sha256:b67fa20fb2fe7fb23c8813faf266d85685517155aa505990b48de112f89c84e1`. Exact bundled-source correspondence hasn't been checked, so don't claim latest wording/validation is either absent or verified deployed. Installed B.Ross admin shell remains SHA-256 `30ada2856e95a749a7bb5000f3b9cc6f90f81e9e04cfb98944ada442d3051e73`; Natural Carr admin remains `52be682bc40f3ee1bd2534f01f9afb188c12156ab29a955133ac712ea4cd6e8f`.

Next gates: exact bundled-source verification; normalized-email provider-intake review; authorized live recovery submission/decision, CSRF/replay/conflict testing where not specifically evidenced. Keep verified-link activation, OIDC, per-app appearance, IPv6/media and all inherited provider/Plex/enforcement gates separate. Natural Carr Sign Out is published and operator browser checks were reported complete; global logout across every application wasn't independently verified.

## Historical checkpoints

The dated entries below preserve prior source, backup, integration and deployment evidence. Their then-current next-step commands/flags/image hashes are historical, not instructions to rerun or current-state claims. This summary takes precedence. Both complete roadmaps remain retained.

### Member copy and input hardening prepared, not deployed (2026-09-17)

Latest source-only follow-up (2026-09-17 local): simplified member recovery text without exposing UID/automatic attachment/24-hour mechanics. Exact intro: Already supporting B.Ross, but your accounts aren't linked? Manual notice: All requests are manually reviewed. Removed the supporter-ID/login-UID instruction; label Support Method, placeholder Choose a provider unchanged; ID label Subscription, transaction or membership ID (if available). Keep privacy warnings; submitting a request doesn't change support/account access. Backend expiry/rates/CSRF/owner proof checks unchanged. Transaction IDs are accepted as references for MANUAL fallback; automatic candidate lookup is still provider+subscription ID, never transaction/email proof.

Source hardening: raw reference must be string/null/absent, at most160 characters BEFORE trim; reject control bytes0-31/127 anywhere, allow only optional3-160 ASCII letters/numbers/underscore/hyphen after trim. Provider exact string enumPayPal/Stripe/Patreon. Parameterized SQL, scoped trusted UID, independent owner proof/revision/CSRF and safe textContent/HTML escaping remain. New tests reject SQL/HTML/shell/template/control-byte/Unicode/malformed/oversized payloads before DB access; verify literal SQL parameter binding, malicious owner IDs/proof and dynamic plain-text rendering of hostile queue values. 96 focused checks PASS with0 failures/0 skips (30 recovery,14 foundation,14 owner,22 config,6 routes,3 framing,1 HTTP client,6 navigation including live shell simulations). Node syntax/browser-script compilation and changed-file whitespace checks pass. Exact source hashes: src/identity-recovery.js6a78beb2faf2fe63460bd02ef55a8e0f8dc8dae54869eb819154cdc0af6e1aea; src/identity-recovery-pages.jse43d01d17db3ef9607825bcb0b50fe01c87514ba0317ef5670e67e4410b545a8; test/identity-recovery.test.jsa5dbf3dc3ca6b0e455b4e0d5a995e0b9483c973e4610f1b0a2534308b3048e1f. No new DB/schema/SQL mutation, real PostgreSQL rerun or full security audit claimed. Prior real integration PASS describes the deployed v2 code, not this new exact source. V2 manifest/rebuild preflight compares older recovery files and WILL report drift now; don't weaken checks/reuse old deployment script as if current.

Next: user GUI-rebuild/recreate membership ONLY to deploy these three changed source/test files; no new migration or tabbed-shell copy needed (already installed matching shell). Keep legacy_email/dry_run/no host ports and both admin-root tabs. Verify runtime source hashes privately and health after GUI; member wording/form and prior pending owner/nonowner/CSRF/tab/refresh/history/live-queue gates remain. Don't fabricate another verified mapping, revoke pilot or write payments/Plex to test. Provider normalized-email intake risk remains open before verified-link login activation; optional automated hosted proof, OIDC, per-app login branding, IPv6/media and all F/I production-write/provider gates retained. No commits/pushes or reset credits used.

Natural Carr admin Sign Out button is LIVE: https://admin.naturalcarr.com/, static file /mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural-admin/index.html (UNC equivalent verified). Same-origin href /outpost.goauthentik.io/sign_out, styled keyboard-focusable anchor, responsive header; no new JS, auth-policy/proxy change or restart. Existing authentik-server.conf actually routes the outpost path to Authentik with auth_request off; unauthenticated logout-path GET302 and signed-out admin-root302 observed. Exact original backup /mnt/cache_addons/addonfiles/dockers/appdata/swag/admin-ui-backups/natural-admin-index.before-signout-20260918T0255Z.html, old hashde79c982bd74865613b575738ab78fd0bb7967f2cb875f7bc51c0540b4bda72b; installed hash52be682bc40f3ee1bd2534f01f9afb188c12156ab29a955133ac712ea4cd6e8f. Staged-file structural/link/hash validation; structural/link/hash validation passed. Actual authenticated sign-out/Back behavior/browser appearance NOT tested; don't claim global SSO logout or session clearing yet.

### Recovery and tab-only admin deployed; browser gates pending (2026-09-17)

Paired recovery deployment passed (2026-09-17 local): operator preflight verified pinned source/snapshot/candidate and merged Compose, backed up the exact live admin page; GUI gateway rebuild and runtime-code/config checks passed; matching tabbed shell published. Independent inspection: healthy image sha256:ae74669f1537f996961d1c0b0f7cd87f22242194a34db63afd3cf2fb7f71e6db, no host ports, edge/internal-DB networks preserved, review/recovery enabled, member mode legacy_email, enforcement dry_run, WebUI https://admin.bross.cloud/. Installed admin HTML SHA-25630ada2856e95a749a7bb5000f3b9cc6f90f81e9e04cfb98944ada442d3051e73. Signed-out synthetic forged UID/email GETs: admin root, Supporter root/recovery and Request/Stats/New302; Supporter admin403; public support200. These are status-only signed-out checks, not authenticated rendering or proof/decision/CSRF/history checks. Production009 registered and startup SQL installed/operator hash-verified; original recovery queue empty at migration checkpoint, no later fresh count claimed. Current90 focused checks plus real isolated PostgreSQL/HTTP PASS remain evidence; no new full-suite/penetration/provider/Plex write test claimed.

Next: operator browser checks using only admin root tabs: both B.Ross Media/Supporter Management, Review login account links, then Review login-link recovery requests; embedded views retain the root tab shell and refresh/deep-link navigation. Signed-in Supporter root should show Help link my membership to this login and its no-email-required form. Initially open/navigate only; don't submit/revoke/approve another real link as a synthetic test. Verify a non-owner can't access admin and sign-out/Back doesn't restore usable admin. Then separately plan authorized member submission/manual-reference fallback, single-use/CSRF and owner rejection/approval live gates, without sharing private IDs/UIDs/emails/screenshots. Keep legacy_email until provider-email intake review and complete ownership/recovery activation gates pass. Automatic hosted provider/Plex proof, revoked-account recovery/session-reset, native OIDC and per-app appearance remain planned. Preserve all F/I/IPv6/media/provider/enforcement gates and existing Tautulli permissions. No financial credentials requested/stored by this flow.

Retained: fresh restored production archive /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-production-backup-e9ETH2bp/membership.dump SHA-2567bf8570e5f2d0ca22ff5ab1c1f30c6f279d102c0bb673cd688594a36b71deb8f; old compatible image bross-membership:pre-recovery-20260918T020953Z; exact settings and original shell /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-production-backup-e9ETH2bp/recovery-config-PI05zYg9/settings.env.before-recovery and admin.html.before-recovery. Original shell hash5344039398ef24ae474bcedfa3e59b83cc8b8a4a02d1ad801dee886e46a07de5. Non-secret canonical override backup /boot/config/plugins/compose.manager/projects/bross-membership/docker-compose.override.yml.before-tabbed-admin-20260918T0230Z. Normal rollback uses exact old settings/shell plus compatible image with GUI-only recreation; leave009 and ownership data registered/intact, never drop tables or restore archive over newer payments. Root-private artifacts may be SMB-unreadable; don't weaken permissions.

Earlier prepared/not-deployed/settings-not-run/stop-before-rebuild notes below are historical checkpoints. This doesn't activate verified-link member lookup or complete I3 live browser/mutation gates.

### Recovery settings validated; paired deployment pending (2026-09-17)

Operator-confirmed settings checkpoint PASS (2026-09-17 local): effective Compose plus candidate loadConfig validated; exact appdata settings backup /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-production-backup-e9ETH2bp/recovery-config-PI05zYg9/settings.env.before-recovery. Only identity mode=legacy_email, recovery enabled=true and supporter origin=https://supporter.bross.cloud were prepared; secrets.env untouched. These are NEXT-rebuild settings: running gateway and live shell remain unchanged/recovery inactive. Production009 is applied and startup SQL registered; fresh restored archive/hash and rollback image pre-recovery-20260918T020953Z remain retained. Corrected canonical Compose override WebUI label only to https://admin.bross.cloud/; exact non-secret backup /boot/config/plugins/compose.manager/projects/bross-membership/docker-compose.override.yml.before-tabbed-admin-20260918T0230Z, candidate override SHA-256e427b0d341bb486cda22f65420e67864b6ad4c1300d03fd5fa16cdfb2974021b. No GUI rebuild/static publication by agent. Rechecked live shell hash5344039398ef24ae474bcedfa3e59b83cc8b8a4a02d1ad801dee886e46a07de5 and candidate30ada2856e95a749a7bb5000f3b9cc6f90f81e9e04cfb98944ada442d3051e73. Paired commands prepared/Bash syntax checked NOT RUN: preflight hashed snapshot/source/candidate/live drift, quiet merged Compose and exact private admin shell backup; operator GUI-build/recreate membership ONLY (no postgres); immediately post-check healthy/private recovery-enabled legacy_email/dry_run runtime and built code hashes, then atomically publish exact candidate preserving live mode/owner. No nginx/proxy/auth-policy change or reload needed. If any step fails stop/report; retain old shell/settings/rollback image; don't call deployment complete or activate verified_links. After both steps: owner/nonowner/signedout/CSRF/tab/deep-view/history/member recovery-form/live-queue tests, avoid submitting/approving another real link without external proof. Preserve full F/I/provider-email intake/IPv6/media/provider/enforcement gates. Admin root two tabs only; embedded render/API routes aren't standalone user entry points. Normal rollback leaves additive schema/data in place; never drop tables/restore over newer payments.

Earlier settings-not-run or stop-before-preflight notes are historical. Operator may rebuild only after the paired preflight passes; deployment/browser results are not yet claimed.

### Production recovery schema applied; settings checkpoint prepared (2026-09-17)

Operator-confirmed production009 PASS (2026-09-17 local; UTC tag20260918): nine migrations registered,009 present and recovery queue empty; exact tested startup SQL installed/hash-verified. Rollback image retained: bross-membership:pre-recovery-20260918T020953Z. Fresh restored backup: /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-production-backup-e9ETH2bp/membership.dump, SHA-2567bf8570e5f2d0ca22ff5ab1c1f30c6f279d102c0bb673cd688594a36b71deb8f. Production additive schema only; running gateway, existing account links, payments, Plex, Compose, login settings and live tabbed shell unchanged. Startup SQL is root-private/not readable over SMB; don't weaken permissions merely to independently inspect it. Live inspection confirms healthy unpublished gateway, same image, review enabled, recovery inactive, legacy_email and dry_run. Live shell hash5344039398ef24ae474bcedfa3e59b83cc8b8a4a02d1ad801dee886e46a07de5; staged candidate hash30ada2856e95a749a7bb5000f3b9cc6f90f81e9e04cfb98944ada442d3051e73. Next settings-only command is prepared/Bash syntax-checked NOT RUN: back up exact appdata settings.env privately, change only three identity options, validate merged Compose using current image with read-only candidate source and network none; pass config privately over stdin, print no secrets, restore settings on failure. secrets.env untouched; later-file override must validate the intended effective settings. No rebuild yet. Then GUI-only coordinated gateway/candidate-shell deployment, browser owner/nonowner/CSRF/tabs/history/portal checks. Keep admin root two tabs only and all F/I gates, provider-email intake review and separate verified-login activation. Rollback disables controls/uses compatible image while retaining additive schema/data; never drop ownership tables or restore over newer payments.

Earlier production009-not-applied or next-backup/test notes are historical. Source recovery/tab-only features remain undeployed.

### Fresh recovery backup verified; production009 prepared, not run (2026-09-17)

Operator-confirmed fresh-backup checkpoint PASS (2026-09-17): /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-production-backup-e9ETH2bp/membership.dump, SHA-256 7bf8570e5f2d0ca22ff5ab1c1f30c6f279d102c0bb673cd688594a36b71deb8f. Archive restored with eight baseline migrations;009 created/registered only in the isolated database, nine versions/empty recovery queue verified. Temporary DB removed; production unchanged. Previous recovery-tests-v2 real PostgreSQL/HTTP PASS remains valid. Next guarded production009 command is prepared/syntax-checked, NOT RUN: retain current app image; guard exact backup/SQL hashes, healthy unpublished legacy-email/recovery-disabled runtime and eight-version baseline; create009/register in one transaction; verify9:1:0; no-clobber/hash-verify tested009 into startup migrations. No real links, settings, running image, shell, Compose, payment/Plex/enforcement changes. After operator result: private opt-in configuration/quiet Compose checks, GUI-only paired gateway/tabbed-shell publication and browser owner/nonowner/CSRF/tab/history checks. Keep admin root two tabs only, legacy_email and all F/I/provider-intake/verified-login gates. Normal rollback retains additive tables and disables controls; never drop ownership records or restore over newer payments.

Earlier fresh-backup-next or isolated-test-not-run notes below are historical. The admin candidate remains staged, not published.

### Recovery integration checkpoint passed (operator-confirmed 2026-09-17)

Operator-confirmed 2026-09-17: recovery-tests-v2 PostgreSQL/HTTP integration PASS. Both temporary containers were removed; original private backup retained; production unchanged. This covers real replay/concurrency, conflicting ownership, expiry/revision guards, audit rollback, member/owner HTTP controls and tab-only top-level redirects/iframe views. The live gateway remains healthy/private on the same image, recovery disabled and member mode legacy_email. Candidate admin shell and recovery source are NOT deployed; production009 is NOT applied. Next is a fresh private production backup and isolated restore/additive009 registration check; the new inline command is syntax-checked but NOT RUN. Then production009 registration/autoload installation, private opt-in configuration/quiet Compose validation, GUI-only paired gateway/shell deployment and live owner/nonowner/CSRF/tab/history checks. Preserve all F/I roadmap gates, provider-email intake review and separate verified-login activation. Never drop ownership tables or restore over newer payments.

Earlier prepared/not-run isolated-test statements below are historical. The 90 focused source checks remain passing; no full-suite, production009 or GUI/browser deployment result is claimed.

### Admin navigation contract: one tabbed site (prepared 2026-09-17)

Owner administration has one browser entry point: https://admin.bross.cloud/, with B.Ross Media and Supporter Management tabs. Login-link review and recovery are views within Supporter Management, not separate admin pages or hostnames. Operator instructions must start at the tabs. Legacy top-level HTML navigation will redirect to the corresponding root tab anchor; internal iframe render routes and APIs remain functional implementation details.

Source now uses root tab anchors exclusively and adds a navigation guard that serves known admin HTML only to iframe requests. API requests are unaffected; existing owner/CSRF/authentication guards remain. The staged shell removes the separate-window link, selects the correct tab from an allowlisted hash, preserves media controls, pauses previews and avoids reloading an unchanged iframe.

90 focused checks pass, including six tab-navigation/shell simulations. New isolated HTTP tests exercise compatibility redirects and embedded owner views, but have NOT RUN. Candidate shell is /mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-recovery-20260918/tabbed-admin/admin.html, SHA-256 30ada2856e95a749a7bb5000f3b9cc6f90f81e9e04cfb98944ada442d3051e73. Live shell still has SHA-256 5344039398ef24ae474bcedfa3e59b83cc8b8a4a02d1ad801dee886e46a07de5; no live publication/rebuild occurred. Install the guarded gateway and candidate shell together after isolated validation and the recovery migration/config/GUI gates. Back up the exact live shell and recheck drift/hash before copying it. Don't delete internal routes or publish only half this change.

### Signed-in login recovery: source-only, disabled (2026-09-17 local; stage names use UTC)

The operator confirmed the first externally verified test login link saved successfully. The supplied owner-page screenshot shows a verified provider-account proof. Earlier zero-link notes describe the schema-install checkpoint, not current ownership state. The preceding count report showed two member records, one currently supported member, no pending manual requests, one Patreon account with an email and one PayPal account without an email. Don't publish record identifiers or assume either email proves ownership. Authentik contains two active accounts sharing the test sign-in email; the pilot was identified by exact username rather than choosing the first email match.

New source provides a separate signed-in recovery form and owner queue. Trusted SWAG UID plus configured authority bind each request; client-supplied UID/member ID/actor are ignored. No membership is exposed to the submitter. Provider plus subscription reference finds a candidate for the owner, never by email. The reference may be omitted for manual review; absence of a provider email is supported. Unknown/missing references require explicit separate verification of the existing supporter record. External ownership proof is still mandatory; no automatic provider OAuth/email challenge was added.

Opt-in defaults off: `AUTHENTIK_IDENTITY_RECOVERY_ENABLED=false`. Enabling requires existing owner review configuration/secret plus `AUTHENTIK_IDENTITY_SUPPORTER_ORIGIN` (the canonical HTTPS supporter origin), distinct from the admin origin. New routes are GET/POST `/identity-recovery` on the supporter host, the Supporter Management recovery view, GET `/admin/api/identity-recovery`, and POST `/admin/api/identity-recovery/:requestId/decision` on the owner host. Disabled routes return 404 without database access. Portal links and the owner-queue link appear only when enabled.

Member actions require exact supporter host, authenticated UID, exact Origin/JSON/fetch-site checks and a 15-minute identity/authority/origin-bound HMAC form token. Only its hash is stored, uniquely, making replay unable to overwrite a request. Per-identity transactions serialize submissions and cap them at five per hour/three unexpired pending requests. Requests expire after 24 hours. Owner actions reuse independent owner UID/host/Origin/CSRF checks, require explicit proof/confirmation and revision checks, and recheck the provider candidate under lock. Link insertion, request consumption and minimal audits share one transaction. Expired/conflicting/revoked links fail closed. Rejection changes no mapping. No payment/Plex or enforcement mutation is added.

90 focused source tests pass (24 recovery plus 60 existing identity/configuration/routes/framing/client tests and six tab-navigation checks), with source/browser-script/shell syntax and whitespace checks passing. New opt-in real PostgreSQL/HTTP tests are prepared but NOT RUN; their no-database invocation safely skips. Mock rollback tests aren't real-database evidence. No full suite, GUI build/deploy or production recovery migration result is claimed.

Staged SQL `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase3-recovery-20260918/009_identity_recovery_requests.sql` has SHA-256 `9ae3f20e6fb7fb1f44fff7e4e02d38d5a1660b0fc2dbd55637b8dd1a54fb399e`. It is deliberately OUTSIDE automatic startup migrations. Exact pre-source copies are in that directory. Twelve-file secret-free test snapshot: `recovery-tests-v2`; manifest SHA-256 `6b77540527c30d4f0a716cebdb76ec05fea7efd37078dbb1328e47c552e25acc`. The isolated command restores the retained root-private pre-008 backup, applies 008/009 only to a network-none disposable DB, then runs existing identity and new recovery HTTP/transaction tests sequentially. Logs stay root-private alongside that archive; only captured temporary container IDs are removed.

Main tabbed admin HTML/routing are unchanged and still contain B.Ross Media and Supporter Management; admin HTML hash remains `5344039398ef24ae474bcedfa3e59b83cc8b8a4a02d1ad801dee886e46a07de5`. All operator navigation is through the tabbed root. Tab-only navigation and compatibility redirects are staged, not yet deployed.

Next gate: real isolated tests and result review. Then a fresh private production backup, explicit additive009 installation/registration and rollback plan, private opt-in configuration, quiet Compose validation, GUI-only build, and signed-in/non-owner/CSRF/history/live-queue checks. Keep member mode `legacy_email`; do NOT rebuild or enable recovery/verified login yet. Normal rollback preserves additive ownership data and disables recovery; never drop identity tables or restore over newer payments. Provider intake's pre-existing normalized-email association remains unchanged and must be addressed before complete verified-login activation. Native OIDC, per-app presentation, IPv6/exhaustive media and inherited membership feature gates remain open.

### Owner review deployed; ownership/recovery checkpoint next (2026-09-17)

Live inspection confirms the rebuilt gateway is running, review controls are enabled, a valid owner proxy UID is configured, authority is `https://auth.bross.cloud`, admin origin is `https://admin.bross.cloud`, and no backend host ports are published. `AUTHENTIK_IDENTITY_MODE` is absent from the running environment; source defaults it to `legacy_email`. The operator reports a successful GUI rebuild and owner/non-owner, portal and sign-out browser checks. Those browser results weren't independently repeated in this checkpoint. Earlier source-only and stop-before-rebuild statements below are historical.

Next: read-only aggregate ownership/recovery readiness checks, then authenticated identity-bound recovery requests and provider ownership review. Don't enable `verified_links` yet. Existing provider intake still attaches previously unknown provider accounts to members by normalized email. The current manual recovery form records a subscription reference, Plex username and contact email, but doesn't bind the request to the signed-in Authentik proxy UID. Its approval links Plex, not Authentik. Neither matching emails nor a submitted subscription reference proves ownership of both accounts.

The readiness report must show counts only: schema versions, verified/revoked login links, members without a verified link, currently supported members without a verified link, pending manual requests, missing provider-held email and provider-email groups associated with multiple internal members. Scope login coverage to the configured authority. These counts aren't proof and must never create or merge links. Keep member login, payment intake, Plex access and enforcement unchanged. Manual recovery must remain available even when a payment provider supplies no email; verify ownership through an authenticated provider/Plex account or separate owner review. Don't request card/bank details, passwords, access tokens or unredacted receipts.

### Production schema checkpoint applied (operator-confirmed 2026-09-17)

The operator ran the guarded checkpoint successfully: fresh private backup restored and schema fixtures passed in isolation; migration 008 created/registered in one production transaction; eight migrations and zero identity links verified; temporary database removed. The tested SQL is now in build-context `migrations/008_authentik_identity_links.sql`, independently hash-verified as `df4bd30f98ff21620b9020637d6be3043a6e2b8723686bad56da0ffa0936a924`. Startup will skip its registered version. Earlier staged-only/schema-not-applied statements below are historical. No login/account/payment/Plex settings, Compose/proxy files or running app changed.

Fresh root-private backup: `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase2b-production-backup-O3p66HV7/membership.dump`, SHA-256 `2e67921438a1bd4ffa332f40e6907061a8c2f4b1f56bfc8dfd4f30280e85cbd0`. Retained compatible rollback image: `bross-membership:pre-identity-20260917T172555Z`. Private diagnostics stay beside the archive; don't publish raw logs or database records.

Stop before any rebuild. Owner UID/authority configuration and GUI deployment/browser checks come next, with member login still `legacy_email`. Normal rollback disables/leaves controls off and retains the unused additive table/registration; the old app image is compatible. Never automatically drop links or restore an older database over newer payment events. If migration execution fails after starting, check schema state before retrying because a commit may have occurred. Keep private diagnostic logs beside the fresh archive.

### Owner identity review controls: source-only, inactive (2026-09-17)

The build context now has an owner-only screen to review existing identity links, approve an externally verified Authentik-to-supporter link, or revoke one. This is direct owner review, not a new self-service enrollment/proof queue. No email enrollment or automatic matching is added. Existing Plex/payment manual-review controls are unchanged.

`AUTHENTIK_IDENTITY_REVIEW_ENABLED` defaults to false; disabled handlers return 404 without querying the new table. Opt-in requires `AUTHENTIK_IDENTITY_OWNER_UID` (verified 64-hex proxy UID, not UUID/OIDC subject), `AUTHENTIK_IDENTITY_AUTHORITY`, `AUTHENTIK_IDENTITY_ADMIN_ORIGIN` and an existing `SELF_SERVICE_SECRET` of at least 32 characters. No real values were read or changed. The screen is linked from Supporter Management only when enabled. Verified-link login remains independently inactive.

Every new action checks the configured owner UID and exact admin host. Mutations also require the configured Origin, JSON, an expiring owner/authority/origin-bound token, explicit confirmation and externally verified ownership. Body-supplied actor/authority fields are ignored. Conflicts/stale revisions fail closed; database errors are sanitized. List output is owner-only and bounded to 200 links. Revocation doesn't block legacy email login; don't represent it as a legacy-session revocation control.

60 focused tests pass (14 identity, 22 configuration, six self-service routes, three framing, 14 owner review, one HTTP-client fidelity). Rendered browser code compiles, source syntax and whitespace checks pass. The operator confirmed the complete corrected isolated integration pass: real PostgreSQL concurrent idempotence, conflicting claims, audit rollback and revision-guarded revocation, plus real owner HTTP denial/approval/revocation. Both temporary containers were removed, original private backup retained, production unchanged. No full-suite/build/browser or production deployment result is claimed.

The passing six-file read-only snapshot is `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase2b-20260917/owner-review-tests-v2`; manifest SHA-256 `6134e8d8e449d22281cccf9d19e1699c5b07cc37219a5fcecf46e5dc020655a3`. Private diagnostics remain beside the backup. Next: fresh production backup and explicit additive migration/rollback plan, verify the configured authority and owner proxy UID without publishing values, then GUI-only deployment and owner/non-owner/browser checks for review controls. Keep member login in `legacy_email`; user proof/recovery, existing-provider email association review and separate verified-login activation remain later gates. No production schema, links or flags changed.

### Phase 2B foundation: source-only, inactive (2026-09-17)

The build context now has a verified Authentik proxy-UID lookup scoped to a configured HTTPS authority. It maps to existing internal member IDs without email fallback. Link creation/revocation helpers require explicit ownership proof, reject conflicts, reserve revoked identities, and write minimal audit metadata atomically. They are not exposed through new routes or owner UI yet. `AUTHENTIK_IDENTITY_MODE` defaults to `legacy_email`; `verified_links` requires `AUTHENTIK_IDENTITY_AUTHORITY`. Production has not been rebuilt or switched.

44 focused tests pass: 14 identity, 21 configuration, six self-service route and three admin framing tests. Syntax and whitespace checks pass. The operator also confirmed the isolated PostgreSQL restore/migration/constraint test below. Full-suite, real concurrent application transactions and production integration remain unverified.

Migration `008_authentik_identity_links.sql` is staged outside startup's automatic `migrations/` directory at `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase2b-20260917`. SHA-256: `df4bd30f98ff21620b9020637d6be3043a6e2b8723686bad56da0ffa0936a924`. Synthetic `identity-schema-fixtures.sql` in the same directory has SHA-256 `cbb832eab4d66e97ee8ed0e99283386c67f0a6b3955b3192acab428576e111c1`; it refuses any database except `bross_identity_check` and rolls back fixture rows. Exact pre-change source/test copies are retained there. No production database migration or identity links were created.

Isolated database checkpoint passed (operator-confirmed 2026-09-17): the fresh root-private backup restored with seven baseline migrations, 008 applied only to the temporary database, identity constraint fixtures passed, synthetic rows rolled back, and the temporary container was removed. Retained backup: `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase2b-db-backup-MqZ0jo9P/membership.dump`, SHA-256 `c803a802b6191be42db4ef6137a7b9bac10bb2801615d19e57be733e1fa0b8f3`. Private retry diagnostics stay beside the archive; don't publish or read database records for documentation.

Next checkpoint: implement owner-only review/enrollment controls, then test permitted and denied actions, external proof, CSRF, conflicts, auditing and real concurrency before production installation or mode switch. Obtain another fresh backup before production migration. Deployment remains through Compose Manager GUI only. Do not move 008 into automatic migrations early or enable `verified_links` yet.

Separate finding: payment intake's `resolveUser()` still associates a new provider account with an existing normalized email. This is unchanged, and the new portal lookup does not fix it. Review that behavior with Phase 3 ownership proof before activating the complete identity workflow. No automatic Authentik email linking is added; no member merges, provider/Plex writes, financial credential fields or enforcement changes are part of this checkpoint.

The admin exit gate remains complete. Older pending-admin and not-implemented statements below describe earlier checkpoints and are superseded by this section.

Admin exit gate passed (operator-confirmed: 2026-09-17): both owner tabs work, a non-owner cannot access the gateway dashboard or overview API, and sign-out/Back doesn't restore usable administration. Together with the real framing/nginx/forged-header checks and retained Supporter403, this completes the tabbed admin hardening checkpoint. This supersedes pending admin-browser checks below. Next is identity Phase 2 design/implementation: verified stable Authentik identity mapped to existing internal membership user IDs, no automatic email merges, uniqueness/conflict/cross-user tests and a fresh backup before any production migration. No identity migration or enforcement activation is authorized merely by this test result.

Owner UI checkpoint (2026-09-17): the operator confirmed both B.Ross Media and Supporter Management tabs work after deployment. The owner-tab functional check passes. A real non-owner denial check on `/admin/` and `/admin/api/overview`, plus sign-out/Back behavior, remain unverified. Keep identity activation gated on those checks; don't infer them from working tabs.

Deployment checkpoint (2026-09-17): the GUI-rebuilt gateway is healthy with no host bindings and unchanged edge/database networks. The operator's inline install passed: rebuilt admin same-origin/public anti-framing headers, unchanged owner-only binding, real nginx validation/reload, and route smokes. Live default/admin HTML hashes match the tab candidates. Signed-out forged-identity probes returned 302 on the admin root, dashboard, overview API and mixed-case API; Supporter admin stayed 403, member root 302, public support 200. Exact two-file backup: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/admin-tabs-qnghD8G0`. Owner/non-owner browser tests, both-tab behavior and sign-out/history checks remain pending; don't activate identity changes until they pass.

Latest admin checkpoint (2026-09-17): containment is deployed and verified. Real SWAG validation/reload passed. Supporter `/admin`, `/admin/`, `/admin/api/overview`, `/Admin/`, `/ADMIN/api/overview`, and `/%61dmin/` all returned HTTP 403. Exact backup: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/admin-containment-kFpMSS7y`. Don't restore that file automatically; it reopens the member-facing dashboard.

The existing admin Authentik application uses `forward_single`, engine `any`, and exactly one enabled, non-negated direct-user binding, with no group/policy binding and failure result false. Tabs reuse this rule without changing Authentik. Owner-browser and non-owner denial checks on the new gateway proxy remain pending.

The tab interface and admin-host `/admin` private proxy are deployed from `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/admin-tabs-20260917`. Gateway build-context `src/routes.js` opts only admin HTML into CSP same-origin framing and X-Frame-Options SAMEORIGIN; public/member pages retain anti-framing defaults. Three embedding and six current route tests pass. Static admin JavaScript syntax, unique IDs, tab switching, lazy frame loading, preview pause, history guard, and owner-host proxy boundary simulations pass. Real nginx and signed-out route checks now pass; integrated browser behavior isn't verified yet. No payment/enforcement configuration changed and no migration was added.

### Admin security gate: historical finding and remaining rollout gate (2026-09-17)

Before containment, the operator confirmed `ADMIN_AUTH_ENABLED` false and unauthenticated private gateway `/admin` HTTP 200; Supporter's catch-all exposed the dashboard to member-portal users. Supporter's admin-path denial is now applied. Keep host-port closure and the owner-only admin edge rule intact because application Basic authentication remains disabled. No misuse audit has been performed.

The deployed layout has B.Ross Media and Supporter Management tabs at `https://admin.bross.cloud/`, with the gateway's `/admin` namespace proxied only within that existing owner-only host. Keep administration in the existing tabs; no new Authentik application is needed. Member self-service stays at `https://supporter.bross.cloud/`; its case-insensitive admin paths are denied. The live denial file matches SHA-256 `05ebc59c71ee7c02f3be197aaafe4204820fd23283c980c00430803e25eaf115`. Do not continue identity activation until an owner is permitted and a non-owner is denied at the dashboard, and sign-out/history behavior is verified.

Phase 2A's private backup and isolated restore passed; migrations 001-007 and zero ambiguous email groups were verified. Enforcement remains `dry_run`. Host swap has no active devices. Admin readiness failed and supersedes the earlier next-gate status below.

Phase 1A is deployed and verified. Phase 1B checkpoints 1 through 3 are deployed: saved SWAG networks, all seven private Docker-DNS proxy locations, unpublished gateway port, and an internal database network. After GUI recreation, both membership containers report healthy and have no host port bindings; the PostgreSQL volume is unchanged. The operator confirmed working support/portal pages and denied LAN access to `http://192.168.1.253:3110/admin`. The portal is `https://supporter.bross.cloud/` (no `/manage`). The 2026-09-17 user-run checks confirm private health, fresh signed-out/forged-header redirects on Supporter/Request/Stats/New, and outbound provider HTTPS connectivity. Separate IPv6-client denial and exhaustive signed-in media authorization remain unverified. Phase 2A review, private backup, and isolated restore passed; owner-only admin readiness is the next gate. No identity migration or app change is implemented. Phases 3 through 5 remain planned.
Membership records, payment-provider settings, and Tautulli settings are unchanged. Request/Stats Authentik entries were added using New's existing login flows and `require-plex-friends` policy binding. Existing admin restrictions weren't changed. Their LAN proxy repair is applied and operator-confirmed working.

Phase 1A production checks passed: real SWAG syntax validation/reload, support HTTP 200, and signed-out forged-header redirect HTTP 302. Signed-in portal access and correct membership display were confirmed by the operator. Its identity guards remain in place; the default proxy file now also contains the applied Request/Stats LAN repair. Don't reapply the old Phase 1A package over this newer file. Phase 1A local rollback/drift simulations also passed.

Phase 1A backup: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/phase1a-20260916T230432Z-E8kFiv`.

Phase 1B local preparation checks passed: shell syntax/package hashes, prepare/repeat behavior, unchanged proxy/Compose fixtures, database exclusion, rollback of new attachments after failed health checks, preservation of existing attachments, and rejection of unexpected networks/members, failed candidate-Compose checks, and source drift. Real preparation then passed on Tower with both containers already attached. Its repeated ssl_stapling warnings didn't prevent nginx validation. Compose validation stayed quiet; no expanded credentials were printed.

## Roadmap

These identity phases are separate from the older membership feature phases below. Don't equate Phase 2 stable Authentik links with the original Phase 2 Plex observation work.

| Phase | Change | Completion gate |
|---|---|---|
| 1A | Set verified identity headers at the protected gateway location; strip identity from public payment routes | Real SWAG nginx test and reload; signed-out forged-header denial; signed-in portal check |
| 1B | Dedicated SWAG/gateway edge network; unpublished app port; separate private database network | Effective Compose validation; GUI recreation; all gateway routes work; LAN port denied; network persistence verified |
| 2 | Link stable Authentik identity to the existing internal membership user ID | Production 008 applied; owner review deployed/enabled, member login remains legacy email. Focused/isolated tests pass; browser gates operator-reported complete. Ownership/recovery and provider-email review precede separately gated verified-login activation |
| 3 | Signed-in membership recovery/manual owner fallback deployed; automated provider/Plex proof remains planned | Production009 applied; source/isolated tests passed. Preserve external proof, exact-image verification, authorized live decisions/replay/conflict gates and provider-email intake review |
| 4 | Native Authentik OpenID Connect login for the gateway | Issuer/subject and token validation; callback/session/CSRF checks; existing links survive the transition |
| 5 | Individual login-page presentation for Request, Stats, New, and Supporter | Same identity authority; correct app permissions; Tautulli's current per-user history stays unchanged |

Complete and verify each phase before activating the next. Don't change payment-provider intake or membership ownership while the proxy trust boundary is still open.

### Inherited membership feature roadmap

Inherited feature claims below retain their historical evidence. Production008/009 were operator-confirmed applied/registered; fresh runtime inspection confirms dry_run. Other feature completion requires its own dated live validation.

| Feature phase | Scope and status | Remaining gate / dependencies |
|---|---|---|
| Core gateway | Previously deployed: PayPal/Patreon intake, normalized subscriptions, idempotence, reconciliation, API/admin/health | Fresh provider/audit verification before intake changes; hosted payments and minimal records only |
| Plex observation | Previously deployed: references, verified/candidate/rejected links, GET-only service observations, recommendations/overrides | Preserve separation of observation and writes; no account merges from email alone |
| Enforcement 3A/3B | Dry-run proposals previously deployed; manual approval implemented | Legitimate manual Plex2 invite/restore remains unverified; don't manufacture production state |
| Enforcement 3C | Scheduler/circuit breaker/cooldown implemented; historical deployment was dry-run | Reverify current mode without exposing secrets; user authorization plus live-write gate before manual/auto activation; disable always manual |
| Notifications 3D | SMTP and Discord supported independently; historical deployment | Test only configured channels with permission; keep identity/secrets out of operational messages |
| Self-service 4A/4B | Legacy magic-link/Plex sign-ins and manual mismatch review implemented; current Authentik root portal works | Migration 007 application, live review queue and approve/reject weren't retested; admin must verify ownership, not trust a submitted reference |
| Production activation 5 | Partial; this rollout closes the gateway host-port bypass | Combined app security/dependency review, tested backup/restore, owner-only gateway dashboard path, legitimate write gate still required |
| Wizarr invitations 6 | Implemented; user historically confirmed rebuilt QR flow works | Preserve server/library restrictions, download prohibition, bounded retries/grace, guarded write decisions; no fresh production invite sent |
| Stripe/Cash App 7 | Stripe migration/provider/Checkout/admin monitoring and hosted Cash App support present; support UI has PayPal/Stripe/Patreon choices | Fresh authorized hosted Checkout + signed webhook/admin observation required; no live transaction generated here |
| Venmo | Deferred | Separate provider-supported hosted flow/product decision; don't add a credential-handling workaround |
| Future reporting/provider expansion | Unscoped | Separate user request, official hosted/tokenized flows, same privacy and safety gates |

Scope references: [membership gateway](BROSS-MEMBERSHIP.md), [Authentik](AUTHENTIK.md), [SWAG edge](SWAG-EDGE.md), [routes](ROUTES-AND-ACCESS.md), [operations](OPERATIONS.md), [platform](PLATFORM-OVERVIEW.md), and [security findings](SECURITY-FINDINGS.md). Phase continuation starts with remaining checks below; historical completion isn't a fresh application audit.

## Verified starting point

- Active source/build context: `R:\\github\\bross-supporter-gateway`, Unraid `/mnt/cache_addons/addonfiles/github/bross-supporter-gateway`.
- Canonical Compose project: `/boot/config/plugins/compose.manager/projects/bross-membership`.
- Running containers: `bross-membership` and `bross-membership-db`.
- Neither membership container has host port bindings (IPv4 or IPv6).
- The gateway runs on `bross-membership-edge` and `bross_membership_database`. PostgreSQL runs only on `bross_membership_database`, defined as internal in active Compose.
- SWAG is managed by a Docker template, not a Compose project. Its recreated container and saved template both retain `medianet` and `bross-membership-edge`. Medianet has gateway priority 1; edge has priority -1. The saved Extra Parameters explicitly list both networks.
- Gateway public routes and the protected supporter portal proxy to `bross-membership:3110` through scoped Docker DNS on the dedicated edge network. Direct LAN port 3110 is intentionally unavailable.
- The Authentik-protected gateway hostname in the inspected configuration is `supporter.bross.cloud`. Membership self-service stays at that hostname root.
- Phase 1A now explicitly forwards verified Authentik headers at the protected proxy location and clears identity headers on the six public gateway locations. The previous server-level header inheritance gap is closed.
- `authentikSession()` looks up the membership user by Authentik email. The received UID currently contributes to CSRF generation, not membership lookup.
- Existing administrator-reviewed Plex links include conflict checks and audit entries.
- Tautulli users already see only their own history (operator-confirmed; unchanged by this rollout).

## Phase 1A package

Private, secret-free staging directory:

`/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase1a-20260916`

Only these live nginx files change:

- `site-confs/default.conf`: six public gateway locations include the public header guard.
- `site-confs/supporter.bross.cloud.conf`: the proxied location explicitly sets verified identity.
- `membership-public-identity-headers.conf`: clears the gateway's supported Authentik identity headers and unused JWT/metadata headers.
- `membership-verified-identity-headers.conf`: forwards the verified subrequest variables at location scope and clears unused JWT/metadata headers.

Historical Phase 1A package: it kept the then-current LAN upstream and didn't remove port 3110. Its original proxy files are superseded by Phase 1B; don't rerun the old installer over current proxy files.

### Apply on Tower

Paste into the Unraid terminal:

```bash
bash /boot/homelab-ops/scripts/deploy-membership-header-guard.sh apply
```

The script checks staged hashes and the expected live-file hashes. It stops on configuration drift. It validates the existing configuration, creates an exact-file backup, installs the four files, validates in real SWAG, reloads, and runs public-support and signed-out forged-header checks. A failure during installation or the smoke checks restores and reloads the previous configuration.

Backups stay under:

`/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups`

After it succeeds, verify the signed-in supporter portal and support buttons in your browser. Don't paste tokens, cookies, private membership records, or webhook payloads into a report. Record only the outcome and HTTP status.

Phase 1A alone wasn't a complete spoofing defense. Phase 1B subsequently removed the host-port bypass; keep the current dedicated edge/database boundaries intact.

## Phase 1B deployment constraints

### Checkpoint 1: prepare and persist the edge network

Staged package: `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase1b-20260916`.

Paste into Tower's terminal:

```bash
bash /boot/homelab-ops/scripts/prepare-membership-edge.sh prepare
```

The script checks source hashes, validates the candidate effective Compose configuration without printing expanded secrets, and validates current SWAG. It creates a labeled NAT-mode bridge network named `bross-membership-edge` and attaches only SWAG and the currently running gateway. Both retain their current default gateways during preparation. PostgreSQL isn't attached. It tests Docker DNS/private gateway health from SWAG and checks the existing public support and signed-out portal paths. It doesn't edit or reload proxy routes, edit Compose/templates, remove host ports, or recreate containers. On a post-attachment failure it disconnects only the attachments added by that run.

Then edit SWAG in Unraid's Docker tab. Enable Advanced View. Keep its primary Network Type as `Custom: medianet`. Change Extra Parameters to:

```text
--cap-add=NET_ADMIN --network=name=medianet,gw-priority=1 --network=name=bross-membership-edge,gw-priority=-1
```

Apply the SWAG template (briefly interrupts the proxy while SWAG is recreated). This persists the extra network on future updates. Keep every other field unchanged. Confirm support and the signed-in portal still work, then report the result before the proxy switch.

Docker 29.5.2 supports repeated network options and negative gateway priorities. Unraid's command builder suppresses the primary Network Type option when Extra Parameters contains a network flag. List both networks explicitly here; don't rely on the primary selector to add medianet. Verify live attachments after applying. Medianet's higher priority keeps it as SWAG's default gateway.

### Verified network-persistence checkpoint

At checkpoint 1, live and saved inspection confirmed both SWAG networks (medianet `172.20.0.10`, edge `172.28.0.2`). The gateway temporarily retained its original default network and edge connection. PostgreSQL remained off edge; port 3110 remained published at that checkpoint. Those transitional gateway/default-port details are superseded by checkpoint 3 below; don't treat historical addresses as routing constants.

If medianet is missing during a future template change, restore the running connection with:

```bash
docker network connect --gw-priority 1 medianet swag
```

Then apply the corrected two-network Extra Parameters above through Unraid's SWAG edit form. Keep every other field unchanged. Verify both live and saved attachments again.

The preparation command above has now passed after template recreation. Both containers were already attached, so it left those connections alone. Private DNS/health, real nginx syntax, package/source hashes, candidate effective Compose validation, support HTTP 200, and forged-header redirect HTTP 302 passed. Don't apply the SWAG template again just because the preparation output repeats the earlier persistence instructions.

The Phase 1B default proxy preserves all six repaired Ombi/Tautulli LAN upstreams. Its seven membership proxy locations use the scoped Docker-DNS helper. Local preparation/drift/rollback simulations and real preparation passed; the proxy and Compose switches are now applied. The preparation installer's original-file guards describe the pre-switch state, so don't rerun it as a current-state validator.

### Checkpoint 2: switch only membership proxy upstreams (applied)

Applied and verified on 2026-09-16. Backup: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/phase1b-proxy-20260917T002630Z-j7LGdx`. Real nginx validation/reload and all script smoke checks passed. Independent installed-hash, support/denied-route, and container-health checks passed. The operator confirmed correct signed-in membership at the supporter hostname root. The browser gate for checkpoint 3 passed.

Paste into Tower's root terminal:

```bash
bash /boot/homelab-ops/scripts/deploy-membership-private-proxy.sh apply
```

The installer checks package/live identity-guard hashes, unchanged Compose files, running containers, both SWAG networks, edge-network properties/members, private gateway health, and media LAN backends before writing. It stops on source drift or a partial/unexpected installation. It backs up the exact default/supporter proxy files under `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/phase1b-proxy-*`.

Only `site-confs/default.conf`, `site-confs/supporter.bross.cloud.conf`, and the new `membership-docker-upstream.conf` are installed. The helper scopes Docker DNS to membership upstreams and retains each request path/query. Shared resolver/authentication files and Request/Stats routes stay unchanged. Real nginx validation runs before reload. Support and signed-out identity-denial/media checks run afterward. Failure restores/reloads the original proxy files and moves the new helper into the backup's `failed` directory. An exact already-installed configuration is validated/reloaded without recopying files.

Local checks passed: shell syntax, install/repeat with unchanged Compose fixtures, exact rollback after nginx/reload/smoke failures, private-health failure before writes, drift/partial-install refusal, and missing-network refusal. These used mocked Docker/HTTP commands. The production proxy apply and operator's signed-in membership check passed. No checkout sessions or unsigned webhook requests were used as smoke tests.

The installer and signed-in browser gates passed before checkpoint 3. The pre-switch nginx backup uses the LAN port; don't restore it after port closure without coordinating restoration of the published port too.

### Checkpoint 3: active Compose and GUI recreation (applied)

The operator's inline command installed and quietly validated the prepared Compose file. Compose Manager GUI recreation then used existing images (no source rebuild/pull). Inspection confirms healthy app/database; app networks edge plus database, database only database, SWAG medianet plus edge; and empty host port bindings on both membership containers. The database mount remains `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/postgres:/var/lib/postgresql/data`.

Exact Compose/override rollback backup: `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase1b-20260916/compose-backup-20260917T004343Z-dDlAGF`. This is configuration backup only, not a logical database backup or tested restore.

Active SHA-256 hashes:

| File | SHA-256 |
|---|---|
| Compose Manager `docker-compose.yml` | `9D7E85D56078C68FC1E3B2F534DC200BD78A4147AB95DAF0F5F878ED0CAE490F` |
| Unchanged `docker-compose.override.yml` | `9F54915E7F9C6439EA971D44BE9C7DD966CE8D8744197B9B80F5F25079BFF17A` |
| SWAG `site-confs/default.conf` | `1B6475E4216118198A3E999F790ABD64607F8F53EB7AC310DD84877258375F4B` |
| SWAG `site-confs/supporter.bross.cloud.conf` | `975545D4670C03D53E5E9478CDB84BDB23001D0E3123D6CAF2E1FD97CC0C16A9` |
| SWAG `membership-docker-upstream.conf` | `B36CFFC21C7A0EC244463F9A351071D4FD2E9599E0F461DA1B930EF297746315` |

Operator-confirmed afterward: public support and signed-in portal work; the LAN admin port is unreachable. Direct IPv6 client denial, fresh forged-header/media checks, and explicit outbound-provider reachability after recreation weren't separately tested. Carry these into checkpoint 4; no payment transactions or webhook payloads were generated to test networking.

### Remaining validation and continuation gates

1. Signed-in membership after checkpoint 2: operator-confirmed at `https://supporter.bross.cloud/`. Passed.
2. Compose backup/install, quiet validation, GUI recreation, no host bindings, expected network attachments, healthy app/database, unchanged volume, and operator LAN denial: passed.
3. Fresh private health, signed-out/forged-header redirects, and outbound provider HTTPS checks passed on 2026-09-17. IPv6-client denial and exhaustive signed-in media authorization remain unverified. No authenticated provider operation, payment transaction, signature test, or full app suite was tested.
4. Phase 2A: source/schema review, user-run logical backup, and isolated schema/data restore passed. Owner-only gateway admin readiness remains the next check. No automatic email merges or production identity migration.
5. Phase 2B/2C: add verified stable identity links with uniqueness/audit/conflict handling; test allowed and cross-user denied cases; activate only after gates pass and retain recovery for unknown users.

The prepared Compose file is active. No explicit port-3110 URLs were found in the searched Tower user scripts, host scripts, or Docker templates. Unsearched external callers remain unknown. The stale Compose WebUI label points at the separate media admin, not a verified gateway admin entry. Verify an owner-only gateway dashboard path before Phase 2 administration.

Future operator commands should be inline ready-to-paste blocks, not new script files. Copy to `/boot` without `cp -p`; its ownership-preservation attempt failed and the original Compose was restored before the successful retry. Keep Bash `[[ lhs == rhs ]]` comparisons on one line (a newline after `==` caused the first command to stop before file writes).

### Configuration rollback after port closure

Restore the exact Compose/override backup, validate quietly, and recreate through Compose Manager's GUI only. This republishes port 3110 and reopens the former LAN trust gap; require an explicit operator decision. Current private-DNS proxies can remain if the gateway still joins edge, but the old Compose doesn't persist that attachment. Plan the edge attachment and nginx/Compose restoration together. Don't restore a LAN-upstream nginx backup while the host port remains closed. No rollback was performed after successful recreation.

### Rollback before the proxy switch

No live proxy or Compose files have changed at checkpoint 1. If preparation fails, the script rolls back only that run's new attachments and leaves the unused network for review. To undo successful preparation, restore SWAG Extra Parameters to `--cap-add=NET_ADMIN`, keep Network Type `Custom: medianet`, and apply the template. Verify medianet is attached. Then disconnect the gateway:

```bash
docker network disconnect bross-membership-edge bross-membership
```

Don't remove the network while either container still uses it. Proxy/Compose switch rollback is a separate gate and will be recorded with the installation step.

### Constraints

- Give only SWAG and the gateway access to the new edge network. Don't put the gateway on the broad `medianet` network.
- Keep PostgreSQL off the edge network; retain its existing persistent volume.
- The gateway needs an outbound-capable edge network for payment-provider and media-service requests.
- Use Docker DNS for every gateway upstream. The inspected `resolver.conf` points to the LAN DNS server, not Docker's embedded resolver. A variable upstream needs an explicitly scoped Docker resolver.
- Persist SWAG's additional network in its saved template. A one-time `docker network connect` alone won't survive container recreation.
- Keep payment webhooks free of interactive authentication. Signature verification stays in the application.
- Check effective Compose overrides. Never print the expanded configuration with secret environment values.
- Recreate through the Unraid Compose Manager GUI, not a terminal `compose up`.
- Keep a staged, hash-checked rollback configuration. Switch proxies before closing the host port; validate each step.
- Inventory any existing direct API/admin callers before closing port 3110. Provide an authenticated replacement path where needed.

## Identity and privacy rules

### Phase 2A evidence (2026-09-17)

Source review confirms existing internal `users.id`, provider/Plex link uniqueness, and `access_audit_log`. `authentikSession()` still selects by normalized email; no stable Authentik link table exists. Authentik 2026.8.1 identifies the proxy UID as a hash of user ID plus the installation/tenant unique identifier, not the independent User UUID. Namespace verified proxy identities to their authority and reconcile any future OIDC subject explicitly; don't automatically infer equivalence or ownership. Sources: [User model](https://raw.githubusercontent.com/goauthentik/authentik/version/2026.8.1/authentik/core/models.py), [tenant identifier](https://raw.githubusercontent.com/goauthentik/authentik/version/2026.8.1/authentik/tenants/utils.py), and [proxy headers](https://docs.goauthentik.io/add-secure-apps/providers/proxy/).

The operator's read-only checks report migrations 001-007 applied; zero case-insensitive email-collision groups; enforcement mode `dry_run`; private health `ok`; Supporter/Request/Stats/New signed-out forged identity HTTP 302. Unauthenticated outbound HEAD checks returned PayPal 406, Stripe 404, Patreon 200. These demonstrate DNS/TLS/HTTP transport, not authenticated provider success.

Private custom-format database backup reported at `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/phase2-db-backup-20260917T125628Z-zEHLZO/membership.dump`. Supplied SHA-256: `390a52afd41ea0c1cf118e68e9a08c0d5f10021e3f1bb4e7e109c5beeadd9301`. The root-only backup directory is inaccessible through the workstation share; don't weaken permissions to inspect it. Backup contents weren't opened or printed. The operator's isolated restore test passed: schema/data restored, seven migrations and core tables verified. The temporary container was removed and original backup retained. The test used the running database's existing image, no network/host ports, read-only root, and tmpfs data. Docker warned that the kernel couldn't enforce swap limits; host swap status wasn't checked, so don't promise tmpfs data never reached swap. No live database, credentials, app deployment or enforcement mode was changed. This isn't a full application disaster-recovery test. Obtain a fresh backup before a later production migration if the database has changed.

Use one internal gateway account ID. Map verified external identities to it: Authentik identity, Plex ID, and provider-scoped payment customer/subscription IDs. Don't make email the ownership key.

Email matches may suggest a link; they don't automatically merge accounts. Existing records need a verified migration path. A supplied subscription reference or Plex username isn't proof of ownership.

Use provider authentication where supported, or a short-lived single-use link sent to the address already held on the provider record. Bind completion to the initiating authenticated account. Keep administrator review for missing/unverifiable contact details.

Native OpenID Connect uses validated `iss` and `sub`. Don't assume the proxy UID equals the OIDC subject. Reconcile identities through a verified mapping during Phase 4. Unknown identities must fail closed.

For new checkout sessions initiated while signed in, bind a server-controlled opaque internal account reference to the checkout and confirm it through the signed webhook. Handle anonymous/external subscriptions through the verified-link flow.

Don't retain card numbers, bank credentials, or payment passwords. Keep only necessary provider identifiers, contact details, membership state, paid-through dates, verified links, and audit entries. These are still sensitive personal/transaction-related metadata.

## Tautulli boundary

Keep Tautulli's existing individual Plex/guest sessions and per-user restrictions. Authentik controls entry; it doesn't automatically establish a matching Tautulli session. Don't inject shared Basic credentials or a shared administrator session to skip its login. Seamless individual SSO requires a separate supported integration and its own verification gate.

## References

- [Nginx header inheritance](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header)
- [OpenID Connect stable identifiers](https://openid.net/specs/openid-connect-core-1_0.html#ClaimStability)
- [Authentik Tautulli integration](https://integrations.goauthentik.io/media/tautulli/)
- [Docker multi-network syntax and gateway priority](https://docs.docker.com/reference/cli/docker/container/run/#connect-a-container-to-a-network---network)
- [Unraid template network-override behavior](https://github.com/unraid/webgui/blob/master/emhttp/plugins/dynamix.docker.manager/include/Helpers.php)
