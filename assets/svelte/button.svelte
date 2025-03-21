<script lang="ts">
  import { Button } from "$lib/ui/button";

  let { children }: Props = $props();
</script>

<Button>{@render children?.()}</Button>
