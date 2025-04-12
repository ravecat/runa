<script module lang="ts">
  import { Modals } from "svelte-modals";
  import type { ModalProps as DefaultModalProps } from "svelte-modals";

  export type ModalProps<
    Out extends Record<string, unknown> = {},
    ReturnValue = void,
  > = DefaultModalProps<ReturnValue> & Out;
</script>

<Modals />
