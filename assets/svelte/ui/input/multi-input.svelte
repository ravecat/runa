<script lang="ts">
  import { Badge } from "$lib/ui/badge";
  import X from "lucide-svelte/icons/x";
  import { Button } from "$lib/ui/button";
  import type { Snippet } from "svelte";
  import type { HTMLInputAttributes } from "svelte/elements";
  import { cn } from "$lib/utils.js";

  type Props = HTMLInputAttributes & {
    value?: string[];
    icon?: Snippet;
    badge?: Snippet;
    onValueChange?: (newValue: string[]) => void;
    error?: string[] | string;
  };

  let {
    value = $bindable([]),
    placeholder = "Enter a value",
    icon,
    badge,
    class: className,
    error,
    name,
    onValueChange,
    ...rest
  }: Props = $props();
  let currentValue = $state("");
  let inputElement: HTMLInputElement = $state();

  function onkeydown(event: KeyboardEvent) {
    if (event.key === "Enter" && currentValue.trim() !== "") {
      event.preventDefault();
      const newValue = currentValue.trim();

      if (!value.includes(newValue)) {
        value = [...value, newValue];
        currentValue = "";
        onValueChange?.(value);
      }
    } else if (
      event.key === "Backspace" &&
      currentValue === "" &&
      value.length > 0
    ) {
      event.preventDefault();
      value = value.slice(0, -1);
    }
  }

  function dropValue(index: number) {
    value = [...value.slice(0, index), ...value.slice(index + 1)];
    inputElement?.focus();
    onValueChange?.(value);
  }
</script>

<div class={className}>
  <div
    role="group"
    id="tags"
    class={cn(
      "flex flex-wrap items-center gap-1 px-3 py-2 w-full min-h-10 border rounded-md focus-within:ring-2 max-w-full box-border",
      error?.length > 0 ? "border-destructive focus-within:ring-destructive focus-within:ring-1" : "border-input focus-within:ring-ring",
    )}
  >
    {#each value as item, idx (item)}
      <div class="flex items-center">
        {#if badge}
          {@render badge()}
        {:else}
          <Badge variant="outline">
            {item}
          </Badge>
        {/if}
        <Button
          class="size-6"
          size="icon"
          variant="ghost"
          aria-label="Remove {item}"
          onclick={() => dropValue(idx)}
        >
          {#if icon}
            {@render icon()}
          {:else}
            <X class="size-3 text-muted-foreground" />
          {/if}
        </Button>
      </div>
    {/each}
    <input
      class="bg-transparent border-none outline-none p-0 h-6 text-xs focus:ring-0 flex-1 min-w-0 box-border"
      type="text"
      placeholder={value.length === 0 ? placeholder : ""}
      bind:value={currentValue}
      bind:this={inputElement}
      {onkeydown}
      aria-controls="tags"
      aria-autocomplete="list"
      {...rest}
    />
  </div>
  {#if error?.length > 0}
    <p
      class="mt-1 px-1 text-xs text-destructive overflow-hidden text-ellipsis whitespace-nowrap w-full"
    >
      {Array.isArray(error) ? error[0] : error}
    </p>
  {/if}
</div>
