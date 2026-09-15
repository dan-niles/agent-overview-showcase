const USER = 'alice';
const ROLES = { manager: { 'x-user-id': 'jane', 'x-user-roles': 'MANAGER' }, accountant: { 'x-user-id': 'john', 'x-user-roles': 'ACCOUNTANT' } };
const KEY = 'durable-claims';
const $ = id => document.getElementById(id);

let state = load();
function load() { try { return JSON.parse(localStorage.getItem(KEY)) ?? { conversationId: null, transcript: [] }; } catch { return { conversationId: null, transcript: [] }; } }
function save() { localStorage.setItem(KEY, JSON.stringify(state)); }

function toast(text) { const t = $('toast'); t.textContent = text; t.classList.add('show'); setTimeout(() => t.classList.remove('show'), 2600); }
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const asList = d => Array.isArray(d) ? d : (d?.items ?? d?.tasks ?? d?.humanTasks ?? d?.reviewActivities ?? []);

async function api(path, { method = 'GET', body, headers = {} } = {}) {
  const res = await fetch(path, { method, headers: { ...(body ? { 'content-type': 'application/json' } : {}), ...headers }, body: body ? JSON.stringify(body) : undefined });
  const text = await res.text();
  let data = text;
  try { data = JSON.parse(text); } catch { /* plain string bodies from the agent service */ }
  if (!res.ok) throw Object.assign(new Error(typeof data === 'string' ? data : data?.error?.message ?? JSON.stringify(data)), { status: res.status });
  return data;
}

// ── Alice: chat ────────────────────────────────────────────────────────────────
function renderChat() {
  const box = $('chat');
  box.innerHTML = state.transcript.map(m => `<div class="msg ${m.who}${m.pending ? ' pending' : ''}">${esc(m.text)}</div>`).join('')
    || '<div class="msg sys">Click “New conversation” to start a claim. The agent runs as a durable workflow from that moment on.</div>';
  box.scrollTop = box.scrollHeight;
  $('runId').textContent = state.conversationId ?? '—';
  $('temporalLink').href = state.conversationId ? `http://localhost:8233/namespaces/default/workflows/${encodeURIComponent(state.conversationId)}` : 'http://localhost:8233';
}

function push(who, text, extra = {}) { const m = { who, text, at: Date.now(), ...extra }; state.transcript.push(m); save(); renderChat(); return m; }

async function newConversation() {
  $('newConv').disabled = true;
  try {
    const id = await api('/api/agent/conversations', { method: 'POST', body: { username: USER } });
    state = { conversationId: String(id), transcript: [] };
    save();
    push('sys', `Conversation started · durable run ${id}`);
    toast('Durable agent started');
  } catch (e) { toast(`Could not start: ${e.message}`); }
  $('newConv').disabled = false;
}

async function send(text) {
  if (!text.trim()) return;
  if (!state.conversationId) { toast('Start a conversation first'); return; }
  push('me', text);
  const pending = push('agent', 'thinking', { pending: true });
  $('send').disabled = true;
  try {
    const reply = await api(`/api/agent/conversations/${encodeURIComponent(state.conversationId)}/messages`, { method: 'POST', body: { message: text } });
    pending.text = typeof reply === 'string' ? reply : JSON.stringify(reply);
  } catch (e) {
    pending.text = e.status === 502
      ? '⚡ The agent process went away while this turn was in flight. Its state is safe in the workflow engine — restart the agent and send another message to catch up.'
      : `⚠ ${e.message}`;
    pending.who = 'sys';
  }
  delete pending.pending;
  save(); renderChat();
  $('send').disabled = false;
}

$('newConv').onclick = newConversation;
$('composer').onsubmit = e => { e.preventDefault(); const v = $('input').value; $('input').value = ''; send(v); };
document.querySelectorAll('.quick [data-say]').forEach(b => b.onclick = () => send(b.dataset.say));
$('attach').onclick = () => send(`Here is my receipt: https://files.example.com/receipts/${Math.random().toString(36).slice(2, 8).toUpperCase()}.pdf`);
$('checkState').onclick = async () => {
  if (!state.conversationId) return;
  try {
    const r = await api(`/api/agent/conversations/${encodeURIComponent(state.conversationId)}/state`);
    $('stateOut').textContent = `Finished: ${r}`;
  } catch (e) { $('stateOut').textContent = e.status === 502 ? 'agent unreachable' : 'still running (AgentBusyError)'; }
};

// ── Jane: human tasks ──────────────────────────────────────────────────────────
const detailCache = new Map();
async function detail(kind, id, headers) {
  if (!detailCache.has(id)) detailCache.set(id, api(`/api/workflow/${kind}/${encodeURIComponent(id)}`, { headers }).catch(() => ({})));
  return detailCache.get(id);
}
const kvRows = obj => Object.entries(obj ?? {}).map(([k, v]) => `<dt>${esc(k)}</dt><dd>${esc(typeof v === 'object' ? JSON.stringify(v) : v)}</dd>`).join('');

