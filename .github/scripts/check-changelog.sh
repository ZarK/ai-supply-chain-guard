#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/changelog.sh"

: "${BASE_SHA:?}" "${HEAD_SHA:?}" "${PR_NUMBER:?}" "${GITHUB_REPOSITORY:?}" "${GH_TOKEN:?}"
[[ $BASE_SHA =~ ^[0-9a-f]{40}$ && $HEAD_SHA =~ ^[0-9a-f]{40}$ && $PR_NUMBER =~ ^[1-9][0-9]*$ ]] || {
  fail 'Invalid pull request commit or number.'
  exit 1
}

work=$(mktemp -d)
trap 'rm -f -- "$work"/*; rmdir -- "$work"' EXIT
git diff --no-renames --name-only -z "$BASE_SHA...$HEAD_SHA" > "$work/paths"
if ! skill_changed "$work/paths"; then
  printf 'No skill paths changed; no changelog entry required.\n'
  exit 0
fi
git show "$BASE_SHA:CHANGELOG.md" > "$work/base"
git show "$HEAD_SHA:CHANGELOG.md" > "$work/head"

# Follow the closing references, including all pages and cross-repository issues.
gh api graphql --paginate --slurp \
  -f owner="${GITHUB_REPOSITORY%/*}" -f name="${GITHUB_REPOSITORY#*/}" \
  -F number="$PR_NUMBER" -f query='
    query($owner: String!, $name: String!, $number: Int!, $endCursor: String) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $number) {
          closingIssuesReferences(first: 100, after: $endCursor) {
            nodes { number body }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }' > "$work/issues.json"
jq -e 'length > 0 and all(.[];
  (.errors == null) and
  (.data.repository.pullRequest.closingIssuesReferences.nodes | type == "array"))' \
  "$work/issues.json" > /dev/null || {
  fail 'Could not read the closing issue references. Check token access and retry.'
  exit 1
}
jq '[.[].data.repository.pullRequest.closingIssuesReferences.nodes[]]' \
  "$work/issues.json" > "$work/nodes.json"
count=$(jq 'length' "$work/nodes.json")
issues=()
for (( index=0; index<count; index++ )); do
  number=$(jq -er --argjson index "$index" '.[$index].number' "$work/nodes.json")
  jq -er --argjson index "$index" '.[$index].body | select(type == "string")' \
    "$work/nodes.json" > "$work/issue-$index"
  issues+=("$number" "$work/issue-$index")
done
bash "$script_dir/validate-changelog.sh" "$work/paths" "$work/base" "$work/head" "${issues[@]}"
