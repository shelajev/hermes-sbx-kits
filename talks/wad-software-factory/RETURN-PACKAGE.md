# Return package — WeAreDevelopers software factory

> Real-host follow-up completed: read [CHECKPOINT.md](CHECKPOINT.md) and [HOST-VERIFICATION-2.md](wad-factory-workshop/HOST-VERIFICATION-2.md) first. The real environment creation and both launcher entry profiles now pass; remaining distribution and preview-refresh limitations are documented. Original implementation claims below retain their original scope.

> Provider follow-up: [MULTI-PROVIDER-VERIFICATION.md](wad-factory-workshop/MULTI-PROVIDER-VERIFICATION.md) records the real Pi/Claude/Codex handoff pass, Google spending-cap blocker, and SBX API-key/OAuth distinction.

Implementation summary. Written for the agent or person who tests this next, and for
the authoring pass that turns it into GitHub Pages instructions.

---

## The two repositories

| Repository | Path | Revision | Tags |
|---|---|---|---|
| **A — host control and distributions** | `wad-factory-workshop/` | `5aa0895` on `main` | delivery and host-verification checkpoint tags (see CHECKPOINT.md) |
| **B — the application** | `incident-triage-board/` | `e15230f` on `main` | `app-00-starter`, `app-01-warmup-solution`, `app-02-feature-solution`, `app-03-defective-candidate`, `app-04-intervention-solution` |

Both are local git repositories with no remote configured. The planning documents in this
directory were not modified.

Checkpoint pairing: `wad-factory-workshop/checkpoints/manifest.json` — seven checkpoints,
each naming an app tag, its commit SHA, a profile, the adapter version, the backlog and
app seed versions, and a verifier command.

---

## Read these first

| Document | What it answers |
|---|---|
| `wad-factory-workshop/IMPLEMENTATION-REPORT.md` | what works, exact commands, architecture decisions, what remains |
| `wad-factory-workshop/TEST-REPORT.md` | every case as PASS / FAIL / NOT RUN, with evidence paths and the command to close each gap |
| `wad-factory-workshop/COMPATIBILITY.md` | pinned versions and what was verified on what |
| `wad-factory-workshop/CHECKPOINTS.md` | the chapter ladder, per checkpoint, with commands and recovery |
| `wad-factory-workshop/REHEARSAL.md` | measured timings, room bottlenecks, cuts in priority order |
| `wad-factory-workshop/AUTHORING-HANDOFF.md` | one page per chapter for the instructions author, plus every deviation from the brief |

Operational runbooks: `wad-factory-workshop/technical/` — `HOST-SETUP.md`,
`SANDBOX-SETUP.md`, `MCP-SETUP.md`, `RUN-AND-RECOVER.md`, `MAINTAINER-RELEASE.md`.

---

## What is verified, in one paragraph

**Four** complete crew runs with **real model calls** took `wad-101`, `wad-102`,
`wad-103` and `wad-104` from task contract to accepted, through the real gate: reports
carrying check exit codes, QA review of the exact output commit, fixed workshop checks in
an isolated verification environment, and human acceptance. Runs 1–3 used
`fallback-anthropic-mixed-harness` (Pi coordinating on Anthropic, Claude Code developing,
Claude Code reviewing on a second model); run 4 used the `same-model-claude` entry profile
(three Claude Code sessions, one model) and needed **no manual intervention at all**. Both
advertised entry profiles are therefore verified end to end. 155 automated tests pass
(46 handoff-protocol, 55 host-script, 18 export-verification, 36 MCP protocol and unit),
plus 76 in the application. The MCP adapter serves the real host backlog over stdio and
cannot be tricked into reading another one. The fixed checks fail the starter, fail a
deliberately defective candidate that passes all 42 of its own tests, and pass correct
work.

## What is not verified, in one paragraph

