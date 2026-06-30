#!/usr/bin/env bash
#
# Builds the blog with Hugo and publishes the generated site.
#
# Usage: ./hack/build-and-publish.sh "your commit message"
#
# What it does:
#   1. Pulls the latest source so we never push a stale branch.
#   2. Builds the site with Hugo.
#   3. Pulls the website repo, then copies the fresh build into it.
#   4. Commits and pushes both repos (skipping any repo with no changes).

set -euo pipefail

# Branch both repos publish from.
readonly BRANCH="master"

# Resolve paths from the script's own location so it works from any cwd.
SRC_REPO="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
readonly SRC_REPO
# The published site lives in a sibling repo; override with WEB_REPO if needed.
readonly WEB_REPO="${WEB_REPO:-$(dirname "${SRC_REPO}")/surajssd.github.io}"

function err() {
    echo "❌ Error: $*" >&2
}

function log() {
    echo "$*"
}

# Report which line failed instead of dying silently under `set -e`.
trap 'err "failed at line ${LINENO}"' ERR

# pull <repo>: fast-forward the repo to origin/${BRANCH}. --ff-only refuses to
# create a merge commit, so it fails loudly if local and remote have diverged
# (which is exactly when you want to stop and look) rather than silently merging.
function pull() {
    git -C "$1" pull --ff-only origin "${BRANCH}"
}

# commit <repo> <message>: stage everything and commit + push, but only if the
# tree actually changed. A no-op run must not abort the script (a plain
# `git commit` exits non-zero on an empty commit and would kill everything).
function commit() {
    local repo="$1" msg="$2"
    git -C "${repo}" add -A
    if git -C "${repo}" diff --cached --quiet; then
        log "⏭️  no changes in ${repo}, skipping commit"
        return 0
    fi
    git -C "${repo}" commit -s -S -m "${msg}"
    git -C "${repo}" push origin "${BRANCH}"
}

# --- preflight checks -------------------------------------------------------

msg="$*"
if [[ -z "${msg}" ]]; then
    err "please provide a commit message"
    echo "ℹ️  usage: $0 \"commit message\"" >&2
    exit 1
fi

if ! command -v hugo >/dev/null 2>&1; then
    err "hugo not found on PATH"
    exit 1
fi

if [[ ! -d "${WEB_REPO}/.git" ]]; then
    err "website repo not found at ${WEB_REPO} (set WEB_REPO to override)"
    exit 1
fi

# --- build and publish ------------------------------------------------------

log "🔄 pulling latest in source repo (${SRC_REPO})"
pull "${SRC_REPO}"

log "🔨 building site with hugo"
(cd "${SRC_REPO}" && hugo)

log "🔄 pulling latest in website repo (${WEB_REPO})"
pull "${WEB_REPO}"

# Copy with `/.` so dotfiles are included too. This intentionally does NOT
# delete removed files: the website repo holds assets Hugo never regenerates
# (CNAME, themes/, keybase.txt, ...), and an rsync --delete would wipe them.
log "📦 copying build into website repo"
cp -r "${SRC_REPO}/public/." "${WEB_REPO}/"

log "💾 committing source repo"
commit "${SRC_REPO}" "${msg}"

log "💾 committing website repo"
commit "${WEB_REPO}" "${msg}"

log "✅ done"
