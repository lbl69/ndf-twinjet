const VERSION = "ndf-v23";
const STATIC_CACHE  = VERSION + "-static";
const RUNTIME_CACHE = VERSION + "-runtime";

const STATIC_ASSETS = [
  "./manifest.webmanifest",
  "./icon-192.png", "./icon-512.png", "./icon-512-maskable.png", "./apple-touch-icon.png",
  "./jspdf.umd.min.js", "./html2canvas.min.js", "./supabase-js.min.js"
];

self.addEventListener("install", (e) => {
  e.waitUntil((async () => {
    const s = await caches.open(STATIC_CACHE);
    await s.addAll(STATIC_ASSETS);
    try { const r = await caches.open(RUNTIME_CACHE); await r.add("./index.html"); } catch (_) {}
    await self.skipWaiting();
  })());
});

self.addEventListener("activate", (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter((k) => k !== STATIC_CACHE && k !== RUNTIME_CACHE).map((k) => caches.delete(k))
    );
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;

  const url = new URL(req.url);
  if (url.origin !== location.origin) return;

  const isHTML =
    req.mode === "navigate" ||
    url.pathname.endsWith("/") ||
    url.pathname.endsWith("/index.html");

  if (isHTML) {
    e.respondWith(
      fetch("./index.html", { cache: "no-store" })
        .then((res) => {
          const copy = res.clone();
          caches.open(RUNTIME_CACHE).then((c) => c.put("./index.html", copy)).catch(() => {});
          return res;
        })
        .catch(() => caches.match("./index.html"))
    );
    return;
  }

  e.respondWith(
    caches.match(req).then((hit) => {
      if (hit) return hit;
      return fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(RUNTIME_CACHE).then((c) => c.put(req, copy)).catch(() => {});
        return res;
      });
    })
  );
});
