# Hermes SBX Kit

This directory is a draft SBX agent kit for [Nous Research Hermes Agent](https://github.com/NousResearch/hermes-agent).

## Approach

Bake Hermes into a custom agent image and keep `spec.yaml` lightweight. The image handles Python 3.11 and the Hermes package; the base kit manifest handles the provider-neutral entrypoint and baseline network policy. Provider auth and provider-specific network policy belong in companion kits such as `../hermes-codex` and `../hermes-openrouter`. `../hermes-codex` is a standalone agent kit because SBX requires OAuth policy on agent kits; `../hermes-openrouter` is a mixin. Channel-specific dependencies belong in mixin kits such as `../hermes-telegram`. With the currently tested `sbx` CLI, sandbox persistence is controlled by the sandbox lifecycle; `agent.persistence` is not accepted in `spec.yaml`.

The base image is `docker/sandbox-templates:shell-docker` because it already matches the sandbox runtime user model (`agent`, UID 1000) and includes `uv`, Node, and common developer tools. Hermes requires Python `>=3.11,<3.14`, so the Dockerfile installs Python 3.11 through `uv` rather than using the template's default `python3`.

## Files

- `Dockerfile` builds `docker.io/olegselajev241/hermes-agent-sbx:latest` for publishing and `local/hermes-agent-sbx:latest` for local development.
- `spec.yaml` declares the Hermes agent kit entrypoint and provider-neutral network policy.
- `scripts/install-hermes.sh` is the detailed install script used by the image build.
- `scripts/test-hermes.sh` builds the image and runs credential-free smoke tests, plus optional real model tests if API keys are present.

## Build And Smoke Test

```bash
chmod +x scripts/*.sh
./scripts/test-hermes.sh
```

The credential-free tests should prove that:

- the image builds;
- `hermes --version` works;
- `hermes --help` works;
- `hermes doctor` runs and reports expected missing provider configuration.

By default, the image build installs the newest PyPI release of `hermes-agent`.
Pin a specific release when needed:

```bash
HERMES_VERSION=0.16.0 ./scripts/test-hermes.sh
```

## Current Status

As of this working draft:

- Docker image build and Docker one-shot smoke tests pass with `openai-api`.
- `sbx kit validate .` passes with `sbx` v0.31.0-rc1.
- Fresh SBX sandbox creation works after loading the image into the SBX template store.
- The base image stays provider-neutral and channel-neutral. OpenAI/Codex auth is provided by the sibling `../hermes-codex` agent kit; OpenRouter auth is added by the sibling `../hermes-openrouter` mixin; Telegram dependencies are installed by the sibling `../hermes-telegram` mixin.
- The kit bootstrap writes Hermes' own `model.provider` and `model.default` config only when a provider mixin supplies `HERMES_INFERENCE_PROVIDER` or `HERMES_INFERENCE_MODEL`.
- Interactive `hello` succeeds through the SBX OpenAI credential proxy when using the sibling `../hermes-codex` agent kit.
- The kit overrides `NO_PROXY` / `no_proxy` without the bracketed `[::1]` entry because Hermes' auxiliary title-generation path can trip httpx URL parsing with `Invalid port: ':1]'` when the sandbox runtime injects `[::1]`.

Fast interactive OpenRouter test from this directory:

```bash
sbx run --kit . --kit ../hermes-openrouter --name hermes-openrouter-test hermes .
```

For an already-created sandbox, reattach without `--kit`:

```bash
sbx run hermes-test
```

## Try It From The Host

Run these commands from this directory:

```bash
cd /Users/shelajev/ai-contrib/kits/core/hermes
chmod +x scripts/*.sh
docker build -t local/hermes-agent-sbx:latest .
```

Confirm the image has Hermes installed:

```bash
docker run --rm -it local/hermes-agent-sbx:latest hermes --version
docker run --rm -it local/hermes-agent-sbx:latest hermes doctor
```

`hermes doctor` should run even without credentials. It will report expected first-run warnings such as missing provider setup, missing `~/.hermes/.env`, and optional tool dependencies. Those warnings are useful signal: the CLI is installed and Hermes can inspect its runtime.

To start Hermes directly in Docker:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -e HERMES_HOME=/home/agent/.hermes \
  local/hermes-agent-sbx:latest
```

Yes, this drops you into Hermes' terminal UI because the image default command is `hermes`.

If you want Hermes state to persist across direct Docker runs, use a named volume:

```bash
docker volume create hermes-home
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v hermes-home:/home/agent/.hermes \
  local/hermes-agent-sbx:latest
