# SDLC: how danielterwilliger.com is developed and shipped

Standing rules set by Daniel, 2026-07-28. These are not suggestions; they are the process.

## Standing rules

1. **No tribal knowledge.** Every plan, decision, and piece of configuration is recorded in this repo: as an issue, an issue comment, a PR, or documentation. If it happened and it isn't written down here, it didn't happen properly.
2. **Everything gets an issue.** Work starts as an issue describing what and why.
3. **Everything gets a PR.** No direct pushes of site content. Changes land on `test` via PR, then promote by PR up the ladder.
4. **Stage, review, approve, merge, live.** Content is reviewed on its environment URL before promotion. Only Daniel approves promotion to prod.
5. **Public-safe from day one.** This repo is public. Nothing sensitive goes in files, issues, commit messages, or PR text. Job-search strategy and private context live in the private repo, cross-linked never quoted.
6. **Approved wording only.** Site copy is assembled from Daniel's curated experience record (private repo). Claims are never invented; Daniel signs off line by line before content ships.
7. **Every page declares its visibility.** A PR that adds or changes a page says whether the page is **listed** or **unlisted**. There is no third state, and unlisted is a choice someone makes, not what happens when nobody does.
8. **The agent layer ships with the page.** A PR that adds, removes, or materially changes a listed page updates `profile.md` and `llms.txt` **in the same PR** — never as a follow-up. If a change deliberately does not belong in the machine-readable layer, the PR says why.
9. **Upstream changes arrive as issues, not as sweeps.** The private experience record carries the matching obligation (`job_pii#612`): a session that changes a publicly-stated claim there opens an issue here before it finishes. Those issues are the trigger for revisions; #4 is their standing home. Nobody is expected to notice drift by looking for it.

## Page visibility

`profile.md` and `llms.txt` are the machine-readable mirror of this site — the deliverable behind the public agent/ATS-readable record. They only work if they are complete, so every page has to be in one bucket or the other:

| | Listed | Unlisted |
|---|---|---|
| Linked from site navigation | yes | no |
| In `llms.txt` | yes | no |
| In `profile.md` (if it is a case study) | linked from the matching bullet | no |
| `<meta name="robots">` | absent (indexable) | `noindex,nofollow` |
| Reachable how | by browsing | direct link only |

A page that is unlisted but **not** noindexed is the failure state: invisible to every reader that navigates or parses the site, and visible to any crawler that finds the URL. That is #14.

**Unlisted is not private.** This repo is public, so an unlisted page's source is world-readable by anyone who looks at the repo, and its URL is guessable. Never treat unlisted as a way to publish something that should not be public — if it should not be public, it does not belong in this repo.

## Environments

| Environment | Branch | URL | Serving repo | Indexing |
|---|---|---|---|---|
| Test | `test` | https://test.danielterwilliger.com | `test.danielterwilliger.com` (snapshot) | robots.txt Disallow |
| UAT | `uat` | https://uat.danielterwilliger.com | `uat.danielterwilliger.com` (snapshot) | robots.txt Disallow |
| Prod | `main` | https://danielterwilliger.com | this repo, via GitHub Pages | indexed |

- All history, issues, and PRs live in **this repo only**. The `test.`/`uat.` repos are dumb deploy targets, force-pushed snapshots with two overrides: their own `CNAME` and a deny-all `robots.txt`.
- Naming note: dev/staging/prod is the most common convention; test/uat/prod is the classic enterprise SDLC ladder. Daniel chose test/uat/prod.

## Workflow

```
issue -> branch off test -> PR into test -> bash deploy.sh test -> review on test URL
      -> PR test into uat -> bash deploy.sh uat -> review on uat URL (UAT = Daniel approves)
      -> PR uat into main -> merge = LIVE (GitHub Pages auto-deploys main)
```

- Deploys to test/uat: `bash deploy.sh <env>` (snapshots the branch, applies env overrides, force-pushes).
- Prod needs no deploy step; merging to `main` is the deploy.
- Docs/process changes (like this file) may PR directly to `main`, then `main` is merged back down into `uat` and `test` to keep parity.

## Hosting & DNS (the reproduce-from-scratch runbook)

**Hosting:** GitHub Pages, free tier (requires public repos). Each site: Pages enabled, source = `main` branch root, `cname` set via API:

```
gh api -X POST repos/danielterwilliger/<repo>/pages --input - <<< '{"source":{"branch":"main","path":"/"}}'
gh api -X PUT  repos/danielterwilliger/<repo>/pages --input - <<< '{"cname":"<domain>","source":{"branch":"main","path":"/"}}'
gh api -X PUT  repos/danielterwilliger/<repo>/pages --input - <<< '{"https_enforced":true}'   # after cert issues
```

**Domain:** registered at Squarespace Domains (registration only; no Squarespace hosting). DNS managed at account.squarespace.com → Domains → danielterwilliger.com → DNS → Custom records:

| Type | Name | Data |
|---|---|---|
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |
| CNAME | www | danielterwilliger.github.io |
| CNAME | test | danielterwilliger.github.io |
| CNAME | uat | danielterwilliger.github.io |

Pre-existing records left untouched: Squarespace Domain Connect preset, Google verification CNAME. Removed at launch (2026-07-28): the Squarespace Domain Forwarding rule that 301'd the apex to LinkedIn, and its A record (198.185.159.145).

**Certificates:** GitHub Pages provisions Let's Encrypt automatically once DNS resolves; enforce HTTPS afterward (see command above).

## Local development

Any static server from the repo root, e.g. `python -m http.server 4173`, then http://localhost:4173/. No build step; the site is hand-rolled static HTML/CSS.

## Launch record

- 2026-07-28: repo public, Pages enabled, DNS cut over from the LinkedIn redirect, test/uat environments stood up. Launch tracked in #1, staging in #6, restructure in #5.
- The unlisted Supercast page (#2) is parked privately pending Daniel's voice pass and a visibility ruling; it is intentionally absent from this repo until then.
