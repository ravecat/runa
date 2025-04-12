<script lang="ts">
  import type { HTMLAttributes } from "svelte/elements";
  import { cn } from "$lib/utils.js";
  import { slide } from "svelte/transition";
  import { quintOut } from "svelte/easing";

  type $$Props = HTMLAttributes<HTMLTableRowElement> & {
    "data-state"?: unknown;
  };

  let className: $$Props["class"] = undefined;
  export { className as class };
</script>

<tr
  class={cn(
    "hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors",
    className
  )}
  {...$$restProps}
  on:click
  on:keydown
  transition:slide={{ easing: quintOut, duration: 600 }}
>
  <slot />
</tr>
