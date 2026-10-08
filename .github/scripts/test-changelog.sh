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