```

For a real model call without running the full interactive setup, pass a provider key and use one-shot mode:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -e HERMES_HOME=/tmp/hermes \
  -e OPENAI_API_KEY \
  local/hermes-agent-sbx:latest \
  hermes --ignore-user-config --provider openai-api -m "${OPENAI_MODEL:-gpt-5-mini}" \
    -z "Reply with exactly: hermes-ok"
```

or:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -e HERMES_HOME=/tmp/hermes \
  -e ANTHROPIC_API_KEY \
  local/hermes-agent-sbx:latest \
  hermes --ignore-user-config --provider anthropic -m "${ANTHROPIC_MODEL:-claude-3-5-haiku-latest}" \
    -z "Reply with exactly: hermes-ok"
```

or:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -e HERMES_HOME=/tmp/hermes \
  -e OPENROUTER_API_KEY \
  local/hermes-agent-sbx:latest \
  hermes --ignore-user-config --provider openrouter -m "${OPENROUTER_MODEL:-anthropic/claude-3.5-haiku}" \
    -z "Reply with exactly: hermes-ok"
```

To test a real model call through Docker, export one of:

```bash
export OPENAI_API_KEY=...
./scripts/test-hermes.sh
```

```bash
export ANTHROPIC_API_KEY=...
./scripts/test-hermes.sh
```

```bash
export OPENROUTER_API_KEY=...
./scripts/test-hermes.sh
```

## SBX Test Plan

This is the path to test the kit as an SBX agent kit rather than as a plain Docker container.

1. Build the image locally on the host and load it into the SBX template store:

   ```bash
   docker build -t local/hermes-agent-sbx:latest .
   docker save local/hermes-agent-sbx:latest -o /tmp/hermes-agent-sbx-latest.tar
   sbx template load /tmp/hermes-agent-sbx-latest.tar
   rm -f /tmp/hermes-agent-sbx-latest.tar
   ```

   `docker build` makes the image available to Docker Desktop. `sbx` uses its
   own template image store, so `sbx create`/`sbx run` will otherwise fail with
   a pull error for `local/hermes-agent-sbx:latest`.

2. Set one host-side secret for the provider being tested when using API-key auth.

   With the current `sbx` CLI, secrets are stored by service name. Use global
   scope when you want the provider available to new sandboxes:

   ```bash
   printf '%s\n' "$OPENAI_API_KEY" | sbx secret set -g openai
   # or:
   printf '%s\n' "$OPENROUTER_API_KEY" | sbx secret set -g openrouter
   ```

   You can also run `sbx secret set -g openai` or `sbx secret set -g openrouter`
   and paste the value at the prompt. Check what is already configured with
   `sbx secret ls`.

3. Run the kit with a provider mixin from this directory:

   ```bash
   sbx run --kit . --kit ../hermes-openrouter hermes .
   ```

   The kit entrypoint is `hermes --yolo`, so this should drop you into Hermes' terminal UI inside the sandbox. `--yolo` bypasses Hermes command approval prompts; remove it from `spec.yaml` if you want Hermes to ask before running risky commands.

   For a named sandbox you can smoke-test non-interactively first:

   ```bash
   sbx create --kit . --kit ../hermes-openrouter --name hermes-kit-smoke hermes .
   sbx exec hermes-kit-smoke hermes --version
   sbx exec hermes-kit-smoke hermes --ignore-user-config --provider openrouter \
     -m "${OPENROUTER_MODEL:-anthropic/claude-3.5-haiku}" \
     -z "Reply with exactly: hermes-ok"
   sbx run --kit . --kit ../hermes-openrouter hermes-kit-smoke
   ```

4. Inside Hermes, configure a model if needed:

   ```text
   /model
   ```

   Or run the setup wizard:

   ```text
   /setup
   ```

   If the provider credential is proxy-managed by SBX, Hermes should be able to call that provider through the sandbox egress proxy without the raw secret being present in the sandbox environment.

   Provider mixins set initial interactive Hermes defaults via
   `HERMES_INFERENCE_PROVIDER` and `HERMES_INFERENCE_MODEL`. The base kit does
   not choose a provider on its own.

5. Run a simple prompt first, for example:

   ```text
   say exactly hermes-ok
   ```

   Then test tool use against a throwaway workspace.

6. Check the sandbox network policy logs if provider traffic is blocked:

   ```bash
   sbx policy log
   ```

