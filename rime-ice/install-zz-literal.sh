#!/usr/bin/env bash
set -euo pipefail

deploy=true
if [[ ${1:-} == --no-deploy ]]; then
  deploy=false
  shift
fi
if (( $# != 0 )); then
  printf 'Usage: %s [--no-deploy]\n' "$0" >&2
  exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
user_dir=${RIME_USER_DIR:-"$HOME/Library/Rime"}
deployer=${RIME_DEPLOYER:-'/Library/Input Methods/Squirrel.app/Contents/MacOS/rime_deployer'}
shared_dir=${RIME_SHARED_DIR:-'/Library/Input Methods/Squirrel.app/Contents/SharedSupport'}
staging_dir=${RIME_STAGING_DIR:-"$user_dir/build"}
backup_suffix="$(date +%Y%m%d%H%M%S)-$$"

mkdir -p "$user_dir/lua"
for relative_path in rime_ice.custom.yaml rime_ice_zz_literal.yaml lua/zz_literal.lua lua/zz_literal_processor.lua lua/zz_literal_translator.lua; do
  source_file="$script_dir/$relative_path"
  destination="$user_dir/$relative_path"
  test -f "$source_file"
  if [[ -e "$destination" ]] && ! cmp -s "$source_file" "$destination"; then
    cp "$destination" "$destination.bak.$backup_suffix"
  fi
  cp "$source_file" "$destination"
done

if [[ $deploy == false ]]; then
  exit 0
fi
test -x "$deployer"
test -d "$shared_dir"
"$deployer" --build "$user_dir" "$shared_dir" "$staging_dir"
