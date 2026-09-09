# Historical Documentation

These are older service snapshots. They preserve project history, but they are
not the current source of truth.

Compare every route, credential boundary, deployment path, and project status against the canonical documents one directory above and the live files.

## Imported files

- `bross-api-README-pre-canonical.md` - API README that contains some stale route and mount statements.
- `homelab-ops-README-pre-canonical.md` - prior repository index.

## Conflict order

Use this order when two documents disagree:

1. Current running behavior and read-only route tests.
2. Current live SWAG configuration.
3. Current Compose definition.
4. Current application source and tests.
5. Canonical documents in the parent directory.
6. Historical files in this directory.

Never recover a secret from an old snapshot. Rotate the secret instead.
