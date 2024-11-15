[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter, Recode.FormatterPlugin],
  inputs: [
    "{config,lib,test}/**/*.{ex,exs,heex}",
    "*.{heex,ex,exs}"
  ],
  line_length: 80
]
