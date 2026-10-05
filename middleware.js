export const config = {
  matcher: ['/scripts/:path*']
};

export default function middleware(request) {
  const accept = (request.headers.get('accept') || '').toLowerCase();
  const secFetchDest = (request.headers.get('sec-fetch-dest') || '').toLowerCase();
  const secFetchMode = (request.headers.get('sec-fetch-mode') || '').toLowerCase();

  const isBrowserNavigation =
    secFetchDest === 'document' ||
    secFetchMode === 'navigate' ||
    accept.includes('text/html');

  if (isBrowserNavigation) {
    return Response.redirect(
      new URL('/blocked.html', request.url),
      302
    );
  }
}
