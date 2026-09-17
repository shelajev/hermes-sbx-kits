# Workshop implementation assessment

Assessment date: 2026-09-17. Implementation reviewed: workshop `5aa0895`, application
`e15230f`. This is a teaching and scope assessment, not a fresh runtime verification
or a replacement for the accepted planning brief. No implementation was changed.

## Verdict

The system is a credible implementation of the central promise: give a coding team
an isolated development environment, let it retrieve work from the host, implement
and review a real change, and bring back evidence. Keep that system and the incident
board. The main work now is making the assembly understandable and repeatable for a
room of people.

The current repository is an integration test rig and reference implementation. It
is not yet a two-hour learner experience. Its main command composes the environment,
transfers code, starts the database and web server, creates all three agents, assigns
work, and watches the gates. That is useful automation but hides most of the things
participants came to learn to assemble.

A tenfold reduction in the code and configuration participants need to read is
realistic. A tenfold reduction in all runtime code, preserving the demonstrated
behavior and its reliability, is not established. Do not confuse a short wrapper
around the existing implementation with deleting that implementation.

## Match to the intended stories

| Intended learning | What exists | Teaching assessment / needed adjustment |
|---|---|---|
| Build from Docker components, rather than claim a released platform product | SBX lifecycle, kits, policies, MCP adapter, external host state | Strong fit. Keep the component diagram visible as pieces are introduced. |
| A worker has a real development environment | TypeScript UI/API, Postgres, Testcontainers, real agent implementation | Strong. Show the actual Docker daemon and a disposable test database inside SBX. No need to redesign the app. |
| Published ports make the result visible | Real health checks and host-loopback port publishing passed | Keep. The running server can retain old modules after a change: add an explicit refresh/restart with migrations before the final browser reveal. A green check plus stale UI undermines the lesson. |
| First experience is one worker / one model | The first-worker checkpoint calls `factory run`, which starts all three roles | Reveal one assistant first, or describe the first run honestly as a supplied crew. Best fit to the brief: a short direct worker exercise before introducing the team. |
| Herdr coordinates the team; files carry durable handoffs | Three sessions, real messages, wakeups, reports, coordinator, supervisor | Strong, but substantially more machinery than the lesson needs to expose. Show one message and one review report; supply the transport. |
| Separate role, harness, provider, model; Pi is required | Profiles, Pi coordinator, real Pi/Claude/Codex round trip | Strong. Everyone edits a role mapping. Same-provider access is a supported outcome. The provider smoke is enough for this chapter; do not repeat the main feature just to prove a profile edit. |
| Narrow host integration through MCP | Real stdio Beans adapter, unmounted backlog, real gateway retrieval | Excellent fit. `get_task` should deliver the main task before implementation starts. Do not teach the server implementation or make participants compile it. |
| Lightweight host orchestration | Working factory CLI with status, export and acceptance | Functionally fits; educationally overgrown. Twelve command handlers plus libraries turn “a few scripts” into another tool to learn. |
| Kits and environment composition | Validated crew and provider kits; real `sbx env create` passed | The declarative environment and `factory run` are different setup paths. The environment includes ACR; the launcher transfers pre-materialized policy and uses its own create flags. Do not teach the env file as controlling the run when it does not. |
| Templates make tools available quickly | Working built-in Docker-enabled image; custom Dockerfile and inventory | Teach the image actually used. A custom prebuilt image is an optimization to justify by measured download/startup time, not a required extra product to finish. |
| Package and distribute skills with ACR | ACR kit installation works; package source and pinned, materialized policy exist | Runtime instructions are real. Package distribution/installation is not yet the same thing: the workshop package is unpublished and launcher policy is copied in. This is a remaining teaching proof if ACR distribution stays a promise. |
| Credential proxy / OAuth | Provider kit port and real proxy-backed requests; mode diagnostics | Teach credential placement and observed mode without exposing tokens. Authentication/account limitations are setup concerns, not a new core exercise. No new auth investigation is needed for this assessment. |
| Host repairs a scoped policy denial | Scenario, host controls, diagnostics and reported access failures | Keep one small deterministic denial and recovery. Avoid downloading Chromium as the core recovery exercise; bandwidth and browser setup distract from the permission boundary. |
| Human joins through SSH and settles a requirement | Real SSH connectivity; decision protocol; real agent ambiguity evidence | Good story. Prefer a labelled prepared paused exercise to waiting for spontaneous disagreement or rebuilding a third major feature. Connect to the same live crew and record the decision. |
| Learner takes home a reusable factory | Real next-task workflow, Git export, acceptance | Strong. End with a reviewed commit and a command for the next task. No scheduler, merge automation or integrated parallel feature teams needed. |
| Last 25 minutes: experimentation, cloud/governance | Separate presenter scripts and extensions | Correct separation. Rehearse presenter demonstrations independently; they must not hold up completion. |
| Static GitHub Pages guide | Technical runbooks and authoring material | Still an authoring/delivery task, intentionally deferred. The current README and manifests are not learner-ready instructions. |

