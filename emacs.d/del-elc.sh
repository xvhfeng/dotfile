#!/usr/bin/env bash

# Delete every compiled Emacs Lisp file below this configuration's elpa/ tree.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
elpa_dir="$script_dir/elpa"

if [[ ! -d "$elpa_dir" ]]; then
  printf 'elpa directory not found: %s\n' "$elpa_dir" >&2
  exit 1
fi

find "$elpa_dir" -type f -name '*.elc' -print -delete
