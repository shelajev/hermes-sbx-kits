# Workshop story: from one sandboxed agent to a software factory

Working story proposal, 2026-09-17. Based on the author's latest direction. This
supersedes the ordering proposed in `workshop-assessment.md`; it does not change
implementation or claim that the new intermediate stages already exist. The final
system remains the working factory checkpoint. This is a planning document, not a
validated speaker-toolkit outline or slide script.

## Through-line

We start with an assistant we can let act. We finish with a system we can give work.
Every addition answers a limitation participants have just encountered. Docker
components are the teaching spine; Beans and Herdr are supporting components.

The incident board is present from the first useful coding exercise. It gives us
something visible to change, an API to test, and a database the agent can start inside
SBX. Do not use a different toy application for every infrastructure concept.

## 1. Let one agent work: SBX

**Question:** How can I let a coding assistant run commands without approving each
one or giving it my normal host environment?

Install SBX and authenticate in the session. Give one chosen agent a private app
checkout and run it with the appropriate approval-bypass setting inside SBX.
Explain that relaxing harness prompts does not remove the sandbox boundary.

Learners inspect the filesystem, create a sandbox-local file, and check a deliberately
unmounted host canary is absent. With an actual workspace mount, explain its access
rather than implying all host files are always unreachable. Show one short, controlled
network-policy example if it fits; do not make provider authentication failures the
exercise.

Have the agent start Postgres with the private Docker engine, run a test, and serve
the board. Publish the app port to the host browser. The host has no Docker daemon.
Use the small count-label fix as the first visible change.

**Exit:** one useful worker, an actual running board, and evidence of the boundary.
**Transition:** “It works. But I'm still creating the environment and handing it work.”

## 2. Give the worker a job: Beans, sbxenv and a host launcher

**Question:** Can I start this from a task instead of reconstructing the terminal
session every time?

Show one Bean with a concrete task and acceptance criteria. Beans needs a couple of
commands, not a chapter about issue tracking. A short host script takes that task,
creates the sandbox from the environment recipe, transfers the private checkout and
starts the agent. Initially the host supplies a task snapshot; that is an explicit
limitation MCP will address later.

Teach `sbxenv` as the reusable composition recipe and show the actual SBX CLI calls
used by the script. CLI automation is enough programmatic access; do not invent a
second SDK tutorial. The implementation must consume the recipe we teach, rather
than showing an env file alongside unrelated hardcoded creation flags.

**Exit:** one command can launch a worker for a host-tracked task.
**Transition:** “Now we can dispatch work. But one worker also checks its own work.”

## 3. Add another pair of eyes: Pi, kits and templates

**Question:** Can the environment contain more than the assistant it started with?

Add a Pi tooling mixin to the environment and create the next sandbox with both
harnesses. Start Pi manually and ask it to inspect a small change. Learners see that
installing another agent does not automatically create a team.

Explain the division: the template supplies a prepared filesystem and tools; kits
compose additional setup, credentials and permissions. Teach the template actually
used. A custom workshop image can later cache the same tools; participants do not
need to build that image or install host Docker.

Separate role, harness, provider and model explicitly. Start with supported single-
provider access. Everyone edits the role map; the presenter demonstrates available
cross-provider assignments. Pi remains a required real harness even if Gemini access
is unavailable. The Google/Codex credentials of the multi-provider base are a
composition detail to explain here: OAuth bindings cannot simply be added in a mixin
on the tested SBX build.

**Exit:** two capable assistants in one SBX, still manually coordinated.
**Transition:** “Two terminals aren't a team. I'm still moving messages between them.”

## 4. Make it a team: another kit, Herdr and shared instructions

**Question:** Who starts the roles, hands over the work, and asks for review?

Add the Herdr/team mixin beside the Pi/tooling mixin. These separate stages require
splitting the current combined crew kit. Herdr runs inside SBX and owns agent sessions.
Use a Pi coordinator, a developer and QA. Shared files carry messages and reports;
Herdr delivers prompts and lets us inspect terminals. Explain that writing a file
alone does not wake the recipient.

Use the short, real handoff relay to prove all roles can communicate. Then inspect one
assignment and one review report. Keep the underlying transport supplied; learners
should not implement message deduplication or a state machine during the workshop.

**Shared instructions belong here.** “They also need the same definition of good
work.” Add the ACR capability, install one versioned policy package, and inspect the
instructions the agents receive. A visible review finding can reference that policy.
This preserves the original skill-distribution lesson without making another long
chapter. Installing the ACR CLI alone is not the package-distribution proof.

**Exit:** a real team whose roles, models and shared instructions are inspectable.
**Transition:** “The team can work, but its task knowledge is still a copy I put inside.”

## 5. Connect the factory to its backlog: MCP and controls together

**Question:** How can agents read the current task and report back without mounting
our host control directory into their VM?