Sources: `planning-brief.md`, `implementation-agent-prompt.md`, the workshop source,
`HOST-VERIFICATION-2.md`, `MULTI-PROVIDER-VERIFICATION.md`, and `REHEARSAL.md`. Existing
reports have different dates and scopes. This assessment uses the later real-host
reports for runtime conclusions, not the older README status table.

## How much complexity is there?

At the reviewed workshop revision there are 243 tracked files and 23,446 lines.
That headline exaggerates runtime complexity: 121 evidence files account for 4,852
lines, tests are substantial, and the cached app dependency lockfile alone is 2,833
lines. Do not delete evidence or tests merely to make a line count look better.

The important teaching surface is still large:

- `factory/factory`: 797 lines; `factory/` with its three libraries: 1,352.
- `handoff`: 496; `crew-run`: 441; `crew-notify`: 104; `crew-start`: 162.
- Actual coordinator/developer/QA role contracts: 393 lines combined.
- Six technical runbooks: 1,738 lines.
- Thirteen scripts: 1,399 lines, including maintainer/distribution tooling.

These are raw source lines, including comments and blank lines. They are not
measurements of necessary complexity or estimates of implementation effort.

## Recommended simplification

### 1. Expose a small assembly; keep the tested support behind it

Give learners these artifacts to understand/edit:

1. One environment recipe: image, kits, ports and MCP binding.
2. One role map: harness/provider/model for three roles.
3. Three short role briefs.
4. One short host launch script showing the actual SBX command and task assignment.
5. One task, one message, one QA result and one acceptance result to inspect.

Target roughly 150–250 lines of learner-facing code/configuration across these
artifacts, excluding supplied policy text and application source. That is a design
budget, not a measured completed reduction. It is easily more than ten times smaller
than asking learners to understand the current orchestration and setup surface.

A helper call is acceptable when its purpose is clear (`transfer the app`, `start
Herdr`, `run fixed checks`). Hiding every SBX command inside a new `workshop` CLI is
not an improvement: the learner should see the technology being taught.

Keep the existing implementation as supplied support while extracting this surface.
Avoid maintaining two independent orchestration implementations. One test-backed
implementation should power both the concise examples and the complete run.

### 2. Reduce the learner command vocabulary

Core actions: **start, inspect, decide when asked, finish**. Use raw SBX/Herdr
inspection commands where they teach a component.

- Fold `factory submit` into starting work. Currently it marks Beans in-progress and
  prints another command; it does not dispatch anything. That distinction teaches
  our CLI rather than SBX.
- Present verification and export as one explicit finish step, with the exact commit
  and check result visible. Internally retain the checks and export verification.
- Leave doctor as a setup diagnostic, not a command learners must learn in detail.
- Keep cleanup, profile validation, releases, signing/checksums and support diagnostics
  available, but off the main chapter path.

This is an interface reduction. Do not claim that a new four-command wrapper has
made 1,352 lines of implementation disappear.

### 3. Narrow actual runtime assumptions before cutting code

For the taught workflow, support one active task per sandbox, one developer writing
at a time, three roles and one working checkout. Do not generalize for concurrent
writers, integrated branches, arbitrary harness types or automatic scheduling.

Good candidates for real deletion in a later simplification pass:

- `FACTORY_MODE=local`: it is a second execution path and conflicts with the central
  workshop rule that generated code runs in SBX. Tests can keep a labelled SBX
  double without exposing a participant local mode.
- Unsupported harness options unrelated to the chosen Claude/Codex/Pi paths.
- Repeated environment selection, transfer and auth explanations across scripts and
  agent prompts; put shared mechanics in one supplied place.
- Multi-attempt automatic correction/recovery as a general framework. A narrow live
  workflow can stop on failure and accept an explicit retry. Keep the happy path's
  QA feedback and one correction, plus the human-decision resume story.
- Checkpoint switching of both entire repositories for every lesson. Pin one workshop
  release and use app fixture tags plus small chapter configs. Use a fresh sandbox
  for recovery instead of switching a learner's in-progress checkout underneath them.
- Presenter-only MCP write functionality in the core adapter. A named read-tool denial
  may be sufficient to teach governance; if mutation remains useful, isolate it as a
  presenter extension rather than requiring the extra concepts in attendee setup.

The host control layer and long role prompts offer better savings than the app.
The transport is a worse first target: its wakeup, duplicate and stale-report handling
address failures we actually encountered. Reducing it from 496 lines to a small fixed
message schema may be possible, but needs a separate measured pass. A plain `echo`
plus blind `herdr agent prompt` would reintroduce known stalls and duplicate prompts.

### 4. Make role instructions small and literal

Target 25–40 lines per role plus one short shared protocol reference, rather than
393 lines of role contracts. Keep only:

- what this role owns and must not edit;
- where the task and inbox are;
- how to send a message and wake another role;
- what a completion/review report must name;
- when to ask the human.

Move exit-code tables, all authentication variants, resume mechanics and examples of
every branch into supplied tooling/reference. Preserve the explicit warning that
harness-native agent messaging does not reach this crew.

