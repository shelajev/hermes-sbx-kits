#!/usr/bin/env bash
set -euo pipefail

HERMES_VERSION="${HERMES_VERSION:-0.16.0}"
HERMES_EXTRAS="${HERMES_EXTRAS:-anthropic,cli,mcp,web}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"

export UV_NO_CONFIG="${UV_NO_CONFIG:-1}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

mkdir -p "$HERMES_HOME"

uv python install "$PYTHON_VERSION"

if [ -n "$HERMES_EXTRAS" ]; then
  package_spec="hermes-agent[$HERMES_EXTRAS]==$HERMES_VERSION"
else
  package_spec="hermes-agent==$HERMES_VERSION"
fi

uv tool install --python "$PYTHON_VERSION" --force "$package_spec"

hermes --version
hermes --help >/dev/null
