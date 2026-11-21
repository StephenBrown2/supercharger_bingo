// Same-origin, read-only proxy for the public supercharging.life reads the web
// app needs: username import, and the community history and counts behind
// First pins and alerts. supercharging.life sends no CORS headers, so the
// browser cannot call it directly. Delete this file (and `main` in
// wrangler.jsonc) once supercharging.life sends CORS headers.
const allowed = {
  '/life/supercharging/ajax.php': ['content', [
    'user_list_for_datatables',
    'first_checkin_history_list_for_datatables',
    'supercharger_checkin_history_list_for_datatables',
    'supercharger_list_for_datatables',
  ]],
  '/life/supercharging/export.php': ['action', ['user_xlsx']],
};

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const rule = allowed[url.pathname];
    if (request.method !== 'GET' || !rule || !rule[1].includes(url.searchParams.get(rule[0]))) {
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
