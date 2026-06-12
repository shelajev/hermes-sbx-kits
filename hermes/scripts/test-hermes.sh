#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-local/hermes-agent-sbx:latest}"
HERMES_VERSION="${HERMES_VERSION:-latest}"

docker build \
  --build-arg "HERMES_VERSION=$HERMES_VERSION" \
  -t "$IMAGE" \
  .

docker run --rm "$IMAGE" hermes --version
docker run --rm "$IMAGE" hermes --help >/dev/null

# Doctor is expected to report missing provider setup in a credential-free smoke
# test, but the command itself should run and report the installed environment.
docker run --rm "$IMAGE" hermes doctor || true

run_provider_smoke() {
  local env_name="$1"
  local provider="$2"
  local model="$3"
  local output

  output="$(
    docker run --rm \
      -e "$env_name" \
      -e HERMES_HOME=/tmp/hermes \
      "$IMAGE" \
      hermes --ignore-user-config --provider "$provider" -m "$model" \
        -z "Reply with exactly: hermes-ok"
  )"
  printf '%s\n' "$output"

  if [ "$output" != "hermes-ok" ]; then
    printf 'Expected provider smoke output to be exactly "hermes-ok"; got: %s\n' "$output" >&2
    return 1
  fi
}

if [ -n "${OPENAI_API_KEY:-}" ]; then
  run_provider_smoke OPENAI_API_KEY openai-api "${OPENAI_MODEL:-gpt-5-mini}"
fi

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  run_provider_smoke ANTHROPIC_API_KEY anthropic "${ANTHROPIC_MODEL:-claude-3-5-haiku-latest}"
fi

if [ -n "${OPENROUTER_API_KEY:-}" ]; then
  run_provider_smoke OPENROUTER_API_KEY openrouter "${OPENROUTER_MODEL:-anthropic/claude-3.5-haiku}"
fi
