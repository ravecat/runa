// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

/** @type {import('tailwindcss').Config} */

let plugin = require("tailwindcss/plugin");

module.exports = {
  darkMode: ["selector", '[data-mode="dark"]'],
  content: ["../deps/salad_ui/lib/**/*.ex", "./js/**/*.js", "../lib/**/*.*ex"],
  theme: {
    extend: {
      colors: require("./tailwind.colors.json"),
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("./vendor/tailwindcss-animate"),
    require("@tailwindcss/forms"),
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
