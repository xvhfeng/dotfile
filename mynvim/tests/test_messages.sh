#!/usr/bin/env bash
set -euo pipefail

test_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$test_root"

XDG_DATA_HOME=$(mktemp -d) XDG_STATE_HOME=$(mktemp -d) XDG_CACHE_HOME=$(mktemp -d) \
  nvim --clean --headless -u NONE -c 'luafile tests/messages_spec.lua' -c 'qa!'
