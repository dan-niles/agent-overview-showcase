# Durable Claims — demo script

**What this is:** the smallest possible demo of the Ballerina `workflow` module's
`DurableAgent` — one insurance-claims agent, in one package, with no ICP/Thunder/Docker
stack. It is the cut-down sibling of `wf-demo-claims-approval`: same domain and the same
three governance rules, none of the surrounding microservices.

The agent enforces, in its own instructions: a bill is required over **$1000**, a
manager signs off over **$3000**, and every payment is **always** gated on an
accountant. It runs as a durable Temporal workflow — kill the process mid-conversation
and it resumes exactly where it left off, because nothing lives in memory.

## Cast (played from the web UI, one browser tab)

| Column | Plays | Does |
|---|---|---|
| Claimant | alice | Chats with the agent |
| Manager | jane | Approves / requests a bill / rejects |
| Accountant | john | Releases the payment |
| Operations | — | Shows the run's activity timeline as it happens |

There's no login — the UI panel headers already say who's "sitting" at each seat.

## The pitch (say this up front)

> This whole claims case — gather the story, file it, validate it against our rules,
> get a manager's sign-off, get an accountant to release the money — is **one Ballerina
> agent**, described as a system prompt plus a handful of plain functions. The workflow
> engine is what makes it durable: every step is checkpointed, so a crash, a redeploy, or
> a manager who takes three days to approve something all look the same to the code —
> the run just picks up where it left off.

## Act 1 — the happy path with governance

1. Claimant panel → **New conversation**. *Say: this starts a durable Temporal
   workflow — instance ID shown under Operations.*
2. Click **Small claim ($600)**. The agent files it, validates it — under $1000, no
   bill needed, under $3000, no manager needed — and goes straight to the accountant.
   *Say: three rules, no bill and no sign-off required, so it skips both gates.*
3. Accountant panel → **Release payment**. Watch the chat: the agent confirms the
   payout and asks if there's anything else. Say `no thanks` — it says goodbye and
   the run completes. *Say: the agent decides when the conversation is over, same as
   a person would.*

## Act 2 — every gate, in one case

1. **New conversation** → click **Big claim ($4200)**.
2. The agent files the claim, then — over $1000 with no bill — opens the thread for a
   document. Click **📎 Attach receipt**.
3. Over $3000 it raises a **manager sign-off**. Switch attention to the Manager panel:
   the card carries the claim facts. **Approve**.
4. Watch the chat: the agent notifies accountants and reaches for the payment — which
   is **gated**. Manager panel goes quiet; Accountant panel gets the 💸 card.
5. **Release payment**. The chat concludes with the payment reference.
6. Point at the **Operations** panel throughout Act 2 — the activity timeline is
   filling in live: `fileClaim` → `validateClaim` → the manager task → `executePayment`,
   each with its actual input/output. *Say: this is the workflow engine's own record,
   not something the app logged — ask it about a run from a week ago and it answers
   exactly the same way.*

## Act 3 — the durability beat (the one that sells it)

This is the point of the whole exercise — the [workflow
guide](https://ballerina.io/learn/write-a-workflow-with-ballerina/) and the [error &
replay guide](https://ballerina.io/learn/handle-errors-and-replay-failed-activities-in-workflows/)
both come down to this.

1. Start a **Big claim** conversation and get it parked on the manager sign-off
   (Act 2, steps 1–3).
2. **Kill the agent process** (`Ctrl+C` in its terminal, or `bal stop`, or just `kill`
   the PID). *Say: this is a crash, or a redeploy, or a laptop closing — the process is
   simply gone.*
3. Restart it (`bal run target/bin/durable_claims.jar`). Give it a few seconds to
   reconnect to Temporal.
4. Go back to the Manager panel and **Approve** — the task is still sitting there
   exactly as it was; the process restart never touched it, because the task lived in
   Temporal, not in the agent's memory. Finish the case as in Act 2.
   *Say: nothing was replayed by hand, nothing timed out, no state was lost — that's
   the entire pitch for durable workflows over a plain service.*

Optional, if you want the retry story too: unplug the model token (see below) before
step 1, start a conversation, and watch the Operations panel show the `llmChat`
activity retry automatically a few times before the run parks in a `FAILED` state with
the exact error recorded — the [error-handling guide](https://ballerina.io/learn/handle-errors-and-replay-failed-activities-in-workflows/)
in one screenshot. Fix the token, restart, and the same conversation resumes.

## Human tasks and approval gates — the two governance primitives

- **`managerApproval`** is a `humanTasks` entry ([human-task
  guide](https://ballerina.io/learn/write-a-workflow-with-a-human-task/)): the agent
  calls it like a tool, and the run durably suspends until `jane` decides through
  `POST /workflow/human-tasks/{taskId}/complete`.
- **`executePayment`** is a plain activity with `requiresApproval: true, userRoles:
  "ACCOUNTANT"`: every call is gated by a review activity, decided through
  `POST /workflow/review-activities/{taskId}/proceed`.

Both show up in the UI as cards; both are the same REST surface Temporal/Ballerina
expose out of the box — nothing bespoke was built to make this a demo.

---

## Setup — what you actually need

No Docker, no Postgres, no ICP, no Thunder. Three things:

1. **Temporal**, running locally:
   ```bash
   temporal server start-dev
   ```
   (Temporal UI at http://localhost:8233 — handy to have open in a second tab.)

2. **A fresh WSO2 default-model-provider token**, in `Config.toml`. It expires in
   ~1 hour, so generate it right before you demo: VS Code → Ballerina Integrator →
   open this integration → **Default model provider** → generate token → paste the
   `serviceUrl` / `accessToken` into `[ballerina.ai.wso2ProviderConfig]`.

3. **The agent itself**:
   ```bash
   bal run target/bin/durable_claims.jar   # or bal run from the project root
   ```

4. **The demo UI** (Node, no build step):
   ```bash
   cd webapp && node server.mjs
   ```
   Open http://localhost:3000. It serves the page, proxies to the agent (`:8080`) and
   the workflow management API (`:8234`), and stands in for the `notifications` service
   the agent posts bell alerts to.

### What Config.toml already has (added for this demo)

```toml
[ballerina.workflow]
mode = "LOCAL"
taskQueue = "DURABLE_CLAIMS_QUEUE"

[ballerina.workflow.management.rest]
enableManagementApi = true
enableBasicAuth = false
```

`mode = "LOCAL"` is what talks to `temporal server start-dev` on `localhost:7233`
(the module's own default). `management.rest` opens the human-tasks/review-activities
REST API on port 8234 that both the UI and the Temporal UI's task views ride on.

`main.bal` needs `import ballerina/workflow.management.rest as _;` — without it the
two config keys above are "unused" and the API never starts. It also opens its
listener with `timeout = 0`: a chat turn can legitimately block for however long a
human takes to decide, and the default 60s listener timeout would otherwise cut every
long-running turn off with a 500.

### If something looks wrong

| Symptom | Cause |
|---|---|
| Chat reply is `Error while connecting to the model` (visible on the Operations timeline as a `llmChat` failure) | The WSO2 token expired — regenerate it and restart the agent |
| `unused configuration value ...workflow.management.rest...` at startup | The REST import is missing from `main.bal` |
| A chat send hangs the browser tab indefinitely | Expected while a gate is open — that's the reviewer's cue, not a bug |
