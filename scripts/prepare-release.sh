#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../.github/scripts/changelog.sh"
(( $# == 1 )) || { fail 'Usage: bash scripts/prepare-release.sh vX.Y.Z'; exit 1; }
tag=$1
validate_release_tag "$tag"
cd -- "$script_dir/.."
[[ $(git branch --show-current) == main ]] || { fail 'Switch to main before preparing a release.'; exit 1; }
[[ -z $(git status --porcelain --untracked-files=all) ]] || { fail 'Start with a clean working tree and index.'; exit 1; }

git fetch --no-tags origin refs/heads/main:refs/remotes/origin/main
[[ $(git rev-parse HEAD) == "$(git rev-parse refs/remotes/origin/main)" ]] || {
  fail 'Main is not current. Update main before preparing a release.'
  exit 1
}
branch="prepare-$tag"
if git show-ref --verify --quiet "refs/tags/$tag"; then fail "Tag $tag already exists locally."; exit 1; fi
if git show-ref --verify --quiet "refs/heads/$branch"; then fail "Branch $branch already exists locally."; exit 1; fi
remote_refs=$(git ls-remote --refs origin "refs/tags/$tag" "refs/heads/$branch")
[[ -z $remote_refs ]] || { fail 'The release tag or preparation branch already exists on origin.'; exit 1; }

# Use origin explicitly. API failures must stop preparation, not mean 'absent'.
repo=$(gh repo view "$(git remote get-url origin)" --json nameWithOwner --jq .nameWithOwner)
work=$(mktemp -d)
trap 'rm -f -- "$work"/*; rmdir -- "$work"' EXIT
require_unpublished_release "$repo" "$tag"
prepare_changelog CHANGELOG.md "$tag" "$(date -u +%F)" > "$work/changelog"

git switch -c "$branch"
cat "$work/changelog" > CHANGELOG.md
git add -- CHANGELOG.md
git commit -S -m "Prepare $tag"
git push --set-upstream origin "HEAD:refs/heads/$branch"
printf 'Publish the Unreleased entries as %s.\n\nReview the changelog and merge after the required checks and approval.\n' \
  "$tag" > "$work/body"
gh pr create --repo "$repo" --base main --head "$branch" \
  --title "Prepare $tag" --body-file "$work/body"
