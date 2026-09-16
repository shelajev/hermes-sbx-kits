# SBX gateway and host Beans: research conclusion

2026-09-16. Documentation and installed CLI inspection only; no server registered, sandbox started, policy changed, or live tool invocation tested.

## Conclusion

Supported architecture: sandboxed coding agent -> SBX MCP gateway -> host stdio MCP process -> host Beans backlog. No public endpoint, MCP OAuth, host Docker Engine, or AI Governance subscription is needed for this local-command design. Normal SBX login and model authentication still apply. A host runtime or packaged executable is required to run the adapter.

Docker explicitly documents `--command` servers as host subprocesses, supports their working directory through `--dir`, and exposes them through the sandbox gateway. This is different from `--local --url`, which resolves OCI-packaged servers and needs host Docker. Use the explicit-command path. [Gateway documentation](https://docs.docker.com/ai/sandboxes/mcp-gateway/#local-stdio-server), [CLI reference](https://docs.docker.com/reference/cli/sbx/mcp/add/).

When MCP enforcement is inactive, the gateway permits MCP activity without Cedar evaluation. When organization enforcement is active, registration and use require suitable permits; an organization may forbid `local-stdio` registration. Ordinary attendees need no policy setup; rehearse the presenter's actual organization separately. [MCP policy documentation](https://docs.docker.com/ai/sandboxes/governance/access-controls/mcp/).

## Workshop recommendation

Replace the invented incident/runbook reference service with a small read-only Beans MCP adapter. The host owns the actual backlog, and a coding agent retrieves its assigned task and acceptance criteria through the gateway. This stays entirely within the software-factory workflow and avoids duplicate requirements stores.

Core tool surface: `get_task(id)`; optionally `list_tasks()` for discovery. The adapter uses a fixed, workshop-specific Beans configuration/data directory. The installed Beans 0.4.2 exposes `show --json`, `list --json`, `--config`, and `--beans-path`; its command list has no native MCP server. Implement the adapter using these public CLI outputs rather than assuming `beans mcp` exists or parsing Markdown by hand.

The host passes an assigned task ID when launching the crew. A gateway-enabled Claude/Codex role retrieves that task through MCP, writes a task artifact, and communicates it through Herdr/files. Pi remains central to coordination without requiring a new MCP integration. A Pi-only profile would need a verified client adapter if it must itself perform the gateway exercise; that combination must not be promised without implementation evidence.

The adapter is a host process with host-user permissions: `--dir` selects its working directory, not a filesystem jail. Restrict tool inputs to validated IDs and fixed argument arrays; never expose arbitrary shell execution, arbitrary paths, or unrestricted GraphQL mutations. The sandbox does not mount the backlog or receive a generic host-execution capability. No agent can accept its own work through this read-only tool surface.

Registration shape, to be tested after the adapter exists:

```sh
# HOST; illustrative paths and executable, not an existing workshop artifact
sbx mcp add workshop-beans \
  --command /absolute/path/to/node \
  --args /absolute/path/to/workshop/mcp/beans-server.mjs \
  --dir /absolute/path/to/workshop/control

# Attach to an existing local sandbox
sbx mcp load workshop-beans --sandbox factory-demo

# Or include --static-mcp workshop-beans when creating a sandbox
```

The author now requires prebuilt distribution. Prefer versioned standalone adapter binaries from the workshop repository releases, with checksums and a scoped installer. The Node command above illustrates the supported registration shape, not a required implementation language. If using a runtime bundle instead, ship a pinned ready-to-run artifact without requiring attendee compilation. The setup script must resolve absolute executable/file/config paths and must not rely on the daemon inheriting an interactive shell's PATH. Stdio needs no listening port, DNS, tunnel, or manually opened host HTTP endpoint. There is no need to use `--skip-auth` to bypass authentication: the chosen local adapter simply has no OAuth flow.

The custom crew kit must explicitly ensure its MCP-enabled agents connect to the SBX gateway. Built-in single-agent startup support does not prove that every Herdr-started agent in a custom kit is configured correctly. [Gateway integration prerequisites](https://docs.docker.com/ai/sandboxes/mcp-gateway/#prerequisites).

## Governance extension

Simplest presenter proof: retrieve a real task successfully, then demonstrate a policy denial for the same `get_task` tool on a disposable governed run. Alternatively, provide a presenter-only `add_task_note` tool and deny that tool while permitting reads. Preserve host ownership of acceptance and policy. Any allowed note-write fixture must stay scoped to disposable workshop data.

Do not promise policies can distinguish arbitrary `get_task(id)` arguments: the previously suggested allowed-feature/restricted-feature example was not verified. A named tool allow/deny is the clearer documented surface. Registration, invocation, and gateway built-in tools are separate policy actions and must all be checked for the chosen client call path. [MCP access policies](https://docs.docker.com/ai/sandboxes/governance/access-controls/mcp/).

## Required implementation spike

1. Run the adapter against disposable Beans data and verify MCP initialization, tool discovery, and `get_task` through a protocol client.
2. Register it with the pinned SBX CLI, attach it, and have a real sandboxed agent retrieve the exact task through the gateway.
3. Prove the backlog is not mounted inside SBX and that a host-side task update is visible on the next tool read.
4. Prove the attendee path on an account without active MCP governance, without host Docker, and without MCP OAuth. Record all prerequisite versions.
5. Verify adapter startup/restart, missing Beans/config, invalid IDs, working-directory resolution, and sanitized errors. MCP protocol output must not mix with diagnostic stdout.
6. Verify separate presenter policy denial and inspect the corresponding policy evidence. Existing organization restrictions are not evidence that the ungoverned path is unsupported.

The current machine's CLI exposes `mcp add --command/--args/--dir` and `mcp load` supporting local stdio. Documentation and local help differ in unrelated OAuth details, so pin and test the actual workshop build. This research establishes supported capability, not a completed end-to-end validation.
