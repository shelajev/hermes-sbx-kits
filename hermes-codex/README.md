# Hermes Codex Auth SBX Kit

This agent kit runs Hermes with OpenAI auth.

It supports both API-key credentials and the Codex/OpenAI subscription OAuth flow used by SBX:

- `OPENAI_API_KEY` from the host environment;
- `OPENAI_API_KEY` parsed from `~/.codex/auth.json`;
- OpenAI OAuth through SBX-managed access and refresh token sentinels when no API key is present.

## Usage

Run from the repository root:

```bash
sbx run --kit ./hermes-codex --name hermes-codex-test hermes-codex .
```

This kit sets Hermes' initial model configuration to:

```text
HERMES_INFERENCE_PROVIDER=openai-api
HERMES_INFERENCE_MODEL=gpt-5-mini
```

The kit only writes those defaults when no Hermes provider/model is already configured.

To add Telegram:

```bash
sbx run --kit ./hermes-codex --kit ./hermes-telegram --name hermes-codex-telegram-test hermes-codex .
```

## Checks

```bash
sbx kit validate ./hermes-codex
```
