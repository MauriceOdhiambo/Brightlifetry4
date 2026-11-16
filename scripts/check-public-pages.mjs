import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';

const root = { innerHTML: '', querySelectorAll: () => [], querySelector: () => null };
const classList = { add() {}, remove() {}, toggle() {}, contains: () => false };
const document = {
  title: '',
  getElementById: id => id === 'publicHomeContent' ? root : null,
  querySelectorAll: () => [], querySelector: () => null,
  body: { classList }, documentElement: { classList }, addEventListener() {}
};
const window = { addEventListener() {}, scrollTo() {}, innerWidth: 1280 };
const history = { replaceState() {}, pushState() {} };
const location = { hash: '', pathname: '/', search: '' };
const context = {
  document, window, history, location, URL, console, setTimeout, Date, Promise, String,
  encodeURIComponent,
  fetch: () => Promise.resolve({ ok: true, text: () => Promise.resolve(JSON.stringify({ success: true, items: [] })) })
};
vm.createContext(context);
vm.runInContext(readFileSync(new URL('../public-pages.js', import.meta.url), 'utf8'), context);

const routes = {
  home: 'Building Brighter Communities',
  about: 'About Us',
  projects: 'Our Projects',
  water: 'Water Project',
  governance: 'Governance',
  partner: 'Partner With Us',
  donate: 'Support',
  contact: 'Contact'
};
for (const [route, expected] of Object.entries(routes)) {
  context.window.renderSitemapPage(route, false);
  assert.match(root.innerHTML, /class="sb-header"/, `${route}: header missing`);
  assert.match(root.innerHTML, /class="sb-footer"/, `${route}: footer missing`);
  assert.ok(root.innerHTML.includes(expected), `${route}: expected page content missing`);
  assert.ok(!/Member Login|Register\s*<|Savings & Loan Information/i.test(root.innerHTML), `${route}: member-only content leaked into public page`);
}
const projectKeys = ['education', 'women', 'agriculture', 'community_development', 'poultry', 'bike_skills', 'entrepreneurship', 'community', 'youth', 'financial_literacy', 'other', 'training'];
for (const key of projectKeys) {
  context.window.renderSitemapPage(`project-${key}`, false);
  assert.match(root.innerHTML, /sb-project-detail-layout/, `project-${key}: detail layout missing`);
}
const publicIndex = readFileSync(new URL('../index.html', import.meta.url), 'utf8');
assert.ok(publicIndex.includes('/public-pages.js'), 'public page renderer is not loaded');
assert.ok(!publicIndex.includes('/assets/app.js'), 'private application script must not load on public website');
assert.ok(!/\bMember Login\b|>Register<|Savings & Loan Information/i.test(publicIndex), 'private authentication/member content found in public HTML');
console.log(`Public website checks passed: ${Object.keys(routes).length} main pages and ${projectKeys.length} project-detail routes.`);
