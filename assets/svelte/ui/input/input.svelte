<script lang="ts">
  import type { HTMLInputAttributes } from "svelte/elements";
  import type { InputEvents } from "./index.js";
  import { cn } from "$lib/utils.js";

  type $$Props = HTMLInputAttributes & { error?: string[] };
  type $$Events = InputEvents;

  let className: $$Props["class"] = undefined;
  export let error: $$Props["error"] = [];
  export let value: $$Props["value"] = undefined;
  export { className as class };

  export let readonly: $$Props["readonly"] = undefined;
</script>

<input
  class={cn(
    "border-input bg-background ring-offset-background placeholder:text-muted-foreground focus-visible:ring-ring flex h-10 w-full rounded-md border px-3 py-2 text-xs file:border-0 file:bg-transparent file:text-xs file:font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
    className
  )}
  bind:value
  {readonly}
  on:blur
  on:change
  on:click
  on:focus
  on:focusin
  on:focusout
  on:keydown
  on:keypress
  on:keyup
  on:mouseover
  on:mouseenter
  on:mouseleave
  on:mousemove
  on:paste
  on:input
  on:wheel|passive 
  {...$$restProps}
/>
{#if error?.length > 0}
  <span class="text-destructive">{error}</span>
{/if}
