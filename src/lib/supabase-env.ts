/**
 * URL e chave pública do Supabase.
 * O vite.config injeta __APP_* no build (inclui .env na pasta do projeto, pai e cwd).
 */

export function getSupabaseUrl(): string {
  const injected =
    typeof __APP_SUPABASE_URL__ !== "undefined" ? __APP_SUPABASE_URL__ : "";
  const fromMeta = (import.meta.env.VITE_SUPABASE_URL as string | undefined) || "";
  return String(injected || fromMeta).trim();
}

export function getSupabasePublishableKey(): string {
  const injected =
    typeof __APP_SUPABASE_PUBLISHABLE_KEY__ !== "undefined"
      ? __APP_SUPABASE_PUBLISHABLE_KEY__
      : "";
  const fromMeta =
    (import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY as string | undefined) ||
    (import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined) ||
    "";
  return String(injected || fromMeta).trim();
}
