import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { resolve } from "path";
import { sveltePreprocess } from "svelte-preprocess";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig(({ command, mode }) => {
  const isDev = mode === "development";

  if (isDev) {
    // Terminate the watcher when Phoenix quits
    process.stdin.on("close", () => {
      process.exit(0);
    });

    process.stdin.resume();
  }

  return {
    conditions: ["svelte", "browser", ...(isDev ? ["development"] : [])],
    plugins: [
      svelte({
        preprocess: sveltePreprocess(),
        compilerOptions: {
          dev: isDev,
          hydratable: true,
          css: "injected",
        },
      }),
      tailwindcss(),
    ],
    optimizeDeps: {
      include: ["svelte"],
      conditions: ["svelte", "browser", ...(isDev ? ["development"] : [])],
    },
    resolve: {
      alias: {
        $lib: resolve(__dirname, "svelte"),
      },
    },
    publicDir: false,
    logLevel: "info",
    build: {
      target: "esnext",
      outDir: "../priv/static/assets",
      emptyOutDir: true,
      manifest: false,
      minify: !isDev,
      sourcemap: isDev ? "inline" : false,
      rollupOptions: {
        input: {
          app: resolve(__dirname, "js/app.js"),
        },
        output: {
          assetFileNames: "[name][extname]",
          entryFileNames: "[name].js",
          chunkFileNames: "[name].js",
        },
      },
      commonjsOptions: {
        exclude: [],
        include: ["vendor/topbar.js"],
      },
    },
  };
});