7. If the kit starts but Hermes cannot call a provider, check these in order:

   - the image tag in `spec.yaml` matches the local image you built;
   - the corresponding `sbx secret set ...` value exists on the host;
   - the provider domain is present in `network.allowedDomains`;
   - `network.serviceDomains` maps that provider host to the credential source;
   - `sbx policy log` does not show a stricter local, corporate, or system policy blocking the request.

## Telegram Mixin Direction

Hermes does not expose a separate `hermes telegram` command. Telegram runs through the Hermes messaging gateway:

```bash
hermes gateway setup
hermes gateway run --replace --accept-hooks
```

The sibling `../hermes-telegram` kit is a mixin intended to be combined with this agent kit and a provider mixin. For OpenAI/Codex auth, combine Telegram with the sibling `../hermes-codex` agent kit instead:

```bash
sbx run --kit ../hermes-codex --kit ../hermes-telegram --name hermes-telegram-test hermes-codex .
```

The Telegram mixin installs `python-telegram-bot[webhooks]==22.6` into Hermes' tool environment and starts the gateway automatically when Telegram config is present.

The Telegram bot token cannot use the same SBX proxy-managed credential pattern as OpenAI/Anthropic because Telegram's Bot API puts the token in the request URL path (`/bot<TOKEN>/...`) rather than in an auth header. With the current `sbx` CLI, the lowest-friction path is to put Telegram gateway settings in a local, ignored workspace env file:

```bash
mkdir -p .sbx
cp ../hermes-telegram/sbx.env.example .sbx/.env
$EDITOR .sbx/.env
```

When the sandbox starts, the Telegram mixin sources that file from the sandbox `WORKSPACE_DIR` and launches `hermes gateway run --replace --accept-hooks`.

The upstream SBX feature gap is tracked in docker/sbx-releases issue #7, "Support custom secrets / environment variables passed into sandboxes". Until arbitrary env/secret injection exists, the local workspace env file is the lowest-friction option.

For a host-driven smoke test without typing into the setup wizard, you can also pass an env file only to the gateway process:

```bash
cat > ~/.config/hermes-telegram.env <<'EOF'
TELEGRAM_BOT_TOKEN=...
TELEGRAM_ALLOWED_USERS=123456789
TELEGRAM_HOME_CHANNEL=123456789
EOF

sbx exec -d --env-file ~/.config/hermes-telegram.env hermes-telegram-test \
  hermes gateway run --replace --accept-hooks
```

This is raw process environment, not proxy-managed secret hiding. Use it for testing only if that tradeoff is acceptable.

## Hermes Testing

Use three layers:

1. Static install checks: `hermes --version`, `hermes --help`.
2. Local runtime checks: `hermes doctor`, optionally with `HERMES_HOME=/tmp/hermes` for a clean home.
3. Provider integration checks: `hermes --ignore-user-config --provider <provider> -m <model> -z "Reply with exactly: hermes-ok"`.

For current Hermes releases, the relevant provider slugs are:

- `openai-api` for a raw `OPENAI_API_KEY` against `api.openai.com`;
- `anthropic` for `ANTHROPIC_API_KEY`, `ANTHROPIC_TOKEN`, or compatible Claude credentials;
- `openrouter` for `OPENROUTER_API_KEY`;
- `openai-codex` for Hermes' OpenAI Codex OAuth/runtime path.

`openai-codex` is not the same provider path as `openai-api`: a raw `OPENAI_API_KEY`
uses `openai-api`, while `openai-codex` expects Hermes/Codex authentication. The
current automated smoke path uses `openai-api` because it is key-based and works
well in Docker and SBX credential proxy flows.

Claude Code credentials are also not the same thing as an Anthropic API key. For
the kit as written, the cleanest Claude path is a direct `ANTHROPIC_API_KEY`
through the `anthropic` provider, or Claude-family models through OpenRouter.

## Open Questions Before Publishing

- Confirm the final incoming SBX kit spec field for the kit-owned Dockerfile. The current manifest still points at an image tag, while the requested future behavior is that the agent kit can ship or build a final image.
- Confirm whether a future SBX kit schema restores an explicit persistence field. `sbx` v0.31.0-rc1 rejects `agent.persistence`, so this kit omits it.
- Decide which Hermes extras to bake in. The current image includes `anthropic,cli,mcp,web`; broader messaging, browser, and voice extras should only be added if the kit needs those workflows.
