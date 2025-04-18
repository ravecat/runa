const Components = import.meta.glob("../svelte/**/*.svelte", { eager: true });
import { getRender } from "live_svelte";

export const render = getRender(Components);
