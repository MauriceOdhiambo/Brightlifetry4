const CACHE_NAME = 'brightlife-public-portal-v2.4.1-cache';
const APP_SHELL = ['/', '/login', '/portal.html', '/manifest.webmanifest', '/favicon.png', '/favicon.ico', '/app-icon-192.png', '/app-icon-512.png', '/public-reference.css?v=20261117-3', '/public-pages.js?v=20261117-3', '/assets/images/snd-brightlife-mark.png', '/assets/app.css?v=20261117-2', '/assets/app.js?v=20261117-2'];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin || url.pathname.startsWith('/api/')) return;
  if (request.mode === 'navigate') {
    event.respondWith(fetch(request).then(response => {
      if (response.ok) { const copy = response.clone(); caches.open(CACHE_NAME).then(cache => cache.put(request, copy)); }
      return response;
    }).catch(() => caches.match(request).then(hit => hit || (url.pathname === '/login' ? caches.match('/portal.html') : caches.match('/')))));
    return;
  }
  event.respondWith(caches.match(request).then(cached => cached || fetch(request).then(response => {
    if (response.ok) { const copy = response.clone(); caches.open(CACHE_NAME).then(cache => cache.put(request, copy)); }
    return response;
  })));
});
