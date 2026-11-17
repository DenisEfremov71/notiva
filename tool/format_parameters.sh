#!/bin/sh
# Runs tool/format_parameters.dart from a cached kernel snapshot so that
# formatting on save is fast. The snapshot is rebuilt whenever the script or
# the resolved dependencies change.
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
script="$root/tool/format_parameters.dart"
snapshot="$root/.dart_tool/format_parameters.dill"

if [ ! -f "$snapshot" ] || [ "$script" -nt "$snapshot" ] || [ "$root/pubspec.lock" -nt "$snapshot" ]; then
  (cd "$root" && dart compile kernel "$script" -o "$snapshot" >/dev/null)
fi

exec dart "$snapshot" "$@"
