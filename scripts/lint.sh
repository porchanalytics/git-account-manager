#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not installed"
  exit 1
fi

shellcheck -x \
  bin/git-account-manager.sh \
  scripts/*.sh \
  lib/*.sh
echo "shellcheck OK"




