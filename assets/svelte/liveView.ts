import { writable } from "svelte/store";

import type { Live } from "live_svelte";

export const live = writable<Live>();