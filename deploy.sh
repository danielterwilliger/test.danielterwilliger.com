#!/usr/bin/env bash
# deploy.sh <test|uat> — snapshot that environment's branch and force-push it
# to its GitHub Pages deploy repo (<env>.danielterwilliger.com).
#
# Environments:
#   test branch  -> test.danielterwilliger.com   (noindexed)
#   uat  branch  -> uat.danielterwilliger.com    (noindexed)
#   main branch  -> danielterwilliger.com        (deploys automatically via
#                                                 GitHub Pages on push; this
#                                                 script is not needed for prod)
#
# Promotion flow: PR test -> uat, PR uat -> main. Deploy repos hold snapshots
# only; all history, issues, and PRs live in this repo.
set -euo pipefail
ENV=${1:?usage: deploy.sh test|uat}
[[ "$ENV" == "test" || "$ENV" == "uat" ]] || { echo "usage: deploy.sh test|uat" >&2; exit 1; }

REPO_DIR=$(git rev-parse --show-toplevel)
SHA=$(git --git-dir="$REPO_DIR/.git" rev-parse --short "$ENV")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

git --git-dir="$REPO_DIR/.git" archive "$ENV" | tar -x -C "$TMP"

# Environment overrides: subdomain CNAME, and keep crawlers out of non-prod.
echo "$ENV.danielterwilliger.com" > "$TMP/CNAME"
printf 'User-agent: *\nDisallow: /\n' > "$TMP/robots.txt"

cd "$TMP"
git init -qb main
git add -A
git commit -qm "deploy $ENV @ $SHA"
git push -qf "https://github.com/danielterwilliger/$ENV.danielterwilliger.com.git" main
echo "deployed $ENV @ $SHA -> https://$ENV.danielterwilliger.com"
