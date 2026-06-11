# Hermes SBX Kits

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
docker.io/shelajev/hermes-agent-sbx:0.16.0
```

Users of this repo should not need to build the image locally once that image is published.

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

Build and push:

```bash
docker build -t docker.io/shelajev/hermes-agent-sbx:0.16.0 ./hermes
docker push docker.io/shelajev/hermes-agent-sbx:0.16.0
```

Optional local tag for development:

```bash
docker tag docker.io/shelajev/hermes-agent-sbx:0.16.0 local/hermes-agent-sbx:0.16.0
```
