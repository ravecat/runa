import { defineConfig } from "vite";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import glob from "vite-plugin-glob";

const __dirname = dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [svelte(), glob()],
  resolve: {
    alias: {
      $lib: resolve(__dirname, "svelte"),
    },
  },
  build: {
    rollupOptions: {
      input: {
        app: resolve(__dirname, "js/app.js"),
        server: resolve(__dirname, "js/server.js"),
      },
      output: {
        entryFileNames: `[name].js`,
        chunkFileNames: `[name].js`,
        assetFileNames: `[name].[ext]`,
      },
    },
    outDir: "../priv/static/assets/",
    emptyOutDir: true,
    assetsDir: "",
  },
});
