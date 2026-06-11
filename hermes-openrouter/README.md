# Hermes OpenRouter SBX Mixin

This provider mixin extends the sibling `hermes` agent kit with OpenRouter API-key auth.

## Usage

Set the OpenRouter secret in SBX, then run from the repository root:

```bash
printf '%s\n' "$OPENROUTER_API_KEY" | sbx secret set -g openrouter
sbx run --kit ./hermes --kit ./hermes-openrouter --name hermes-openrouter-test hermes .
```

This mixin sets Hermes' initial model configuration to:

```text
HERMES_INFERENCE_PROVIDER=openrouter
HERMES_INFERENCE_MODEL=anthropic/claude-3.5-haiku
```

The base Hermes kit only writes those defaults when no Hermes provider/model is already configured.

## Checks

```bash
sbx kit validate ./hermes
sbx kit validate ./hermes-openrouter
```
