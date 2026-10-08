#!/usr/bin/env bash
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/changelog.sh"

if (( $# < 3 || ($# - 3) % 2 != 0 )); then
  fail 'Usage: validate-changelog.sh PATHS_NUL BASE_CHANGELOG HEAD_CHANGELOG [ISSUE_NUMBER ISSUE_BODY_FILE ...]'
  exit 1
fi
validate_changelog "$@"
