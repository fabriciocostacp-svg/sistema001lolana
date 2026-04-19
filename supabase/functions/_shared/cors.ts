const defaultAllowHeaders =
  'authorization, x-client-info, apikey, content-type, x-session-token';

export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': defaultAllowHeaders,
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

export function handleCors(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    const requested = req.headers.get('Access-Control-Request-Headers');
    const headers: Record<string, string> = {
      ...corsHeaders,
      ...(requested
        ? { 'Access-Control-Allow-Headers': requested }
        : {}),
    };
    return new Response(null, {
      status: 200,
      headers,
    });
  }
  return null;
}
