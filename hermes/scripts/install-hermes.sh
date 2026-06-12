#!/usr/bin/env bash
set -euo pipefail

HERMES_VERSION="${HERMES_VERSION:-latest}"
HERMES_EXTRAS="${HERMES_EXTRAS:-anthropic,cli,mcp,web}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"

export UV_NO_CONFIG="${UV_NO_CONFIG:-1}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

mkdir -p "$HERMES_HOME"

uv python install "$PYTHON_VERSION"

if [ -n "$HERMES_EXTRAS" ]; then
  package_spec="hermes-agent[$HERMES_EXTRAS]"
else
  package_spec="hermes-agent"
fi

case "$HERMES_VERSION" in
  "" | latest | current)
    ;;
  *)
    package_spec="$package_spec==$HERMES_VERSION"
    ;;
esac

printf 'Installing %s with Python %s\n' "$package_spec" "$PYTHON_VERSION"

uv tool install --python "$PYTHON_VERSION" --force "$package_spec"

installed_version="$(hermes --version)"
printf '%s\n' "$installed_version"

case "$HERMES_VERSION" in
  "" | latest | current)
    ;;
  *)
    case "$installed_version" in
      *"v$HERMES_VERSION"* | *" $HERMES_VERSION "* | *"$HERMES_VERSION"*)
        ;;
      *)
        printf 'Expected Hermes version %s, got: %s\n' "$HERMES_VERSION" "$installed_version" >&2
        exit 1
        ;;
    esac
    ;;
esac
hermes --help >/dev/null
