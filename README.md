# Hermes SBX Kits

## Quickstart From Docker Hub

From the project directory you want Hermes to work in, set the OpenAI secret once on the host if you want API-key auth:

```bash
printf '%s\n' "$OPENAI_API_KEY" | sbx secret set -g openai
```

Run Hermes using the published kit:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-codex-kit:latest \
  --name hermes \
  hermes-codex .
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
  --kit docker.io/olegselajev241/sbx-hermes-codex-kit:latest \
  --kit docker.io/olegselajev241/sbx-hermes-telegram-kit:latest \
  --name hermes-telegram \
  hermes-codex .
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

This repository contains Docker Sandbox (SBX) kits for Hermes:

- `hermes`: the provider-neutral base Hermes agent kit.
- `hermes-codex`: a Hermes agent kit that adds OpenAI API key and Codex/OpenAI subscription OAuth auth.
- `hermes-openrouter`: a provider mixin that adds OpenRouter API-key auth.
- `hermes-telegram`: a mixin kit that adds Telegram gateway support to the base Hermes agent.

Use `hermes-codex` for OpenAI/Codex auth. Use `hermes` plus `hermes-openrouter` for OpenRouter. Add `hermes-telegram` when you also want Hermes wired to a Telegram bot.

## Prerequisites

- Docker Sandboxes (`sbx`) installed.
- An OpenAI API key, Codex/OpenAI subscription OAuth, or an OpenRouter API key.
- For Telegram mode: a Telegram bot token, your numeric Telegram user ID, and optionally a home chat/channel ID.

The Hermes kit is configured to use this prebuilt image:

```text
docker.io/olegselajev241/hermes-agent-sbx:latest
```

Users of this repo should not need to build the image locally once that image is published.

The kits are also published as OCI artifacts:

```text
docker.io/olegselajev241/sbx-hermes-kit:latest
docker.io/olegselajev241/sbx-hermes-codex-kit:latest
docker.io/olegselajev241/sbx-hermes-openrouter-kit:latest
docker.io/olegselajev241/sbx-hermes-telegram-kit:latest
```

## Configure OpenAI Or Codex

For API-key auth, set the OpenAI service secret once on the host:

```bash
printf '%s\n' "$OPENAI_API_KEY" | sbx secret set -g openai
```

If no `OPENAI_API_KEY` is available, the `hermes-codex` kit can use the SBX OpenAI OAuth flow and the same proxy-managed sentinel contract used by the Codex kit.

Check stored secrets:

```bash
sbx secret ls
```

The `hermes-codex` kit defaults Hermes to:

```text
HERMES_INFERENCE_PROVIDER=openai-api
HERMES_INFERENCE_MODEL=gpt-5-mini
```

## Configure OpenRouter

Set the OpenRouter service secret once on the host:

```bash
printf '%s\n' "$OPENROUTER_API_KEY" | sbx secret set -g openrouter
```

The `hermes-openrouter` mixin defaults Hermes to:

```text
HERMES_INFERENCE_PROVIDER=openrouter
HERMES_INFERENCE_MODEL=anthropic/claude-3.5-haiku
```

## Run Hermes Only

From this repository root:

```bash
sbx run --kit ./hermes-codex --name hermes-test hermes-codex .
```

Or use the published kit directly:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-codex-kit:latest \
  --name hermes-test \
  hermes-codex .
```

For OpenRouter instead:

```bash
sbx run --kit ./hermes --kit ./hermes-openrouter --name hermes-openrouter-test hermes .
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
sbx run --kit ./hermes-codex --kit ./hermes-telegram --name hermes-telegram-test hermes-codex .
```

Or use the published kits directly:

```bash
sbx run \
  --kit docker.io/olegselajev241/sbx-hermes-codex-kit:latest \
  --kit docker.io/olegselajev241/sbx-hermes-telegram-kit:latest \
  --name hermes-telegram-test \
  hermes-codex .
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

OpenAI and OpenRouter are configured with SBX proxy-managed service secrets because the proxy can inject an `Authorization` header for their API hosts. The `hermes-codex` kit also includes the OpenAI OAuth block for subscription auth when no API key is configured.

Telegram is different: Telegram Bot API requests contain the bot token in the URL path, so SBX header injection is not suitable. Until SBX supports arbitrary env/secret injection, the Telegram mixin uses a local `.sbx/.env` file in the mounted workspace.

Do not commit `.sbx/.env`.

## Maintainer: Build And Publish Image

The base image is intentionally channel-neutral. Telegram dependencies are installed by the Telegram mixin.

## Maintainer: GitHub Actions

The repository has two manual-only workflows:

- **Publish Kits**: validates and pushes only the SBX kit artifacts.
- **Release Hermes Image And Kits**: builds and pushes a new Hermes base Docker image as `latest`, then pushes the kit artifacts as `latest`.

Required repository secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

`DOCKERHUB_TOKEN` should be a Docker Hub access token with permission to push to:

```text
docker.io/<DOCKERHUB_USERNAME>/hermes-agent-sbx
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-kit
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-codex-kit
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-openrouter-kit
docker.io/<DOCKERHUB_USERNAME>/sbx-hermes-telegram-kit
```

The workflows do not need OpenAI, Telegram, or GitHub write secrets. They only push to Docker Hub.

Trigger kits-only publishing:

```bash
gh workflow run "Publish Kits" \
  --field sbx_release=v0.32.0
```

Trigger a Hermes image update plus kit publishing:

```bash
gh workflow run "Release Hermes Image And Kits" \
  --field hermes_version=0.16.0 \
  --field platforms=linux/amd64,linux/arm64 \
  --field sbx_release=v0.32.0
```

Build and push:

```bash
docker build -t docker.io/olegselajev241/hermes-agent-sbx:latest ./hermes
docker push docker.io/olegselajev241/hermes-agent-sbx:latest
```

Push kit artifacts:

```bash
./scripts/push-kits.sh
```

Current `sbx kit push` packages directory contents directly and does not honor `.gitignore` or `.dockerignore`. The helper script stages a clean temporary copy before pushing, so local files such as `.sbx/.env` or `.venv` are not included.

Optional local tag for development:

```bash
docker tag docker.io/olegselajev241/hermes-agent-sbx:latest local/hermes-agent-sbx:0.16.0
```
