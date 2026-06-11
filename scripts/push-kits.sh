#!/usr/bin/env bash
set -euo pipefail

namespace="${DOCKERHUB_NAMESPACE:-${DOCKER_NAMESPACE:-olegselajev241}}"
version="${KIT_VERSION:-${HERMES_VERSION:-0.16.0}}"
push_latest="${PUSH_LATEST:-true}"
stage="$(mktemp -d /tmp/hermes-kits-push.XXXXXX)"

cleanup() {
  rm -rf "$stage"
}
trap cleanup EXIT

copy_kit() {
  local kit="$1"
  mkdir -p "$stage/$kit"
  rsync -a \
    --exclude '.git' \
    --exclude '.venv' \
    --exclude '.DS_Store' \
    --exclude '.sbx' \
    --exclude '*.tar' \
    --exclude '*.zip' \
    "$kit/" "$stage/$kit/"
}

copy_kit hermes
copy_kit hermes-telegram

sbx kit validate "$stage/hermes"
sbx kit validate "$stage/hermes-telegram"

sbx kit push "$stage/hermes" "docker.io/$namespace/sbx-hermes-kit:$version"
sbx kit push "$stage/hermes-telegram" "docker.io/$namespace/sbx-hermes-telegram-kit:$version"

if [ "$push_latest" = "true" ]; then
  sbx kit push "$stage/hermes" "docker.io/$namespace/sbx-hermes-kit:latest"
  sbx kit push "$stage/hermes-telegram" "docker.io/$namespace/sbx-hermes-telegram-kit:latest"
fi
