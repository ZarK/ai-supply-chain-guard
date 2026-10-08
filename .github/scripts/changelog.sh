#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Error: %s\n' "$*" >&2
  return 1
}

skill_changed() {
  local path
  while IFS= read -r -d '' path; do
    [[ $path != supply-chain-guard/* ]] || return 0
  done < "$1"
  return 1
}

# Read one exact level-two section. Ignore headings inside fenced code.
changelog_section() {
  local file=$1 heading=$2 line active=false found=false fence='' marker
  local fence_pattern='^[[:space:]]*(`{3,}|~{3,})'
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    if [[ $line =~ $fence_pattern ]]; then
      marker=${BASH_REMATCH[1]}
      if [[ -z $fence ]]; then
        fence=$marker
      elif [[ ${marker:0:1} == "${fence:0:1}" && ${#marker} -ge ${#fence} ]]; then
        fence=''
      fi
    elif [[ -z $fence && $line == '## '* ]]; then
      active=false
      if [[ $line == "$heading" ]]; then
        [[ $found == false ]] || { fail "Duplicate $heading section in $file."; return 1; }
        found=true
        active=true
      fi
      continue
    fi
    [[ $active == false ]] || printf '%s\n' "$line"
  done < "$file"
  [[ $found == true ]] || fail "Missing $heading section in $file."
}

# Entries use one top-level '- ' bullet per line.
changelog_bullets() {
  local line fence='' marker
  local fence_pattern='^[[:space:]]*(`{3,}|~{3,})'
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line =~ $fence_pattern ]]; then
      marker=${BASH_REMATCH[1]}
      if [[ -z $fence ]]; then
        fence=$marker
      elif [[ ${marker:0:1} == "${fence:0:1}" && ${#marker} -ge ${#fence} ]]; then
        fence=''
      fi
    elif [[ -z $fence && $line =~ ^-\ [^[:space:]] ]]; then
      printf '%s\n' "$line"
    fi
  done
}

added_unreleased_bullets() {
  local base head old_entries entry old_entry present
  base=$(changelog_section "$1" '## Unreleased') || return 1
  head=$(changelog_section "$2" '## Unreleased') || return 1
  old_entries=$(changelog_bullets <<< "$base")
  while IFS= read -r entry; do
    [[ -n $entry ]] || continue
    present=false
    while IFS= read -r old_entry; do
      if [[ $entry == "$old_entry" ]]; then present=true; break; fi
    done <<< "$old_entries"
    [[ $present == true ]] || printf '%s\n' "$entry"
  done < <(changelog_bullets <<< "$head")
}

# Results: source_tagged and source_urls. Issue text is data, never shell code.
parse_sources() {
  local file=$1 issue=$2 line active=false
  local url_pattern='^- https://[^[:space:]<>]+$'
  source_tagged=false
  source_urls=()
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    if [[ $line == '## Sources' ]]; then
      [[ $source_tagged == false ]] || { fail "Issue #$issue has duplicate Sources sections."; return 1; }
      source_tagged=true
      active=true
    elif [[ $line == '## '* ]]; then
      active=false
    elif [[ $active == true && -n $line ]]; then
      [[ $line =~ $url_pattern ]] || {
        fail "Issue #$issue has a malformed Sources section. Use only '- https://...' lines."
        return 1
      }
      source_urls+=("${line#- }")
    fi
  done < "$file"
}

has_source_link() {
  local entry=$1 prefix needle="]($2)"
  while [[ $entry == *"$needle"* ]]; do
    prefix=${entry%%"$needle"*}
    [[ ! $prefix =~ \[[^][]+$ ]] || return 0
    entry=${entry#*"$needle"}
  done
  return 1
}

validate_changelog() {
  local paths=$1 base=$2 head=$3 added issue body entry url matched complete
  local source_tagged source_urls=()
  shift 3
  [[ -f $paths && -r $paths ]] || { fail 'Cannot read the changed-path file.'; return 1; }
  if ! skill_changed "$paths"; then
    printf 'No skill paths changed; no changelog entry required.\n'
    return 0
  fi
  added=$(added_unreleased_bullets "$base" "$head") || return 1
  [[ -n $added ]] || { fail 'Skill changes require a new bullet under ## Unreleased in CHANGELOG.md.'; return 1; }
  while (( $# )); do
    issue=$1 body=$2
    shift 2
    [[ $issue =~ ^[1-9][0-9]*$ ]] || { fail 'Invalid closing issue number.'; return 1; }
    parse_sources "$body" "$issue" || return 1
    [[ $source_tagged == true ]] || continue
    matched=false
    local issue_pattern="(^|[^[:alnum:]_])#$issue([^[:alnum:]_]|$)"
    while IFS= read -r entry; do
      [[ $entry =~ $issue_pattern ]] || continue
      complete=true
      for url in "${source_urls[@]}"; do
        if ! has_source_link "$entry" "$url"; then complete=false; break; fi
      done
      if [[ $complete == true ]]; then matched=true; break; fi
    done <<< "$added"
    [[ $matched == true ]] || {
      fail "Add one Unreleased bullet with #$issue and every Sources URL as a Markdown link target."
      return 1
    }
  done
  printf 'Changelog entries satisfy the skill change and closing issue requirements.\n'
}

validate_release_tag() {
  local tag=$1 identifier prerelease
  local pattern='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-([0-9A-Za-z-]+\.)*[0-9A-Za-z-]+)?(\+([0-9A-Za-z-]+\.)*[0-9A-Za-z-]+)?$'
  [[ $tag =~ $pattern ]] || { fail 'Use a SemVer tag such as v1.2.3 or v1.2.3-rc.1.'; return 1; }
  prerelease=${tag%%+*}
  if [[ $prerelease == *-* ]]; then
    prerelease=${prerelease#*-}
    local identifiers=()
    IFS=. read -r -a identifiers <<< "$prerelease"
    for identifier in "${identifiers[@]}"; do
      [[ ! $identifier =~ ^0[0-9]+$ ]] || { fail 'Numeric prerelease identifiers must not have leading zeros.'; return 1; }
    done
  fi
}

release_notes() {
  local file=$1 tag=$2 line heading='' section bullets
  validate_release_tag "$tag" || return 1
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    if [[ $line == "## $tag - "* ]]; then
      [[ -z $heading ]] || { fail "Duplicate release section for $tag."; return 1; }
      [[ ${line#"## $tag - "} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { fail "Invalid release date for $tag."; return 1; }
      heading=$line
    fi
  done < "$file"
  [[ -n $heading ]] || { fail "Missing release section for $tag."; return 1; }
  section=$(changelog_section "$file" "$heading") || return 1
  bullets=$(changelog_bullets <<< "$section")
  [[ -n $bullets ]] || { fail "Release section for $tag is empty; add release bullets."; return 1; }
  printf '%s\n' "$section"
}

prepare_changelog() {
  local file=$1 tag=$2 release_date=$3 section bullets line
  validate_release_tag "$tag" || return 1
  section=$(changelog_section "$file" '## Unreleased') || return 1
  bullets=$(changelog_bullets <<< "$section")
  [[ -n $bullets ]] || { fail 'Cannot release an empty ## Unreleased section.'; return 1; }
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    [[ $line != "## $tag - "* ]] || { fail "A changelog section already exists for $tag."; return 1; }
  done < "$file"
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    printf '%s\n' "$line"
    if [[ $line == '## Unreleased' ]]; then
      printf '\n## %s - %s\n' "$tag" "$release_date"
    fi
  done < "$file"
}
