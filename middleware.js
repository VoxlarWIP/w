export const config = {
  matcher: ['/scripts/:path*']
};

export default function middleware(request) {
  const ua = (request.headers.get('user-agent') || '').toLowerCase();
  const accept = (request.headers.get('accept') || '').toLowerCase();

  const looksLikeBrowser =
    accept.includes('text/html') ||
    ua.includes('mozilla') ||
    ua.includes('chrome') ||
    ua.includes('safari') ||
    ua.includes('firefox') ||
    ua.includes('edg/');

  if (looksLikeBrowser) {
    return Response.redirect(
      new URL('/blocked.html', request.url),
      302
    );
  }
}
