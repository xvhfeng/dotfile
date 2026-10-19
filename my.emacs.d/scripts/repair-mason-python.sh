#!/usr/bin/env bash
# Ensure Mason PyPI and pyvenv installers can invoke python on macOS.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
config_dir=$(cd -- "$script_dir/.." && pwd)
mason_bin="$config_dir/runtimes/mason/bin"

python3_bin=$(command -v python3 || true)
if [[ -z "$python3_bin" && -x /opt/homebrew/bin/python3 ]]; then
  python3_bin=/opt/homebrew/bin/python3
fi

if [[ -z "$python3_bin" ]]; then
  echo "error: python3 was not found; install Python 3 first." >&2
  exit 1
fi

mkdir -p "$mason_bin"
ln -sfn "$python3_bin" "$mason_bin/python"
echo "Mason python shim: $mason_bin/python -> $python3_bin"
echo "Start Emacs to let Mason automatically install missing tools."
