#!/usr/bin/env bash
set -euo pipefail

publisher="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build-and-publish.sh"
mktemp_bin=/opt/homebrew/opt/coreutils/libexec/gnubin/mktemp
if [[ -x "$mktemp_bin" ]]; then
    test_root="$("$mktemp_bin" -d --suffix=.dir)"
else
    test_root="$(mktemp -d)"
fi
trap 'rm -rf "$test_root"' EXIT

export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_TERMINAL_PROMPT=0

ssh-keygen -q -t ed25519 -N '' -f "${test_root}/signing-key"
mkdir "${test_root}/bin"
cat >"${test_root}/bin/hugo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p public
cp content.txt public/index.html
EOF
chmod +x "${test_root}/bin/hugo"
export PATH="${test_root}/bin:${PATH}"

init_repo() {
    local repo="$1"
    git init --quiet --bare "${repo}.git"
    git init --quiet --initial-branch=master "$repo"
    git -C "$repo" config user.name 'Publisher Test'
    git -C "$repo" config user.email publisher@example.invalid
    git -C "$repo" config gpg.format ssh
    git -C "$repo" config user.signingkey "${test_root}/signing-key"
    git -C "$repo" config commit.gpgsign true
    git -C "$repo" remote add origin "${repo}.git"
}

seed_repo() {
    git -C "$1" add -A
    git -C "$1" commit --quiet -m 'test: seed publisher fixture'
    git -C "$1" push --quiet --set-upstream origin master
}

assert_equal() {
    if [[ "$1" != "$2" ]]; then
        printf 'FAIL: %s\nExpected: %s\nActual: %s\n' "$3" "$1" "$2" >&2
        cat "${test_root}/publish.log" >&2
        exit 1
    fi
}

for failed_repo in source website; do
    case_dir="${test_root}/${failed_repo} failure"
    mkdir "$case_dir"
    source_repo="${case_dir}/source"
    website_repo="${case_dir}/website"
    init_repo "$source_repo"
    init_repo "$website_repo"
    mkdir "${source_repo}/hack"
    cp "$publisher" "${source_repo}/hack/build-and-publish.sh"
    printf 'public/\n' >"${source_repo}/.gitignore"
    printf 'initial\n' >"${source_repo}/content.txt"
    printf 'initial\n' >"${website_repo}/index.html"
    seed_repo "$source_repo"
    seed_repo "$website_repo"
    printf 'updated\n' >"${source_repo}/content.txt"
    hook="${case_dir}/${failed_repo}.git/hooks/pre-receive"
    printf '#!/usr/bin/env bash\nexit 1\n' >"$hook"
    chmod +x "$hook"

    if WEB_REPO="$website_repo" bash "${source_repo}/hack/build-and-publish.sh" 'test: publish fixture' >"${test_root}/publish.log" 2>&1; then
        printf 'FAIL: a rejected %s push must fail the publisher\n' "$failed_repo" >&2
        exit 1
    fi
    source_head="$(git -C "$source_repo" rev-parse HEAD)"
    failed_head="$(git -C "${case_dir}/${failed_repo}" rev-parse HEAD)"
    rm "$hook"

    WEB_REPO="$website_repo" bash "${source_repo}/hack/build-and-publish.sh" 'test: retry fixture' >>"${test_root}/publish.log" 2>&1
    assert_equal "$source_head" "$(git -C "$source_repo" rev-parse HEAD)" 'retry must not create another source commit'
    assert_equal "$failed_head" "$(git -C "${case_dir}/${failed_repo}" rev-parse HEAD)" 'retry must reuse the failed push commit'
    for repo in "$source_repo" "$website_repo"; do
        assert_equal "$(git -C "$repo" rev-parse HEAD)" "$(git --git-dir="${repo}.git" rev-parse refs/heads/master)" 'retry must push both repositories'
        assert_equal '' "$(git -C "$repo" status --porcelain)" 'retry must leave both working trees clean'
    done
    cmp "${source_repo}/content.txt" "${website_repo}/index.html"

    website_head="$(git -C "$website_repo" rev-parse HEAD)"
    WEB_REPO="$website_repo" bash "${source_repo}/hack/build-and-publish.sh" 'test: unchanged fixture' >>"${test_root}/publish.log" 2>&1
    assert_equal "$source_head" "$(git -C "$source_repo" rev-parse HEAD)" 'unchanged source must not create a commit'
    assert_equal "$website_head" "$(git -C "$website_repo" rev-parse HEAD)" 'unchanged website must not create a commit'
    printf 'PASS: retry after %s push failure and unchanged publish\n' "$failed_repo"
done