**Every host-side `sbx` interaction.** The implementation environment was itself a Docker
Sandbox with no `sbx` CLI, so nothing could create a sandbox, publish a port, register an
MCP server with the real gateway, SSH-attach, or change policy. Those paths are
implemented against the documented CLI surface and their logic is tested against a
labelled double; each one is listed as NOT RUN in `TEST-REPORT.md` with the exact command
to run it. Also not verified: macOS and x86_64 hosts, a clean host with no Docker Desktop
or Engine, Codex on OpenAI, Pi on Google Gemini, the template image (not built), published
release assets (built locally, not published), the presenter governance and cloud
extensions, and the real-browser test (its browser binary's CDN is denied here).

---

## Reproduce the first run from a clean supported host

```bash
# HOST · a clean macOS or Linux machine. No Docker Desktop, no host Docker Engine.

# 1. Virtualization must be available. macOS: this prints 1. Linux: /dev/kvm is yours.
sysctl -n kern.hv_support 2>/dev/null || ls -l /dev/kvm

# 2. Install the standalone sbx build — the sandboxes-only path, NOT one that also
#    installs Docker Engine: https://docs.docker.com/ai/sandboxes/install/
sbx version && sbx login          # interactive; a browser opens

# 3. The two repositories, as siblings
git clone <repo-A-url> wad-factory-workshop
git clone <repo-B-url> incident-triage-board
cd wad-factory-workshop

# 4. Tools on PATH, then the pinned dependencies
. scripts/env.sh
scripts/install-beans.sh                    # upstream release, checksum verified
scripts/build-mcp.sh                        # needs Go 1.26+; OR see note below
scripts/backlog-init.sh
scripts/mcp-register.sh                     # sbx mcp add --command

# 5. Authenticate one provider, then confirm the whole host
#    (Anthropic + Claude Code is the smallest verified path)
factory doctor                              # must end: "this host is ready"

# 6. The first run
factory submit wad-101
factory run wad-101 --profile same-model-claude --base app-00-starter
#    → prints a run id, creates a sandbox, clones the app at the starter revision,
#      starts Postgres on the sandbox's own engine, serves the board, publishes port
#      8080 to the host, starts the crew, and watches it to a conclusion

# 7. Open the URL the run printed, then
factory status <run-id>
factory collect <run-id>                    # bundle + patch, verified against the base
factory accept <run-id>                     # fixed checks, then your decision
factory clean <run-id>                      # removes only this run
```

**Step 4 note.** `scripts/install-mcp.sh` is the attendee command and needs no Go, but
the release is **not published**, so it currently fails with an explanatory message. Until
it is published, use `scripts/build-mcp.sh` (needs Go), or build the release assets on one
machine and `scripts/install-mcp.sh --from-local` on the others.

### Running without a host `sbx` (what this implementation did)

```bash
# Inside any environment with Docker, Node 22, jq and a provider credential
export FACTORY_MODE=local
factory run wad-101 --profile fallback-anthropic-mixed-harness --base app-00-starter
```

`FACTORY_MODE=local` runs the crew in the current machine instead of a nested sandbox.
It exercises the same crew, handoff, acceptance and export code, and it is how every
crew result in `evidence/` was produced.

---

## Built assets

| Asset | Path | Published |
|---|---|---|
| `beans-mcp` × 5 targets, `SHA256SUMS`, `release-manifest.json`, licence, notices | `wad-factory-workshop/dist/beans-mcp/0.1.0/` | **no** |
| sandbox template image | `wad-factory-workshop/template/Dockerfile` | **not built** |
| ACR policy package (`acr validate` passes) | `wad-factory-workshop/kits/acr/package/` | **no** |
| materialised coding policy | `wad-factory-workshop/kits/acr/materialised/` | committed |

No published URLs exist. Nothing in this package claims an asset is downloadable.

---

## Evidence

| Path | What is in it |
|---|---|
| `wad-factory-workshop/evidence/runs/` | per run: summary, crew manifest (harness/provider/model/session per role), developer and QA reports with check exit codes, messages, decision artifacts, acceptance results, bundle verification |
| `wad-factory-workshop/evidence/mcp/adapter-evidence.md` | adapter version, self-check against the real backlog, full protocol test results |
| `wad-factory-workshop/evidence/network-policy/denial-observed.md` | a real, verbatim network-policy denial captured in this environment |
| `wad-factory-workshop/.local/acceptance/` | per-commit acceptance verdicts, failing and passing both preserved (gitignored runtime state) |

**Two pieces worth reading before anything else**, both in
`evidence/runs/wad-102-wad-102-20260916171222-7zfy150609/`:

1. `messages/…0007….json` — a decision request the crew produced *unprompted*. QA found a
   genuine ambiguity in the task contract, and the coordinator refused to resolve it,
   reporting both positions, the exact field, `src/repo/incidents.ts:117`, and what each
   choice changes in code and tests.
2. `acceptance.json` — the fixed checks catching a criterion QA had passed
   (`102.11`, the board row did not show the assignee), which one correction round fixed.

---

## Remaining human-only actions

1. **Confirm the release destination** and push a `beans-mcp-v0.1.0` tag. Everything else
   is automated (`.github/workflows/release.yml`). Until then remote bootstrap is NOT READY.
2. **Build and push the template image** (both CPU variants), run
   `template/record-inventory.sh`, and put the digest in `checkpoints/manifest.json`.
3. **Publish the ACR policy package**, then declare it in repo B's `agents.yaml`.
4. **One clean-host pass**: no Docker Desktop or Engine, fresh `sbx` install and login,
   the sequence above, every step timed. This closes the largest gap.
5. **Obtain an OpenAI and a Google credential**, then run `presenter-mixed` once.
6. **Rehearse governance and cloud**, or replace them with recordings.
7. **Tag the checkpoint pairs** — `workshop_commit` is `"unresolved"` for all seven;
   procedure in `technical/MAINTAINER-RELEASE.md` §7.

---

## Suggested order for testing this on a real host

1. `factory doctor` — it will name whatever is missing, with a scoped remedy.
2. `tests/handoff-protocol.test.sh`, `tests/host-scripts.test.sh`,
   `(cd mcp/beans && go test ./...)` — these need no sandbox and should pass immediately.
3. Checkpoint `01` with `same-model-claude`. Confirm the published port opens in a
   browser and that `docker ps` inside the sandbox shows Postgres.
4. `scripts/mcp-register.sh` then `factory run wad-102 --task-source mcp`. Confirm the
   retrieved task's `version` matches `factory backlog show wad-102`, and that no `.beans`
   directory exists inside the sandbox.
5. Checkpoint `05`: `factory attach`, then the `handoff send --kind decision` sequence.
   Confirm `herdr agent list` shows the same sessions after attaching.
6. `factory run wad-105` for the denial, then `sbx policy log` and a sandbox-scoped
   allow. Confirm no unrelated policy changed.
7. `tests/export-verification.test.sh` and `factory clean`, then `sbx ls` to confirm
   unrelated sandboxes survived.

Each of these corresponds to a NOT RUN row in `TEST-REPORT.md`. Updating that file with
what you observe is the most useful thing the next pass can do.
