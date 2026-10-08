#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/changelog.sh"
work=$(mktemp -d)
trap 'rm -f -- "$work"/*; rmdir -- "$work"' EXIT
checks=0

expect() {
  local expected=$1 name=$2 actual=0
  shift 2
  "$@" > "$work/output" 2>&1 || actual=$?
  if [[ $expected == pass && $actual != 0 || $expected == fail && $actual == 0 ]]; then
    printf 'FAIL: %s (expected %s, status %s)\n' "$name" "$expected" "$actual" >&2
    cat "$work/output" >&2
    exit 1
  fi
  checks=$((checks + 1))
  printf 'PASS: %s\n' "$name"
}

check() {
  bash "$script_dir/validate-changelog.sh" "$work/paths" "$work/base" "$work/head" "$@"
}

printf 'supply-chain-guard/SKILL.md\0' > "$work/paths"
printf '# Changelog\n\n## Unreleased\n\n## v1.0.0 - 2026-01-01\n\n- Old release.\n' > "$work/base"
cp "$work/base" "$work/head"
expect fail 'skill change without entry' check
printf '.github/workflows/changelog.yml\0README.md\0examples/README.md\0' > "$work/paths"
expect pass 'infrastructure-only change' check
printf 'supply-chain-guard/references/rules.md\0' > "$work/paths"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks.\n' > "$work/head"
expect pass 'skill change with entry' check
printf '## Gap\n\nA gap.\n\n## Sources\n\n- https://example.com/first\n- https://example.com/second\n\n## Plan\n\nFix the gap.\n' > "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks. Sources: [First](https://example.com/first), [Second](https://example.com/second). (#66)\n' > "$work/head"
expect pass 'source links and issue reference in one entry' check 66 "$work/issue"
cp "$work/head" "$work/complete"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks. Sources: [First](https://example.com/first). (#66)\n' > "$work/head"
expect fail 'missing source URL' check 66 "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks. Sources: [First](https://example.com/first), [Second](https://example.com/second).\n' > "$work/head"
expect fail 'missing issue reference' check 66 "$work/issue"
cp "$work/complete" "$work/head"
cp "$work/issue" "$work/canonical"
printf '\n## Sources\n\n- [First](https://example.com/first)\n' > "$work/issue"
expect fail 'malformed Sources section' check 66 "$work/issue"
printf '## Gap\n\nNo published finding.\n' > "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks.\n' > "$work/head"
expect pass 'issue without Sources needs only a normal entry' check 66 "$work/issue"

cp "$work/canonical" "$work/issue"
cp "$work/complete" "$work/head"
expect fail 'issue number cannot match a prefix' check 6 "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- Require source checks. https://example.com/first https://example.com/second (#66)\n' > "$work/head"
expect fail 'bare URLs are not Markdown link targets' check 66 "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- First. Sources: [First](https://example.com/first). (#66)\n- Second. Sources: [Second](https://example.com/second). (#66)\n' > "$work/head"
expect fail 'sources cannot be split across entries' check 66 "$work/issue"
cp "$work/complete" "$work/head"
cp "$work/complete" "$work/base"
expect fail 'unchanged bullet does not count as added' check 66 "$work/issue"
# Main released a bullet after the topic branch started. The topic kept it unchanged.
cp "$work/complete" "$work/merge-base"
prepare_changelog "$work/merge-base" v1.1.0 2026-10-08 > "$work/main"
expect pass 'base tip would incorrectly count the released bullet as new' \
  bash "$script_dir/validate-changelog.sh" "$work/paths" "$work/main" "$work/head"
expect fail 'merge base rejects an unchanged bullet released on main' \
  bash "$script_dir/validate-changelog.sh" "$work/paths" "$work/merge-base" "$work/head"
printf '\n- Add a new rule.\n' >> "$work/head"
expect pass 'merge base accepts a new bullet after main releases' \
  bash "$script_dir/validate-changelog.sh" "$work/paths" "$work/merge-base" "$work/head"
printf '# Changelog\n\n## Unreleased\n\n- Literal [entry]* $(example) `example`.\n' > "$work/base"
cp "$work/base" "$work/head"
expect fail 'membership index treats shell metacharacters as exact text' check
printf '\n- Literal entry $(example) `example`.\n' >> "$work/head"
expect pass 'membership index distinguishes similar literal entries' check
printf '# Changelog\n\n## Unreleased\n' > "$work/base"
printf '# Changelog\n\n## Unreleased\n\n## v1.0.0 - 2026-01-01\n\n- Added only to an old release.\n' > "$work/head"
expect fail 'bullet outside Unreleased does not count' check
printf '# Changelog\n\n## Unreleased\n\n```markdown\n- Example only.\n```\n' > "$work/head"
expect fail 'fenced example does not count as an entry' check
printf '# Changelog\n\n## Unreleased\n\n- First.\n\n## Unreleased\n\n- Second.\n' > "$work/head"
expect fail 'duplicate Unreleased section' check
cp "$work/complete" "$work/head"
printf '## Sources\n\n- https://example.com/first trailing text\n' > "$work/issue"
expect fail 'source URL with trailing text' check 66 "$work/issue"
printf '## Sources\n\n- https://example.com/first\n\n## Sources\n\n- https://example.com/second\n' > "$work/issue"
expect fail 'duplicate Sources section' check 66 "$work/issue"
printf '## Sources\n\n- https://example.com/first\n' > "$work/issue"
printf '## Sources\n\n- https://example.com/second\n' > "$work/other-issue"
expect fail 'every closing issue must match' check 66 "$work/issue" 67 "$work/other-issue"
printf '\n- Add another check. Sources: [Second](https://example.com/second). (#67)\n' >> "$work/head"
expect pass 'multiple closing issues' check 66 "$work/issue" 67 "$work/other-issue"
printf '## Sources\r\n\r\n- https://example.com/report_(detail)?x=1&y=2\r\n' > "$work/issue"
printf '# Changelog\n\n## Unreleased\n\n- Check details. Sources: [Report](https://example.com/report_(detail)?x=1&y=2). (#66)\n' > "$work/head"
expect pass 'CRLF issue and exact URL punctuation' check 66 "$work/issue"

printf '# Changelog\n\n## Unreleased\n\n- Require source checks.\n' > "$work/head"
cat > "$work/issue" <<'EOF'
## Example

````markdown
## Sources
- https://example.com/example
```
## Sources
~~~
## Sources
````
EOF
expect pass 'fenced Sources headings ignore shorter and different fence markers' check 66 "$work/issue"
printf '  ~~~markdown\r\n## Sources\r\n- https://example.com/example\r\n  ~~~~\r\n' > "$work/issue"
expect pass 'indented tilde fence and CRLF hide Sources example' check 66 "$work/issue"
cat >> "$work/issue" <<'EOF'
## Sources

```markdown
## Sources
Example text is not a source URL.
## Plan
```
- https://example.com/first
EOF
expect fail 'real Sources after fenced example still requires a link' check 66 "$work/issue"
cp "$work/complete" "$work/head"
expect pass 'fenced lines and headings inside real Sources are ignored' check 66 "$work/issue"

# Mock the API locally; no authentication or network access is needed.
check_release_lookup() (
  local response_kind=$1
  gh() {
    [[ $# == 3 && $1 == api && $2 == --include &&
      $3 == repos/example/project/releases/tags/v1.2.3 ]] || return 99
    case $response_kind in
      exists) printf 'HTTP/2.0 200 OK\r\n\r\n{}\n'; return 0 ;;
      absent) printf 'HTTP/2.0 404 Not Found\r\n\r\n{}\n'; return 1 ;;
      forbidden) printf 'HTTP/2.0 403 Forbidden\r\n\r\n{}\n'; return 1 ;;
      unauthorized) printf 'HTTP/1.1 401 Unauthorized\r\n\r\n{}\n'; return 1 ;;
      server_error) printf 'HTTP/2.0 500 Internal Server Error\r\n\r\n{}\n'; return 1 ;;
      transport_error) printf 'Connection failed (404 in diagnostic text).\n' >&2; return 1 ;;
      empty) return 1 ;;
    esac
  }
  require_unpublished_release example/project v1.2.3
)
expect fail 'release lookup rejects an existing release' check_release_lookup exists
expect pass 'release lookup permits HTTP 404' check_release_lookup absent
for response_kind in forbidden unauthorized server_error transport_error empty; do
  expect fail "release lookup stops on $response_kind" check_release_lookup "$response_kind"
done

expect pass 'stable SemVer' validate_release_tag v1.2.3
expect pass 'prerelease and build SemVer' validate_release_tag v1.2.3-rc.1+build.01
for tag in v01.2.3 v1.2 v1.2.3-01 v1.2.3-rc..1 v1.2.3+ v1.2.3-; do
  expect fail "invalid SemVer: $tag" validate_release_tag "$tag"
done
expect fail 'release preparation rejects empty Unreleased' prepare_changelog "$work/base" v1.2.3 2026-10-08
prepare_changelog "$work/head" v1.2.3 2026-10-08 > "$work/prepared"
expect pass 'prepared release section supplies notes' release_notes "$work/prepared" v1.2.3
section=$(changelog_section "$work/prepared" '## Unreleased')
expect pass 'preparation leaves Unreleased empty' test -z "$section"
notes=$(release_notes "$work/prepared" v1.2.3)
original=$(changelog_section "$work/head" '## Unreleased')
expect pass 'preparation preserves complete entries' test "$notes" = "$original"
expect fail 'release notes reject missing version' release_notes "$work/prepared" v1.2.4
printf '# Changelog\n\n## Unreleased\n\n## v1.2.3 - 2026-10-08\n\n## v1.2.2 - 2026-10-07\n\n- Previous release.\n' > "$work/empty-release"
expect fail 'release notes reject empty version' release_notes "$work/empty-release" v1.2.3
printf '\n## v1.2.3 - 2026-10-09\n\n- Duplicate.\n' >> "$work/prepared"
expect fail 'release notes reject duplicate version' release_notes "$work/prepared" v1.2.3
cp "$work/head" "$work/existing-release"
printf '\n## v1.2.3 - 2026-10-07\n\n- Already released.\n' >> "$work/existing-release"
expect fail 'preparation rejects an existing version section' prepare_changelog "$work/existing-release" v1.2.3 2026-10-08

printf '%s offline checks passed.\n' "$checks"
