import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const rootDir = path.resolve(__dirname);
  const parentDir = path.resolve(rootDir, "..");
  const cwdDir = path.resolve(process.cwd());

  // .env: cwd (de onde rodou o npm), pasta pai, pasta do Vite — último vence (projeto)
  const merged = {
    ...loadEnv(mode, cwdDir, ""),
    ...loadEnv(mode, parentDir, ""),
    ...loadEnv(mode, rootDir, ""),
  };

  const viteSupabaseUrl =
    merged.VITE_SUPABASE_URL?.trim() ||
    merged.SUPABASE_URL?.trim() ||
    process.env.VITE_SUPABASE_URL?.trim() ||
    "";

  const vitePublishableKey =
    merged.VITE_SUPABASE_PUBLISHABLE_KEY?.trim() ||
    merged.VITE_SUPABASE_ANON_KEY?.trim() ||
    merged.SUPABASE_ANON_KEY?.trim() ||
    process.env.VITE_SUPABASE_PUBLISHABLE_KEY?.trim() ||
    process.env.VITE_SUPABASE_ANON_KEY?.trim() ||
    "";

  // Constantes próprias: o Vite nem sempre aplica define em import.meta.env.*
  const define: Record<string, string> = {
    __APP_SUPABASE_URL__: JSON.stringify(viteSupabaseUrl),
    __APP_SUPABASE_PUBLISHABLE_KEY__: JSON.stringify(vitePublishableKey),
  };

  return {
    root: rootDir,
    envDir: rootDir,
    define,
    server: {
      host: "::",
      port: 8080,
      hmr: {
        overlay: false,
      },
    },
    plugins: [react(), mode === "development" && componentTagger()].filter(Boolean),
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
  };
});
