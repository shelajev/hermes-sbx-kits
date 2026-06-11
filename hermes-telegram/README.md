# Hermes Telegram SBX Mixin

This is a companion mixin for the sibling `hermes` agent kit. It does not install Hermes itself; combine it with the Hermes agent kit from the repository root:

```bash
cd /Users/shelajev/ai-contrib/kits/core
sbx run --kit ./hermes --kit ./hermes-telegram --name hermes-telegram-test hermes .
```

## What This Mixin Does

- allows outbound Telegram API traffic;
- sets safe Telegram gateway defaults;
- installs `python-telegram-bot[webhooks]==22.6` into the existing Hermes tool environment;
- loads `.sbx/.env` from the mounted workspace when present;
- starts `hermes gateway run --replace --accept-hooks` in the background when Telegram config exists;
- writes startup diagnostics to `$HERMES_HOME/logs/telegram-gateway.log`.

The Hermes base image intentionally stays channel-neutral. This mixin carries the Telegram dependency instead of baking Telegram into every Hermes sandbox.

## Low-Friction Setup

Create a local env file in the workspace before starting the sandbox:

```bash
mkdir -p .sbx
cp ./hermes-telegram/sbx.env.example .sbx/.env
$EDITOR .sbx/.env
```

Then run both kits:

```bash
cd /Users/shelajev/ai-contrib/kits/core
sbx run --kit ./hermes --kit ./hermes-telegram --name hermes-telegram-test hermes .
```

The startup hook sources `.sbx/.env` from the sandbox `WORKSPACE_DIR` and starts the Hermes gateway automatically.

The `.sbx/.env` pattern is gitignored in the local kit repos. Keep this file local and rotate the bot token if it is pasted into chat, logs, or issue trackers.

## Required Inputs

Telegram needs:

- a bot token from BotFather;
- your numeric Telegram user ID;
- optional home channel or group chat ID.

Hermes reads these as:

```text
TELEGRAM_BOT_TOKEN=...
TELEGRAM_ALLOWED_USERS=123456789
TELEGRAM_HOME_CHANNEL=123456789
```

The setup wizard can also write them for you:

```bash
hermes gateway setup
hermes gateway run --replace --accept-hooks
```

For a host-driven test after sandbox creation, you can keep an env file outside the repo and pass it only to the gateway process:

```bash
mkdir -p ~/.config
cat > ~/.config/hermes-telegram.env <<'EOF'
TELEGRAM_BOT_TOKEN=...
TELEGRAM_ALLOWED_USERS=123456789
TELEGRAM_HOME_CHANNEL=123456789
EOF

sbx exec -d --env-file ~/.config/hermes-telegram.env hermes-telegram-test \
  hermes gateway run --replace --accept-hooks
```

That starts the gateway with raw process env. It is useful for testing, but it is not equivalent to SBX proxy-managed secret hiding.

## Secret Limitation

Do not model `TELEGRAM_BOT_TOKEN` as an SBX proxy-managed credential with the current CLI. OpenAI, Anthropic, OpenRouter, and GitHub work because the sandbox proxy can inject an auth header. Telegram's Bot API uses URLs like `/bot<TOKEN>/getMe`, so the token is part of the path and cannot be added by header injection.

The current SBX feature gap is tracked upstream as docker/sbx-releases issue #7, "Support custom secrets / environment variables passed into sandboxes". Until SBX supports arbitrary raw env or custom secret injection, this mixin uses a local workspace env file.

For now, the practical interactive test path is:

1. create the sandbox with both kits;
2. run `hermes gateway setup` inside the sandbox;
3. start or restart the gateway;
4. send the bot a Telegram DM.

## Checks

```bash
sbx kit validate ./hermes-telegram
sbx exec hermes-telegram-test sh -lc 'tail -80 "$HERMES_HOME/logs/telegram-gateway.log"'
sbx exec hermes-telegram-test hermes gateway status
```
