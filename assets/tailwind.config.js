// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

/** @type {import('tailwindcss').Config} */

let plugin = require("tailwindcss/plugin");

module.exports = {
  darkMode: ["selector", '[data-mode="dark"]'],
  content: ["./js/**/*.js", "../lib/**/*.*ex", "./svelte/**/*.svelte"],
  plugins: [
    require("daisyui"),
    require("@tailwindcss/typography"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", ["&.phx-no-feedback", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        "&.phx-click-loading",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        "&.phx-submit-loading",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        "&.phx-change-loading",
        ".phx-change-loading &",
      ])
    ),
  ],
};