Register the supplied host stdio Beans MCP adapter with SBX and expose it through the
sandbox gateway to a capable role. Claude can hold MCP access and relay the task to
Pi; Pi does not need its own MCP client. The host sends the task ID. The agent calls
`get_task`, obtains the actual contract and shares it with the team. Start the main
assignment/resolution feature using that contract.

Then demonstrate a narrow write: post a progress/result note to that same workshop
backlog. Core tool vocabulary can be just `get_task` and `add_task_note`; `list_tasks`
is convenient but not necessary. Do not add Jira, Linear, MCP OAuth, arbitrary host
filesystem tools or a generic shell command tool.

The existing adapter's note tool is currently presenter-only and restricted to
marked disposable backlogs. Making it an attendee exercise is an explicit small
implementation change: initialize a dedicated workshop backlog, scope writes there,
and update the tool's description/registration. Do not claim the current read-only
path already lets agents close tasks.

**Teach the authority boundary at the moment it changes:**

- Reads retrieve task data; writes change host state.
- The adapter exposes specific operations against its configured backlog.
- A note that says “finished” is an agent report, not an accepted implementation.
- The host checks the exact candidate and then marks the Bean complete.

This supplies real host integration without requiring an unrestricted `complete_task`
operation. If direct MCP completion is later wanted, it should request verified
completion through the host, not simply let the caller assert success.

Local attendees use the deliberately narrow server surface and sandbox access
controls. Organization-level named-tool policy and audit remain a presenter
extension: demonstrate a denied write and an allowed read on disposable data, where
supported and rehearsed. Do not imply an ungoverned attendee has organization policy.
A compact preview can happen now; the longer governance demo can stay in the final
presenter slot.

**Exit:** the team receives real work and sends real results across a controlled bridge.
**Transition:** “Now it can act and report back. But sometimes the missing input is ours.”

## 6. Give the human a way in: SSH

**Question:** What happens when developer and QA disagree about the requirement?

Show a concrete ambiguity and a coordinator that asks instead of deciding product
behavior. SSH into that same sandbox, inspect Herdr sessions and the decision request,
record a decision, and resume the work. Neither restart the team nor manually rewrite
the feature on the host.

Use the existing reopen-note exercise or a clearly labelled prepared paused state.
The story does not depend on agents spontaneously producing the disagreement during
the allotted minutes. Keep this separate from a network denial: host policy fixes
access; a human decision supplies a requirement.

**Exit:** the factory has a human decision path as well as automation.
**Transition:** “We can give it work, inspect it, constrain it and intervene. Let's finish a job.”

## 7. Finish a job, then keep using it

QA names the implementation commit. The fixed checks run against that commit inside
SBX. The host records acceptance, updates Beans, and preserves the exported change.
Refresh/restart the running preview with migrations so the browser shows the accepted
feature. That visible result is the final proof of the factory.

Give learners a next-task command and time to experiment. The presenter uses the
remaining slot to extend the same architecture to organizational governance and cloud
placement, clearly separated from attendee completion.

## Working time budget

This is a rehearsal target, not a measured schedule. Keep installation in-session and
protect the final 25 minutes. Start downloads while introducing the goal and diagram.

| Minutes | Stage |
|---|---|
| 0–10 | Install, authenticate, orientation, downloads |
| 10–25 | One agent in SBX; isolation, containers, board port, warm-up |
| 25–40 | Beans plus short host launcher consuming sbxenv |
| 40–52 | Pi mixin, template explanation, role/provider mapping |
| 52–67 | Herdr mixin, real handoff, shared ACR instructions |
| 67–82 | MCP task retrieval/write-back and immediate control explanation; main feature runs |
| 82–95 | SSH intervention, inspect/verify results; finish may continue into open lab |
| 95–108 | Open lab, catch-up, main-feature completion |
| 108–116 | Presenter governance/cloud extensions |
| 116–120 | Final artifact and next-task command |

Use one warm-up and one substantive feature, not a fresh feature for every stage.
The real main task can take 15–25 minutes; run it across chapter boundaries and use
its work time for inspection and the intervention demonstration. Prepared states are
recovery/teaching fixtures and must be labelled. Rehearsal may need to trim the main
feature rather than consume all experimentation time.

## Implementation handoff implied by this story

Preserve the final tested system. Produce intermediate assemblies:

1. One agent; app/environment proof.
2. One-agent environment driven by a small host task launcher.
3. Same environment plus Pi tooling kit; manual review.
4. Plus Herdr/team kit, role map and ACR instructions; real coordination.
5. Plus host Beans MCP; real task retrieval and restricted result note.
6. Same team with a recorded human decision and an accepted, visible result.

Do not expose the complete factory CLI in stage one. Do not rewrite the tested
transport to make chapter code look small. The environment, kit addition, role mapping
or host connection is the learner-owned change in each stage. Each stage needs one
command to verify it and a recovery path that preserves their prior work.
