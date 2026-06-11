# Hermes SBX Kits

## Quickstart From Docker Hub

From the project directory you want Hermes to work in, set the OpenAI secret once on the host:

```bash
printf '%s\n' "$OPENAI_API_KEY" | sbx secret set -g openai
```

Run Hermes using the published kit:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-kit:latest \
  --name hermes \
  hermes .
```

Reattach later:

```bash
sbx run hermes
```

## Telegram Quickstart From Docker Hub

Create a local Telegram env file in the same project directory:

```bash
mkdir -p .sbx
cat > .sbx/.env <<'EOF'
TELEGRAM_BOT_TOKEN=<your-telegram-bot-token>
TELEGRAM_ALLOWED_USERS=<your-numeric-telegram-user-id>
TELEGRAM_HOME_CHANNEL=<your-numeric-telegram-user-id-or-chat-id>
EOF
```

Run Hermes with Telegram using both published kits:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-kit:latest \
  --kit docker.io/olegselajev241/sbx-hermes-telegram-kit:latest \
  --name hermes-telegram \
  hermes .
```

Reattach later:

```bash
sbx run hermes-telegram
```

Check Telegram status and logs:

```bash
sbx exec hermes-telegram hermes gateway status
sbx exec hermes-telegram sh -lc 'tail -160 "$HERMES_HOME/logs/agent.log"'
```

This repository contains two Docker Sandbox (SBX) kits:

- `hermes`: the base Hermes agent kit.
- `hermes-telegram`: a mixin kit that adds Telegram gateway support to the base Hermes agent.

Use only `hermes` when you want the Hermes terminal agent. Use both kits when you want Hermes wired to a Telegram bot.

## Prerequisites

- Docker Sandboxes (`sbx`) installed.
- An OpenAI API key. This is the provider path we tested.
- For Telegram mode: a Telegram bot token, your numeric Telegram user ID, and optionally a home chat/channel ID.

The Hermes kit is configured to use this prebuilt image:

```text
docker.io/olegselajev241/hermes-agent-sbx:0.16.0
```

Users of this repo should not need to build the image locally once that image is published.

The kits are also published as OCI artifacts:

```text
docker.io/olegselajev241/sbx-hermes-kit:latest
docker.io/olegselajev241/sbx-hermes-telegram-kit:latest
```

## Configure OpenAI

Set the OpenAI service secret once on the host:

```bash
printf '%s\n' "$OPENAI_API_KEY" | sbx secret set -g openai
```

Check stored secrets:

```bash
sbx secret ls
```

The Hermes kit defaults to:

```text
HERMES_INFERENCE_PROVIDER=openai-api
HERMES_INFERENCE_MODEL=gpt-5-mini
```

## Run Hermes Only

From this repository root:

```bash
sbx run --kit ./hermes --name hermes-test hermes .
```

Or use the published kit directly:

```bash
sbx run --kit docker.io/olegselajev241/sbx-hermes-kit:latest --name hermes-test hermes .
```

For an existing sandbox:

```bash
sbx run hermes-test
```

## Run Hermes With Telegram

Create a local env file in the workspace where you run `sbx`. This file is ignored by git:

```bash
mkdir -p .sbx
cp ./hermes-telegram/sbx.env.example .sbx/.env
$EDITOR .sbx/.env
```

Fill in:

```env
TELEGRAM_BOT_TOKEN=<your-bot-token>
TELEGRAM_ALLOWED_USERS=<your-numeric-telegram-user-id>
TELEGRAM_HOME_CHANNEL=<your-numeric-telegram-user-id-or-chat-id>
```

Then create and attach to the Telegram-enabled sandbox:

```bash
sbx run --kit ./hermes --kit ./hermes-telegram --name hermes-telegram-test hermes .
```

Or use the published kits directly:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-kit:latest \
  --kit docker.io/olegselajev241/sbx-hermes-telegram-kit:latest \
  --name hermes-telegram-test \
  hermes .
```

The `hermes-telegram` mixin installs `python-telegram-bot[webhooks]`, loads `.sbx/.env` from `WORKSPACE_DIR`, and starts:

```bash
hermes gateway run --replace --accept-hooks
```

For an existing sandbox:

```bash
sbx run hermes-telegram-test
```

## Verify Telegram

Check gateway status:

```bash
sbx exec hermes-telegram-test hermes gateway status
```

Check logs:

```bash
sbx exec hermes-telegram-test sh -lc 'tail -160 "$HERMES_HOME/logs/agent.log"'
```

Send a DM to the Telegram bot. If it works, the log should show Telegram connected, an inbound message from your user ID, an OpenAI request, and a Telegram response send.

## Notes On Secrets

OpenAI is configured with SBX proxy-managed service secrets because the proxy can inject an `Authorization` header for `api.openai.com`.

Telegram is different: Telegram Bot API requests contain the bot token in the URL path, so SBX header injection is not suitable. Until SBX supports arbitrary env/secret injection, the Telegram mixin uses a local `.sbx/.env` file in the mounted workspace.

Do not commit `.sbx/.env`.

## Maintainer: Build And Publish Image

The base image is intentionally channel-neutral. Telegram dependencies are installed by the Telegram mixin.

## Maintainer: GitHub Actions

The repository has two manual-only workflows:

- **Publish Kits**: validates and pushes only the SBX kit artifacts.
- **Release Hermes Image And Kits**: builds and pushes a new Hermes base Docker image, updates the Hermes kit image reference, commits that reference update, then pushes the kit artifacts.

Required repository secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

`DOCKERHUB_TOKEN` should be a Docker Hub access token with permission to push to:

```text
docker.io/<DOCKERHUB_USERNAME>/hermes-agent-sbx
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-kit
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-telegram-kit
```

The image-and-kits workflow uses the built-in `GITHUB_TOKEN` to commit the updated image reference back to the repository. In GitHub repository settings, Actions must have **Read and write permissions**. If branch protection blocks bot pushes, use a manual PR flow or adjust the protection rule.

Trigger kits-only publishing:

```bash
gh workflow run "Publish Kits" \
  --field kit_version=0.16.0 \
  --field push_latest=true \
  --field sbx_release=v0.32.0
```

Trigger a Hermes image update plus kit publishing:

```bash
gh workflow run "Release Hermes Image And Kits" \
  --field hermes_version=0.16.0 \
  --field image_tag=0.16.0 \
  --field platforms=linux/amd64,linux/arm64 \
  --field push_latest=true \
  --field sbx_release=v0.32.0
```

Build and push:

```bash
docker build -t docker.io/olegselajev241/hermes-agent-sbx:0.16.0 ./hermes
docker push docker.io/olegselajev241/hermes-agent-sbx:0.16.0
```

Push kit artifacts:

```bash
./scripts/push-kits.sh
```

Current `sbx kit push` packages directory contents directly and does not honor `.gitignore` or `.dockerignore`. The helper script stages a clean temporary copy before pushing, so local files such as `.sbx/.env` or `.venv` are not included.

Optional local tag for development:

```bash
docker tag docker.io/olegselajev241/hermes-agent-sbx:0.16.0 local/hermes-agent-sbx:0.16.0
```
