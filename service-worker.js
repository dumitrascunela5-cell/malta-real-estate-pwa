// VERSION 2 - Update this number each time you deploy!
const CACHE_VERSION = 'malta-real-estate-v2';
const urlsToCache = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  'https://unpkg.com/react@18/umd/react.production.min.js',
  'https://unpkg.com/react-dom@18/umd/react-dom.production.min.js',
  'https://unpkg.com/@babel/standalone/babel.min.js',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
  'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css',
  'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'
];

// Install event - cache static assets
self.addEventListener('install', event => {
  console.log('[SW] Installing new version:', CACHE_VERSION);
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then(cache => {
        console.log('[SW] Cache opened');
        return cache.addAll(urlsToCache);
      })
  );
  // Force immediate activation
  self.skipWaiting();
});

// Activate event - clean up old caches and take control immediately
self.addEventListener('activate', event => {
  console.log('[SW] Activating new version:', CACHE_VERSION);
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_VERSION) {
            console.log('[SW] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  // Take control of all clients immediately
  self.clients.claim();
});

// Fetch event - Network first, fallback to cache
self.addEventListener('fetch', event => {
  // Skip chrome-extension and other non-http requests
  if (!event.request.url.startsWith('http')) {
    return;
  }

  event.respondWith(
    // Try network first for HTML files to always get latest
    fetch(event.request)
      .then(response => {
        // Clone the response
        const responseToCache = response.clone();

        // Update cache with new response
        caches.open(CACHE_VERSION)
          .then(cache => {
            cache.put(event.request, responseToCache);
          });

        return response;
      })
      .catch(() => {
        // If network fails, try cache
        return caches.match(event.request)
          .then(response => {
            if (response) {
              return response;
            }
            // If not in cache, return offline page
            return caches.match('./index.html');
          });
      })
  );
});

// Background sync for offline data
self.addEventListener('sync', event => {
  if (event.tag === 'sync-properties') {
    event.waitUntil(syncProperties());
  }
});

async function syncProperties() {
  console.log('[SW] Syncing properties...');
  // Add your sync logic here
}

// Push notifications
self.addEventListener('push', event => {
  const options = {
    body: event.data ? event.data.text() : 'New update available!',
    icon: './icon-192.png',
    badge: './icon-192.png',
    vibrate: [200, 100, 200],
    tag: 'malta-re-notification'
  };

  event.waitUntil(
    self.registration.showNotification('Malta Real Estate PRO', options)
  );
});

// Notification click handler
self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('./')
  );
});

// Message event - for forcing updates from the app
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

console.log('[SW] Service Worker loaded - Version:', CACHE_VERSION);
