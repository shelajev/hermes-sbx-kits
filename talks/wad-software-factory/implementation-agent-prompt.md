# Implementation agent handoff: WeAreDevelopers software factory

You are implementing the runnable system and intermediate checkpoints for a two-hour workshop. Build and verify the system; return evidence that a separate authoring pass can turn into polished instructions. Do not stop at a plan or a skeleton. Do not use sub-agents. The workshop's agent processes are part of the software under test, distinct from delegating this implementation task.

Read the adjacent `planning-brief.md` and `mcp-research.md` first. They record the approved direction, timing, source references, and local reuse paths. The approved decisions in this prompt, including the two-repository layout and prebuilt MCP distribution, refine the brief. This prompt defines execution order and deliverables. Follow applicable repository instructions. Preserve existing work.

## Outcome and constraints

Build a real local software factory around Docker Sandboxes (`sbx`): lightweight host launch/status/collection scripts and Beans backlog; Herdr server and agent roles inside SBX; an incident-triage board with browser UI, API, and a Postgres container; real integration tests and an exported reviewed change.

- No Docker Desktop, host Docker Engine/socket, Labspace, ttyd, simulated agent output, or required cloud infrastructure on the attendee path.
- Containers run on the private Docker daemon inside SBX. Show a real database and disposable test dependencies. Prefer Testcontainers if it works reliably in the selected stack.
- Instructions eventually live on GitHub Pages. For now build the technology and exact technical setup/run/recovery documentation only. Do not build a website, scaffold a lesson site, write polished learner chapters, or create slides. A separate authoring pass will use the verified technical records.
- Setup, downloads, and authentication happen during the session. Measure cold start. Use prebuilt, pinned template artifacts rather than compiling tools on attendees' machines.
- Start with separate coordinator/developer/QA sessions using one model/provider. Everyone then configures roles independently from harness/provider/model. The mixed-provider design is required. Running all roles on one available provider is a supported access fallback, not a skipped chapter.
- Include Claude Code, Codex, and Pi (https://pi.dev). Pi must perform a real role and participate in visible handoffs. Presenter target: Pi with Google Gemini as coordinator, Claude Code developer, Codex QA. Verify Pi with at least one non-Google provider for participants. Do not assume another CLI's subscription or OAuth credentials work in Pi.
- Use Herdr for agent sessions, startup, prompt delivery, inspection, and human attachment inside SBX. Pi invokes the Herdr CLI like the other harnesses. Shared files are also an authorized communication channel for task messages, questions, review findings, decisions, and completion reports. The author reports buggy Codex status detection: do not make Herdr lifecycle status the sole handoff trigger or completion gate. Bounded file polling is allowed. Use a small structured protocol with task/attempt IDs, sender, message identity, and output commit where relevant; atomic writes and consumed-message tracking must prevent partial reads, stale completions, and duplicate handoffs. A current valid report can advance the workflow despite incorrect Herdr status. Inspect an ambiguous session before submitting another prompt; do not blindly type into a potentially busy agent. Do not add another broker or direct Pi RPC orchestration. It has no built-in MCP support according to its current documentation: do not invent native support. Demonstrate the SBX gateway through a verified client, and add a Pi extension only if the chosen design actually needs one.
- Use https://github.com/shelajev/acr-sbx-kit for coding-policy/skill distribution. Pin the actual package source/revision and verify instructions reach every required harness, including Pi. State explicitly how any Pi materialization adapter works.
- Keep the host scripts small. The sandbox coordinator routes work, bounds correction loops, and escalates ambiguity; it does not judge unresolved product requirements or waive failing checks.
- Preserve host authority over permissions. No self-granted policy changes, host shell execution sourced from agent prose, or automatic merging into main.

Create two separate Git repositories in sibling directories: `wad-factory-workshop` for the factory technology, host Beans/MCP integration, distributions, and technical runbooks; `incident-triage-board` for the actual application and its starter/solution fixtures. The detailed ownership and layout contract appears below. Keep the workshop control directory outside every sandbox-writable mount; clone only the app repository into each task sandbox. Inspect for existing targets before creation and preserve user edits. Do not rewrite this planning repository or the existing Herdr checkout.

Build real release artifacts for the MCP adapter and sandbox template, with versioned installation paths. Prefer downloadable MCP binaries attached to releases of the workshop repository; no third repository is needed. Public hosting is an explicit delivery step, not an imaginary URL: use the owner's confirmed remote/release destination if provided, otherwise finish local artifacts, checksums, release automation, and report exactly which destination is needed. Do not claim unpublished assets are downloadable. Do not change organization policy or unrelated resources.

## Milestone 1: prove the hardest integration first

Inspect the installed SBX version and the existing Herdr crew kit and scripts named in the planning brief. Their existence is not evidence of a working end-to-end integration. In particular, the old task driver disallows same-model developer/QA assignments and its kit requires Gemini; do not carry these constraints into the participant fallback.

Choose the smallest app stack you can reliably test. TypeScript UI/API plus Postgres and Node Testcontainers is a reasonable starting hypothesis, not a mandatory stack. Record the decision once and move on.

Produce one real run that:

1. Creates a standalone local SBX environment and starts headless Herdr.
2. Authenticates a chosen provider without exposing real credentials in logs or exported artifacts.
3. Starts the incident board and an in-SBX Postgres container.
4. Publishes only the app port to the host browser and verifies actual UI/API behavior.
5. Sends a small feature to developer and QA sessions, runs fixed acceptance checks, and exports the resulting commit or patch.
6. Starts Pi, delivers a message through Herdr, and observes a real reply/handoff. Prove the intended presenter mapping and an advertised single-provider profile as early as credentials permit.

Report a short milestone result with versions, exact commands, observed failures, and evidence paths. Continue to subsequent milestones without a routine approval pause. If a real credential/platform limitation blocks one test, request that specific missing input, mark the test unverified, and continue independent work. Never call a mocked provider run an end-to-end pass.

## Milestone 2: finish the factory and teaching scenarios

Implement the feature and requirements in the planning brief: assignment, resolution note validation at the API, persistent state/history, existing filter behavior, and executable API/browser checks. Keep the app small. Deliver a seeded starter and a separately labelled faulty candidate that validates only in the UI.

Create explicit role configuration separating role, harness, provider, model, and authentication reference. Include same-model starting profiles, the mixed-provider presenter profile, and one-provider mappings. Expose unsupported combinations through clear diagnostics rather than assuming universal compatibility.

Host scripts launch, inspect, attach, collect, and clean up scoped runs. Record task ID, sandbox, base/output commit, role mapping, stage, evidence paths, and decision requests. Beans owns the host backlog. Herdr readiness is not task completion: require checks and QA review of the exact output commit, followed by human acceptance. Handle uncertain prompt delivery without blind resubmission.

Implement two distinct intervention scenarios:

- **Host access repair:** reproducible harmless network denial, attributable policy evidence, a scoped host-side repair, and resumed work. Show the SBX terminal UI if the pinned release supports the necessary interaction. Distinguish network denial from a missing workspace file. Do not broaden unrelated policy or expose the host filesystem to make the scenario pass.
- **Human product decision through SSH:** developer and QA disagree about reopening a resolved incident. The coordinator reports both positions and marks `needs-human`. The participant SSH-attaches to the same live Herdr crew, delivers the decision to the coordinator through Herdr, and the coordinator records it and resumes the team through Herdr. The implementation and tests reflect the decision. Supply the ambiguity as an explicit exercise input if necessary; do not depend on a model spontaneously arguing or fabricate a conversation.

Implement the host-local stdio Beans MCP adapter described in `mcp-research.md`, replacing the earlier reference-service proposal. Expose read-only `get_task(id)` and `list_tasks()` over the actual host backlog. Register via `sbx mcp add --command` and attach through the SBX gateway; do not use OCI `--local --url`, which requires host Docker. No MCP OAuth or public endpoint. Use fixed workshop data paths and validated CLI arguments. Prove an actual task read by a sandboxed agent, including on an account without active governance, with the backlog unmounted. Keep host task acceptance separate. Explicitly configure gateway access for the relevant custom-crew agent; Pi can receive retrieved task data through Herdr/files. Prove governance by named tool allow/deny; do not assume policy inspects arbitrary task-ID arguments. Keep presenter central-governance and cloud profiles independent from participant success. Cloud must have its own workspace/credential/export setup; do not assume local flags and credentials transfer automatically.

## Milestone 3: runnable intermediate states

Prepare these immutable local checkpoint commits/tags, with publication left to the release step:

| Checkpoint | Required behavior |
|---|---|
| `00-setup` | Supported-OS installation path, provider choice, diagnostic command |
| `01-worker-and-containers` | Board, in-SBX database, published UI, passing warm-up test |
| `02-same-model-team` | Separate roles and real Herdr handoffs using one model |
| `03-mixed-model-team` | Required role/harness/provider/model configuration, Pi, mixed presenter profile, access fallback |
| `04-host-controls` | Small host scripts, Beans visibility, blocked operation, MCP reference |
| `05-human-intervention` | Structured decision request, SSH attach, recorded answer, resume |
| `06-complete` | Reusable factory, acceptance evidence, export, next task, scoped cleanup |

For each checkpoint provide: prerequisites; start commit; exact HOST and SANDBOX commands; the small participant-owned edit/action; expected observable result; verifier; safe recovery; and measured duration. Preserve learner changes before moving checkpoints. A completed app checkpoint cannot replace a live working provider or virtualization setup.

## Verification contract

Build tests and capture evidence as you implement, not after the entire system is built. The detailed test/evidence matrix below supplements these minimum cases. Report each case as PASS, FAIL, or NOT RUN with environment and evidence path. Minimum cases:

- Clean attendee host with no Desktop or host Engine; supported OS/CPU matrix. A machine with Desktop merely stopped is not proof of a clean installation path.
- Cold/warm downloads, authentication, first sandbox, and first successful feature timings.
- Same-model role sessions; required mixed-provider presenter run including Pi/Gemini; Pi non-Google access path; advertised API-key/OAuth modes.
- Real Postgres persistence; separate ephemeral integration-test database; cleanup and port isolation.
- Valid feature accepted; seeded API defect rejected; QA findings applied and retested against the final SHA.
- Missing auth/quota, blocked network, unavailable file, unknown/blocked agent status, timeout, interruption/resume, repeated launch, and decision escalation. Specifically test a completed Codex turn with stale Herdr status: the file report must permit progress without duplicate prompts. Also test stale/partial/duplicate file reports and a completion claim without passing acceptance evidence.
- SSH reattachment preserves work and the answer resolves the recorded requirement.
- Export can be inspected and verified from a fresh checkout/environment; cleanup preserves unrelated sandboxes and host work.
- ACR-loaded instructions across required harnesses; actual MCP invocation; template/kit/model version inventory.
- Presenter governance/cloud tests separately, with NOT RUN if organizational access is unavailable. No organization changes without explicit authorization.

Test non-AI orchestration logic deterministically where appropriate, but label test doubles. Integration runs with actual model calls supply the workshop proof. Do not claim untested platforms work.

## Return package for the narrative/instructions pass

Deliver both repositories, built distribution assets, the paired checkpoint manifest, and these records in the workshop repository:

1. `IMPLEMENTATION-REPORT.md`: what works, exact run commands, architecture changes, remaining limitations, and artifact paths.
2. `COMPATIBILITY.md`: pinned CLI/kit/template/harness versions, supported OS/CPU/auth combinations, PASS/FAIL/NOT RUN evidence.
3. `TEST-REPORT.md`: test cases and sanitized output locations, including real model integration runs.
4. `CHECKPOINTS.md`: chapter-to-commit mapping and commands/results/recovery for each stage.
5. `REHEARSAL.md`: measured setup and exercise times, model usage/cost when available, likely room bottlenecks, and cuts that preserve the required Pi/configuration chapter.
6. `AUTHORING-HANDOFF.md`: one page per chapter listing what the learner does, what they should observe, why it matters, the exact tested command source, and screenshot/recording candidates. Include every deviation from the approved brief.

The return package should let the author write accurate instructions without reverse-engineering the code. Do not present polished prose, a nice website, or green unit tests as a substitute for a functioning factory. The milestone is complete only when the real run and its limitations are documented honestly.

## Detailed build contract: two repositories

Choose a parent directory appropriate to the user's workspace. These names are proposed local names, not claims that GitHub repositories already exist.

```text
<parent>/
  wad-factory-workshop/             # REPOSITORY A: host control and distributions
    README.md                      # technical quick start and support status
    AGENTS.md                      # maintenance boundaries for this repository
    factory/                       # small host CLI/scripts and schemas
    profiles/                      # same-model and mixed-provider assignments
    environments/                  # local SBX environment definitions
    kits/                          # crew integration and ACR composition
    template/                      # Dockerfile/build definition, pinned tool inventory
    roles/                         # coordinator, developer, QA prompt contracts
    mcp/beans/                     # MCP adapter source, protocol tests, build packaging
    backlog/                       # seed task definitions, not a second app source tree
    acceptance/                    # fixed workshop checks/expected outcomes
    checkpoints/manifest.json      # pairs workshop and app revisions
    scripts/                       # bootstrap, distribution, preflight and release helpers
    technical/                     # tested setup/run/reset/troubleshooting records
    presenter/                     # isolated governance and cloud extension definitions
    evidence/                      # sanitized small reports; large recordings external
    .github/workflows/             # CI and distribution build/release automation
    .local/                        # ignored runtime control: Beans, run manifests, binaries
  incident-triage-board/            # REPOSITORY B: app that the factory changes
    README.md                      # app development/test commands inside SBX
    AGENTS.md                      # app coding instructions, not factory host control
    agents.yaml                    # ACR packages for application work
    src/                           # UI and API; actual layout follows stack choice
    db/                            # schema/migrations and deterministic fictional seed
    tests/                         # app-owned unit/API/integration/browser tests
    scripts/                       # dev database/start/test helpers for INSIDE SBX
    <dependency manifest + lockfile>
```

Treat this as an ownership map, not a requirement to create empty directories. Use a simpler layout if equivalent responsibilities remain explicit. Runtime Beans data belongs to the workshop's ignored host control directory, initialized from seed tasks. It is never the app clone's `.beans` directory. The MCP server reads that exact host backlog, not another JSON copy of it.

The app repository must be usable without the factory: its documented commands run the app and tests in a suitable environment. The workshop repository orchestrates clones pinned to app commits; do not duplicate the app source into it, hide it in an archive, or require a third source repository. Keep personal credentials, host absolute paths, generated run state, and model transcripts out of committed fixtures.

Every checkpoint pairs a workshop revision with an app revision plus a named profile, template digest, adapter version/checksum, seed version, and verifier. Plain `git checkout step-03` in one repo is insufficient when the other repo has changed. Provide a small resolver/doctor that validates the pair and reports a mismatch clearly.

## Required stories and observable proofs

These are implementation stories, not polished workshop prose. Preserve the accepted timeline in the brief.

### Story 1: I can give an agent a complete development environment

Host setup installs or locates SBX, logs in interactively, selects a provider, downloads the published workshop assets, initializes the host backlog, and creates a task sandbox. The app is cloned at a fixed starter revision. The agent starts the database container and app and runs a small task. A host browser reaches the board through the explicit SBX port mapping.

Proof: UI screenshot, actual DB container in the sandbox daemon, tests against that DB, app response through the mapped port, and evidence that no host Docker socket/runtime was used. Do not claim the agent can access everything: demonstrate it can install and run the tools the task needs within granted access.

### Story 2: The factory can read the real host backlog through a narrow tool

The host selects an assigned Bean and sends only its ID and necessary execution metadata to the crew. A gateway-enabled coding role invokes `get_task` through SBX MCP and obtains the task body and acceptance criteria. The crew records the retrieved version/hash and performs the work. Host-side changes are visible on a subsequent MCP read.

Proof: matching host Bean ID/content and sanitized tool-call output; no direct `.beans` mount in the VM; no hidden prompt that already contains the full task and makes the MCP call decorative. For the earlier pre-MCP checkpoint, a direct task snapshot is acceptable; the gateway checkpoint must actually depend on retrieval. If the task changes during execution, report the version change and deliberately refresh/replan; do not silently overwrite the accepted contract.

### Story 3: Roles are explicit before models are varied

Start coordinator, developer, and QA as separate same-model sessions. Show one task passing from implementation to QA, and one labelled defective candidate failing verification. The coordinator delegates work and handles the return; it does not implement everything itself. Herdr controls sessions; structured files support communication and reliable completion observation when Codex status is wrong.

Proof: role assignments, separate session identities, delivered prompts/messages, implementation commit, QA result tied to that commit, and verifier output. Agent-reported PASS alone is insufficient.

### Story 4: A role does not imply a particular harness or provider

Everyone edits or selects the role/harness/provider/model mapping. The presenter executes Pi/Gemini coordinator + Claude Code developer + Codex QA. Participants with only one provider map the same role contracts to supported models they can access. Include Pi as a real open-source participant in the workflow, not an installed binary shown only with `--version`.

Proof: real Pi task routing or messaging, plus mixed-provider and fallback run evidence. List authentication capabilities separately by harness/provider. Do not imply a Claude subscription necessarily authenticates Pi, or that a Pi-only configuration can use MCP without a verified adapter. Deliver a fully tested default attendee path with a gateway-enabled harness and document any narrower Pi-only support honestly.

### Story 5: The host can repair an access problem without taking over the work

A supplied probe or small task encounters a sandbox-scoped denied endpoint. The host inspects the cause, grants only the intended access where local policy permits, and the crew continues. An inaccessible outside file is a separate workspace demonstration, not an excuse to allow the entire home directory. The SBX terminal UI may provide the visible inspection surface if verified on the pinned build.

Proof: before/after request outcomes and effective policy evidence, preserved session/work, and no unrelated policy changes. A global allow rule is not an acceptable shortcut.

### Story 6: A human can settle a decision inside the live team

Use the reopening ambiguity in the planning brief. The coordinator records developer/QA positions, identifies the exact unresolved requirement, and reports `needs-human`. SSH attaches the participant to the same live Herdr crew. The human supplies a decision, recorded as an artifact, and the team resumes and adds corresponding tests.

Proof: decision request, attachment to the existing session, decision artifact, resulting code/test change. Do not rely on models spontaneously producing a disagreement; the exercise can explicitly introduce one.

### Story 7: I can keep using this after the workshop

Export the resulting app commit/bundle/patch, verify it against the expected base, and submit a different small Bean through the same factory. The second run gets its own identity and preserves the first run's evidence. Stop/remove only this run's resources after collection.

Proof: fresh-checkout verification of exported code, a second genuine task, and safe scoped cleanup. Published assets plus both source repositories must be sufficient to reproduce the setup without the presenter's laptop paths.

## Incident-triage application contract

Deliver a small finished-looking, readable UI, not a scaffold placeholder. Use fictional incidents and services. No incident-response automation, production service access, email, SaaS login, or application AI feature is required.

The **starter** already launches, displays a seeded incident list/detail view, filters by severity/status, and persists data in Postgres. It has a working test harness. It deliberately lacks the feature the team will implement. The warm-up changes the active-filter count text with correct singular/plural behavior.

The **main feature** adds assignee selection, resolving with a required non-whitespace note, and visible durable history. Define exact API payloads/status codes and deterministic acceptance criteria in the Bean. Validate on the server; page refresh must retain state. Specify retry/idempotency behavior so a repeated resolution request does not accidentally duplicate history. Keep the scope small enough to rehearse in the allocated time.

The **intervention feature** reopens a resolved incident. Its unresolved note-handling behavior is an explicit exercise input; record the human-selected rule and test that result. Do not make the core solution depend on an unstated interpretation.

Provide starter, known-good solution, and known-defective fixture as clearly labelled app commits/tags. Do not leave the solution accessible in the agent workspace as an instruction to copy it and then call that a live implementation. Recovery may use the solution, but its provenance must remain explicit.

Application tests use the sandbox daemon. Prefer Testcontainers-managed Postgres with dynamic internal ports, readiness checks, isolated data, and cleanup. Never use the participant's host database. The long-running app database and disposable test databases must not share state. Pin images by version/digest as appropriate. Keep the database private to the sandbox; only the UI/API port is published to the host. Handle a busy host app port and show the actual chosen URL.

## MCP adapter contract and prebuilt distribution

Implement a real MCP stdio server using a maintained SDK where practical. The source lives in repository A. Prefer a standalone executable distribution to avoid adding Node/Python/package-manager setup on attendee hosts. Go is a reasonable packaging choice; another language is acceptable if the delivered executable/runtime bundle has comparable installation simplicity. Do not require attendees to compile the server or run unpinned `npx` downloads.

Required tool contract:

- `get_task(id: string)`: return ID, title, body/acceptance criteria, status, available dependency information, and a content version/hash or etag. Validate ID syntax and resolve only from the configured workshop backlog.
- `list_tasks(...)`: return a bounded list of workshop tasks with a small explicit filter vocabulary. Avoid unlimited output and unrestricted query execution.

Use the pinned Beans CLI's machine-readable output. Resolve the Beans executable and config/data paths explicitly at registration/startup; never let upward config discovery select the user's unrelated backlog. Invoke subprocesses with argument arrays, fixed subcommands, timeouts, and bounded output. Reject malformed IDs and input outside the tool schema. No shell strings, generic command tool, arbitrary file reads, generic GraphQL mutation endpoint, task deletion, or task acceptance tool.

The adapter is read-only by default even for attendees with no governance. A presenter-only write demonstration, if implemented, is explicitly enabled against disposable data and must not be required by core tools. Do not use read-only annotations as the only enforcement of this distinction.

Implement normal MCP initialization, capability negotiation, tool listing/calling, useful typed errors, clean shutdown, and multiple reads reflecting current host state. Keep stdout exclusively for protocol traffic; put diagnostics on stderr. Test independent server processes against the same read-only backlog. Do not invent whether SBX launches one process per sandbox or reuses it; verify lifecycle behavior and avoid relying on a singleton.

Produce release assets for the host OS/architectures actually supported by the chosen SBX release. At minimum investigate macOS arm64, Linux amd64/arm64, and Windows amd64. Compile-only is not runtime verification; mark untested targets accordingly. Package the adapter, license notices, version metadata, and checksums. Beans remains a separately pinned host dependency unless redistribution is deliberately supported and its license/install behavior verified.

Preferred destination: versioned GitHub Release assets in repository A. Provide CI/build automation, a release manifest, checksums, and an installer that detects OS/architecture, downloads the exact version, verifies the checksum, and installs into a workshop-scoped directory. Support an explicit local-artifact override for pre-publication tests. Do not require root solely to install the adapter.

Release assets must exist before attendee setup is described as ready. If the destination is not confirmed or upload cannot be performed, deliver locally built assets and an exact remaining publication step; mark remote bootstrap NOT READY. A workflow YAML and hypothetical URL do not satisfy the prebuilt requirement.

Registration setup resolves absolute executable/data paths and uses `sbx mcp add --command`, followed by explicit static attachment or `sbx mcp load`. Use a workshop-specific registration name, detect name collisions, and do not overwrite unrelated registrations. A rerun should recognize the same definition; changed definitions should be reported and reconciled deliberately. `--dir` is only working-directory selection, not sandboxing. No OAuth credentials, HTTP listener, host container, or public endpoint are needed for the adapter.

The custom crew integration must connect each relevant MCP-enabled harness to the sandbox's gateway. Reading host Beans with a direct `beans` process inside the VM, mounting `.beans`, or configuring a direct agent-local server bypasses the required demonstration and does not count as success.

## Technical setup and recovery documentation required now

Write exact operational documents based on the implementation. This is necessary setup documentation, not the future narrative workshop guide.

| Document | Required contents |
|---|---|
| `technical/HOST-SETUP.md` | Supported OS/virtualization, Git, standalone SBX, Docker login, pinned Beans and adapter install, provider selection/auth, first diagnostic run; no host Engine/Desktop installation |
| `technical/SANDBOX-SETUP.md` | Template/kit/env composition, prebuilt artifact references, ACR resolution, gateway client setup, agent startup, DB/app/test commands, ports |
| `technical/MCP-SETUP.md` | Install/download verification, fixed backlog binding, registration, attachment, actual `get_task` test, no-governance path, missing-tool/config diagnosis, scoped removal |
| `technical/RUN-AND-RECOVER.md` | Task launch/status/SSH/decision/resume/collect/accept/clean, file-report fallback, model quota/auth problems, denied access, stale sessions, preserved work |
| `technical/MAINTAINER-RELEASE.md` | Build both CPU template variants, build MCP assets, checksums, CI, publishing destinations, version manifest update and clean-host smoke test |

Every command block says HOST or SANDBOX, specifies its working directory, names prerequisites, and shows the expected observable outcome. Separate instructions by supported shell where syntax differs. Do not embed secrets in command lines or sample files. Distinguish installed tooling, configured credentials, and verified successful model requests.

Provide a machine-readable `doctor` report with actionable errors and a human summary. It should check versions, virtualization readiness where observable, artifact availability, profile/auth compatibility, Beans config, adapter execution, registration/attachment, image architecture, and port conflicts without exposing secrets. Offer scoped remediation; do not reset all SBX policy/settings or delete all sandboxes.

## Evidence, release, and completion checklist

Return a single summary pointing to both repositories, their revisions, checkpoint-pair manifest, all built assets, published URLs if any, and every operational document. Include the exact command to reproduce the first run from a clean supported host.

For each story, link evidence to the tested revision and environment. Separate scripted/fake-provider contract tests from actual provider runs. Include actual gateway tool-call evidence for the host integration; adapter unit tests alone are insufficient. A task's own status report is not independent test evidence.

Fixed workshop acceptance checks should come from the trusted workshop revision and run against the candidate in an isolated verification environment. Do not execute arbitrary generated code directly on the host. If the candidate changes app tests, the external checks still exercise the promised API/UI behavior. Preserve failing and passing results with their commit IDs.

Demonstrate lifecycle recovery with bounded attempts. A timeout must not lead to an infinite retry or a second agent writing concurrently to the same clone. File messages need task/run/attempt identity and atomic writes; separate transport acknowledgment from task completion. Test stale Codex status without pretending that every `working` status is stale.

Deliver a concise list of remaining human-only actions, such as interactive login, an unavailable test machine, confirmation of a release destination, or organization access. Continue all independent implementation work while those are pending. Report limitations honestly, and do not broaden the project into a generic agent platform to avoid a specific integration problem.
