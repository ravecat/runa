<script lang="ts">
  import * as Dialog from "$lib/ui/dialog";
  import { Button } from "$lib/ui/button";
  import type { LiveSvelteProps } from "$lib/liveSvelte";

  import type { ModalProps } from "$lib/ui/modals.svelte";
  import type { Team } from "$lib/team";
  import type { Contributor } from "$lib/accounts";

  const {
    isOpen,
    team,
    contributor,
    close,
    live,
  }: LiveSvelteProps<ModalProps<{ team: Team; contributor: Contributor }>> =
    $props();

  function handleDeleteContributor() {
    live.pushEvent(`delete_contributor:${contributor.id}`, {});
    close();
  }
</script>

<Dialog.Root open={isOpen} onOpenChange={() => close()}>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>Delete contributor?</Dialog.Title>
      <Dialog.Description>
        This action cannot be undone. This will permanently delete <span
          class="font-bold">{contributor.user.name}</span
        >
        from <span class="font-bold">{team.title}</span>.
      </Dialog.Description>
    </Dialog.Header>
    <Dialog.Footer>
      <Button
        variant="outline"
        aria-label="Cancel delete contributor"
        onclick={close}>Cancel</Button
      >
      <Button
        variant="destructive"
        aria-label="Confirm delete contributor"
        onclick={handleDeleteContributor}>Delete</Button
      >
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
