// middleware.js — place this in the ROOT of your Vercel project (same level as vercel.json)
// Vercel Edge Middleware: runs before any file is served.

export const config = {
  matcher: ['/(.*\\.lua)', '/(.*\\.luau)', '/(.*\\.txt)', '/\\.ppw'],
};

export default function middleware(request) {
  const url  = new URL(request.url);
  const path = url.pathname.toLowerCase();

  // ── .ppw  →  executor handshake file, always pass through ─────────────────
  if (path === '/.ppw') {
    return;          // Vercel serves the real .ppw file unchanged
  }

  // ── determine whether the caller looks like a browser ─────────────────────
  const ua     = (request.headers.get('user-agent') || '').toLowerCase();
  const accept = (request.headers.get('accept')     || '').toLowerCase();

  const looksLikeBrowser =
    accept.includes('text/html') ||
    ua.includes('mozilla')       ||
    ua.includes('chrome')        ||
    ua.includes('safari')        ||
    ua.includes('firefox')       ||
    ua.includes('opera')         ||
    ua.includes('edge')          ||
    ua.includes('msie');

  if (looksLikeBrowser) {
    // Redirect to the block page
    const blockUrl = new URL('/blocked.html', url.origin);
    return Response.redirect(blockUrl.toString(), 302);
  }

  // ── not a browser → allow through (executor gets the real file) ────────────
  return;    // undefined = Vercel serves the file normally
}
