import { getRender } from "live_svelte";

const Components = import.meta.glob("../svelte/**/*.svelte", {
  eager: true,
  import: "default",
});

export const render = getRender(Components);