async function pollTasks() {
  try {
    const tasks = asList(await api('/api/workflow/human-tasks?status=PENDING', { headers: ROLES.manager }));
    const cards = await Promise.all(tasks.map(async t => {
      const d = await detail('human-tasks', t.taskId, ROLES.manager);
      return `<div class="task" data-id="${esc(t.taskId)}">
        <div class="row"><span class="title">${esc(t.title || t.taskName)}</span><span class="badge">${esc((t.userRoles ?? []).join(', '))}</span></div>
        ${d.description ? `<div class="muted">${esc(d.description)}</div>` : ''}
        <dl>${kvRows(d.taskInput)}</dl>
        <input class="comment" placeholder="Comment for the claimant (optional)">
        <div class="row">
          <button class="ok" data-outcome="APPROVE">Approve</button>
          <button data-outcome="REQUEST_BILL">Request bill</button>
          <button class="bad" data-outcome="REJECT">Reject</button>
        </div></div>`;
    }));
    $('tasks').innerHTML = cards.join('') || '<div class="empty">No sign-offs waiting.</div>';
  } catch (e) { $('tasks').innerHTML = `<div class="empty">${esc(e.message)}</div>`; }
}
$('tasks').onclick = async e => {
  const b = e.target.closest('button[data-outcome]'); if (!b) return;
  const card = b.closest('.task'); const comment = card.querySelector('.comment').value;
  card.querySelectorAll('button').forEach(x => x.disabled = true);
  try {
    await api(`/api/workflow/human-tasks/${encodeURIComponent(card.dataset.id)}/complete`, { method: 'POST', headers: ROLES.manager, body: { result: { outcome: b.dataset.outcome, ...(comment ? { comment } : {}) } } });
    toast(`jane decided: ${b.dataset.outcome}`); pollTasks();
  } catch (err) { toast(err.message); card.querySelectorAll('button').forEach(x => x.disabled = false); }
};

// ── John: approval gates (PRE_RUN review activities) ───────────────────────────
async function pollReviews() {
  try {
    const reviews = asList(await api('/api/workflow/review-activities?status=PENDING', { headers: ROLES.accountant }));
    const cards = await Promise.all(reviews.map(async r => {
      const d = await detail('review-activities', r.taskId, ROLES.accountant);
      return `<div class="task" data-id="${esc(r.taskId)}">
        <div class="row"><span class="title">💸 ${esc(r.title || r.activityName)}</span><span class="badge">${esc(r.trigger ?? 'PRE_RUN')}</span></div>
        <div class="muted">The agent wants to call <b class="mono">${esc((r.activityName ?? '').split('.').pop())}</b> with:</div>
        <dl>${kvRows(d.activityArgs ?? d.input)}</dl>
        <input class="comment" placeholder="Feedback to the agent (used on reject)">
        <div class="row">
          <button class="ok" data-action="proceed">Release payment</button>
          <button class="bad" data-action="reject">Reject</button>
        </div></div>`;
    }));
    $('reviews').innerHTML = cards.join('') || '<div class="empty">No payments waiting for release.</div>';
  } catch (e) { $('reviews').innerHTML = `<div class="empty">${esc(e.message)}</div>`; }
}
$('reviews').onclick = async e => {
  const b = e.target.closest('button[data-action]'); if (!b) return;
  const card = b.closest('.task'); const feedback = card.querySelector('.comment').value;
  card.querySelectorAll('button').forEach(x => x.disabled = true);
  try {
    await api(`/api/workflow/review-activities/${encodeURIComponent(card.dataset.id)}/${b.dataset.action}`, { method: 'POST', headers: ROLES.accountant, body: feedback ? { feedback } : {} });
    toast(`john decided: ${b.dataset.action}`); pollReviews();
  } catch (err) { toast(err.message); card.querySelectorAll('button').forEach(x => x.disabled = false); }
};

// ── Ops: liveness, run timeline, inbox ─────────────────────────────────────────
async function pollHealth() {
  try {
    const h = await api('/api/health');
    $('agentPill').className = `pill ${h.agent ? 'up' : 'down'}`;
    $('agentPill').textContent = h.agent ? 'agent process up' : 'agent process down';
  } catch { $('agentPill').className = 'pill down'; $('agentPill').textContent = 'demo server down'; }
}
const short = v => { const s = typeof v === 'string' ? v : JSON.stringify(v); return s.length > 70 ? s.slice(0, 70) + '…' : s; };
async function pollRun() {
  if (!state.conversationId) return;
  try {
    const w = await api(`/api/workflow/workflows/${encodeURIComponent(state.conversationId)}`, { headers: ROLES.manager });
    $('runStatus').textContent = w.status ?? '—';
    const steps = w.activityInvocations ?? [];
    $('timeline').innerHTML = steps.map(s => `<div class="step ${esc(s.status)}"><span class="dot"></span>
      <span><b>${esc(s.activityName.split('.').pop())}</b>${s.attempt > 1 ? ` <span class="badge">attempt ${s.attempt}</span>` : ''}<br><span class="io">${esc(short(s.input))}</span></span>
      <span class="io">${esc(s.output == null ? s.status : short(s.output))}</span></div>`).join('') || '<div class="empty">No activities yet.</div>';
  } catch (e) { $('runStatus').textContent = e.status === 502 ? 'engine unreachable via agent' : e.message; }
}
async function pollInbox() {
  try {
    const items = await api(`/api/inbox?user=${USER}`);
    $('inboxCount').hidden = items.length === 0; $('inboxCount').textContent = items.length;
    $('inbox').innerHTML = items.map(n => `<div class="notif"><div class="t">${esc(n.title)}</div><div class="b">${esc(n.body)}</div></div>`).join('') || '<div class="empty">Notifications the agent sends land here.</div>';
  } catch { /* demo server down */ }
}

renderChat();
pollHealth(); pollTasks(); pollReviews(); pollRun(); pollInbox();
setInterval(pollHealth, 1500);
setInterval(() => { pollTasks(); pollReviews(); pollRun(); pollInbox(); }, 2500);
