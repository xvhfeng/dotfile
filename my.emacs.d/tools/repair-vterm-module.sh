#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_root="$(cd "${script_directory}/.." && pwd)"
vterm_directory="${config_root}/runtimes/straight/build/vterm"
build_directory="${vterm_directory}/build"
source_module="${vterm_directory}/vterm-module.so"
rebuild=false

usage() {
  printf '%s\n' \
    "Usage: $0 [--check | --rebuild]" \
    "  no option   Build only when missing, repair the module suffix, then verify." \
    "  --check     Verify only; do not build or create a symlink." \
    "  --rebuild   Reconfigure and rebuild before repairing and verifying."
}

mode="repair"
case "${1:-}" in
  "") ;;
  --check) mode="check" ;;
  --rebuild) rebuild=true ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

if [[ ! -f "${vterm_directory}/CMakeLists.txt" ]]; then
  printf 'Vterm source is missing: %s\n' "${vterm_directory}" >&2
  printf '%s\n' 'Start Emacs once so Straight installs vterm, then run this script again.' >&2
  exit 1
fi

if [[ "${mode}" != "check" && ( "${rebuild}" == true || ! -f "${source_module}" ) ]]; then
  command -v cmake >/dev/null 2>&1 || {
    printf '%s\n' 'CMake is missing. On macOS run: brew install cmake libvterm' >&2
    exit 1
  }
  cmake -G 'Unix Makefiles' -S "${vterm_directory}" -B "${build_directory}"
  cmake --build "${build_directory}"
fi

if [[ ! -f "${source_module}" ]]; then
  printf 'Vterm native module is missing: %s\n' "${source_module}" >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin) expected_module="${vterm_directory}/vterm-module.dylib" ;;
  *) expected_module="${source_module}" ;;
esac

if [[ "${expected_module}" != "${source_module}" ]]; then
  if [[ "${mode}" == "check" ]]; then
    [[ -e "${expected_module}" ]] || {
      printf 'Expected module alias is missing: %s\n' "${expected_module}" >&2
      exit 1
    }
  elif [[ ! -e "${expected_module}" ]]; then
    ln -s "$(basename "${source_module}")" "${expected_module}"
  fi
fi

if command -v emacs >/dev/null 2>&1; then
  emacs --batch -Q -L "${vterm_directory}" \
    --eval "(progn (require 'vterm) (princ \"vterm native module loaded successfully\\n\"))"
else
  printf '%s\n' 'Emacs is not on PATH; module file repaired, load verification skipped.'
fi

printf 'Vterm module ready: %s\n' "${expected_module}"