The Pi coordinator stays a real agent with a visible role. Simplifying by replacing
it with a host state machine would discard a stated learning goal.

### 5. Make composition and instruction delivery truthful

Choose one canonical composition recipe that the runner actually consumes. If
`sbxenv` is a core learner artifact, wire the run to it; otherwise teach the real
`sbx create` path and show `sbxenv` as packaging after the working run. Do not keep two
silently divergent sources of truth. The new multi-provider base must be represented
in that same explanation, including why OAuth belongs in the sandbox kit.

For ACR, demonstrate one real package installation/materialization and one visible
rule used during review. Either publish the workshop policy package or use an
already-published suitable package. Keep pre-materialized instructions as an explicitly
labelled recovery artifact, not as the demonstration of distribution itself.

### 6. Simplify delivery, not the proof

Choose one workshop release and one tested distribution path. Supply the Beans MCP
binary; do not spend participant time compiling Go, reading 2,035 lines of adapter
code/tests, or navigating release tooling. Keep the two repositories, with one page
explaining which one learners edit and which one supplies the lab.

Teach the built-in template now. Build a custom cached template only if a timed cold
rehearsal shows a useful saving for the actual room. A new large image may trade many
small downloads for one large download rather than reduce startup time.

## Things not to cut

- Real in-sandbox Docker/Postgres and isolated integration tests.
- Real MCP retrieval from the host backlog, without mounting that backlog.
- Pi and role/provider configuration, including the single-provider access fallback.
- File-based task/review evidence independent of Herdr lifecycle status.
- Message IDs, atomic writes, bounded waits, and guarded wakeups needed by real sessions.
- Exact reviewed commit matching the exported and verified candidate.
- Fixed checks outside the candidate repository, executed inside SBX on that commit.
- Visible denial and host-scoped repair; explicit human decision and same-crew attach.
- Transfer verification, no host execution of generated code, and scoped cleanup.

The independent checks are a strong teaching point: actual QA missed a criterion,
and external checks caught it. Keep the deliberately defective candidate as a short,
labelled demonstration. Do not equate passing agent-owned tests with acceptance.

Those checks are protected from ordinary edits in the app clone, not from a malicious
agent with the same VM user as the copied workshop files. The workshop teaches useful
verification discipline; it does not create mutually distrusting agents inside one VM.

## Keep the journey, stop repeating full feature builds

The main task has taken 25 minutes including an ambiguity and a correction. It is not
a reliable 15-minute exercise to repeat at each chapter. Budget **one warm-up and one
main feature**, with short mechanical proofs and a prepared intervention around them.

Recommended refinement of the accepted timing (not a newly approved script):

| Minutes | Learner activity / visible proof |
|---|---|
| 0–10 | Install/sign in, choose entry profile, begin downloads. |
| 10–18 | Prepared result preview and host/sandbox diagram while downloads continue. |
| 18–33 | One worker, board, Postgres, published port; small warm-up change. |
| 33–43 | Assemble same-model roles in Herdr; inspect one real file handoff. |
| 43–53 | Edit role/provider mapping; use the short smoke relay including Pi. |
| 53–65 | Register host Beans MCP, retrieve the actual main task, launch implementation. |
| 65–80 | While it runs, inspect containers, policy/skill input, role terminals and one small scoped denial. |
| 80–95 | Finish/review/refresh the main result; use the prepared paused crew for SSH decision intervention. Recovery fixture if time is tight. |
| 95–108 | Open lab and catch-up; another task only for people ready for it. |
| 108–116 | Presenter governance/cloud extensions. |
| 116–120 | Reviewed result, preserved export, and next-task command. |

This changes ordering slightly so MCP supplies the work before the main build. It
preserves in-session setup and the last 25 minutes. The exact fit still needs a
rehearsal: setup can take 9–22 minutes by the existing estimate, and the final
intervention should be short. A prepared paused crew is a declared teaching fixture,
not a claim of spontaneous model disagreement.

## Priority for the next implementation/authoring pass

1. **Make the final result visible:** explicit preview refresh with migrations and
   browser verification of the accepted feature.
2. **Extract the learner surface:** short role briefs, one role map, small inspectable
   launcher, clear HOST/SANDBOX labels; retain the tested support behind it.
3. **Resolve the two teaching seams:** one composition path and one real ACR
   package-install proof. Verify the actual advertised main-task MCP path with the
   chosen crew configuration.
4. **Freeze one usable release:** ready MCP download, app fixture references, one
   current status page. README still says host launch failed/not rerun and Codex not
   run; checkpoint entries still have unresolved workshop SHAs and `/work` examples.
   These are authoring inputs that must be corrected before becoming chapter commands.
5. **Write progressive chapters and rehearse cold:** every chapter has a learner
   action, a visible result and a short recovery. Retire repeated full-task runs from
   the timed route. Keep evidence/history out of the learner navigation.

Do not start with a broad rewrite of the handoff protocol or MCP server. The fastest
route to a good workshop is to shorten what must be understood, remove redundant
setup paths, and make each learning goal produce one unmistakable visible result.
