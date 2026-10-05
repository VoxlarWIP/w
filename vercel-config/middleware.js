export const config = {
  matcher: ['/scripts', '/scripts/:path*', '/\\.ppw'],
};

export default function middleware(request) {
  const url = new URL(request.url);
  const path = url.pathname.toLowerCase();

  if (path === '/.ppw') {
    return;
  }

  const ua = (request.headers.get('user-agent') || '').toLowerCase();
  const accept = (request.headers.get('accept') || '').toLowerCase();

  const looksLikeBrowser =
    accept.includes('text/html') ||
    ua.includes('mozilla') ||
    ua.includes('chrome') ||
    ua.includes('safari') ||
    ua.includes('firefox') ||
    ua.includes('opera') ||
    ua.includes('edge') ||
    ua.includes('msie');

  if (looksLikeBrowser) {
    return Response.redirect(
      new URL('/blocked.html', url.origin).toString(),
      302
    );
  }
}
