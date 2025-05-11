import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { resolve } from "path";
import { sveltePreprocess } from "svelte-preprocess";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig(({ command, mode }) => {
  const isDev = mode === "development";
  return {
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
    conditions: ["svelte", ...(isDev ? ["development"] : [])],
    resolve: {
      alias: {
        $lib: resolve(__dirname, "svelte"),
      },
    },
    build: {
      target: "node19",
      ssr: true,
      outDir: "../priv/svelte",
      emptyOutDir: true,
      rollupOptions: {
        input: "./js/server.js",
        output: {
          format: "esm",
          inlineDynamicImports: true,
        },
      },
      sourcemap: isDev ? "inline" : false,
      minify: false,
    },
    experimental: {
      renderBuiltUrl: (filename) => {
        return { relative: true };
      },
    },
    ssr: {
      noExternal: isDev,
    },
  };
});
