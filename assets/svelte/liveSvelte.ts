import type { Live } from "live_svelte";

export type LiveSvelteProps<Out extends Record<string, unknown> = {}> = {
    live: Live;
} & Out;

export type Form<Out extends Record<string, unknown>> = {
    id: string;
    valid: boolean;
    posted: boolean;
    data: Out;
    errors: Record<keyof Out, string[]>;
};