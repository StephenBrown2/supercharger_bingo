// Same-origin, read-only proxy for the two public supercharging.life reads
// that username import needs. supercharging.life sends no CORS headers, so the
// browser cannot call it directly. Delete this file (and `main` in
// wrangler.jsonc) once real login replaces username import.
const allowed = {
  '/life/supercharging/ajax.php': ['content', 'user_list_for_datatables'],
  '/life/supercharging/export.php': ['action', 'user_xlsx'],
};

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const rule = allowed[url.pathname];
    if (request.method !== 'GET' || !rule || url.searchParams.get(rule[0]) !== rule[1]) {
      return new Response('Not found', { status: 404 });
    }
    // No cookies or other client headers go upstream.
    const upstream = await fetch(
      `https://supercharging.life${url.pathname.slice('/life'.length)}${url.search}`,
      { headers: { 'User-Agent': 'SuperchargerBingo/1.0 (web demo import)' } },
    );
    return new Response(upstream.body, {
      status: upstream.status,
      headers: {
        'Content-Type': upstream.headers.get('Content-Type') ?? 'application/octet-stream',
        'Cache-Control': 'no-store',
      },
    });
  },
};
