import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { basename, dirname, extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT ?? 3000);
const INBOX_PORT = Number(process.env.INBOX_PORT ?? 9092);
const AGENT = process.env.AGENT_URL ?? 'http://localhost:8080/agent';
const WORKFLOW = process.env.WORKFLOW_URL ?? 'http://localhost:8234/workflow';
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8' };
const inbox = [];

const json = (res, status, body) => {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
};

const readBody = async req => {
  let s = '';
  for await (const c of req) s += c;
  return s;
};

// Plain http.request: no client timeout, so a chat turn may wait minutes on a human gate.
function proxy(req, res, target) {
  const url = new URL(target);
  const headers = {};
  for (const h of ['content-type', 'content-length', 'accept', 'x-user-id', 'x-user-roles']) {
    if (req.headers[h]) headers[h] = req.headers[h];
  }
  const up = http.request(url, { method: req.method, headers }, r => {
    res.writeHead(r.statusCode, { 'content-type': r.headers['content-type'] ?? 'text/plain' });
    r.pipe(res);
  });
  up.on('error', e => json(res, 502, { error: `${url.host} unreachable: ${e.message}` }));
  req.pipe(up);
}

async function health(res) {
  try {
    const r = await fetch(`${WORKFLOW}/runtime`, { signal: AbortSignal.timeout(1500) });
    json(res, 200, { agent: r.ok, runtime: r.ok ? await r.json() : null });
  } catch {
    json(res, 200, { agent: false });
  }
}

async function serveStatic(res, pathname) {
  const file = pathname === '/' ? 'index.html' : basename(pathname);
  try {
    const data = await readFile(join(root, file));
    res.writeHead(200, { 'content-type': TYPES[extname(file)] ?? 'application/octet-stream' });
    res.end(data);
  } catch {
    json(res, 404, { error: 'not found' });
  }
}

http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');
  const p = url.pathname;
  if (p.startsWith('/api/agent/')) return proxy(req, res, `${AGENT}/${p.slice('/api/agent/'.length)}${url.search}`);
  if (p.startsWith('/api/workflow/')) return proxy(req, res, `${WORKFLOW}/${p.slice('/api/workflow/'.length)}${url.search}`);
  if (p === '/api/health') return health(res);
  if (p === '/api/inbox') {
    const user = url.searchParams.get('user');
    return json(res, 200, inbox.filter(n => !user || n.user === user).slice().reverse());
  }
  return serveStatic(res, p);
}).listen(PORT, () => console.log(`Demo UI      http://localhost:${PORT}`));

http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (url.pathname !== '/notifications') return json(res, 404, { error: 'not found' });
  if (req.method === 'POST') {
    const n = JSON.parse(await readBody(req) || '{}');
    inbox.push({ id: inbox.length + 1, user: n.user, title: n.title, body: n.body, at: new Date().toISOString() });
    console.log(`🔔 ${n.user}: ${n.title}`);
    return json(res, 201, { created: true });
  }
  const user = url.searchParams.get('user');
  return json(res, 200, inbox.filter(n => !user || n.user === user).slice().reverse());
}).listen(INBOX_PORT, () => console.log(`Inbox (notifications sink)  http://localhost:${INBOX_PORT}/notifications`));
