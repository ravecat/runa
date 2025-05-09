<script lang="ts">
  import * as Dialog from "$lib/ui/dialog";
  import { Button } from "$lib/ui/button";
  import type { LiveSvelteProps } from "$lib/liveSvelte";

  import type { ModalProps } from "$lib/ui/modals.svelte";
  import type { Team } from "$lib/team";
  import type { Contributor } from "$lib/accounts";

  type Props = LiveSvelteProps<ModalProps<{ member: Contributor; team: Team }>>;

  let { isOpen, member, team, close, live }: Props = $props();

  function handleLeaveTeam() {
    live.pushEvent(`leave_team`, { contributor_id: member.id });
    close();
  }
</script>

<Dialog.Root open={isOpen} onOpenChange={() => close()}>
  <Dialog.Content>
    <Dialog.Header>
      <Dialog.Title>Leave team?</Dialog.Title>
      <Dialog.Description>
        This action cannot be undone. This will permanently remove you from <span
          class="font-bold"
        >
          {team.title}
        </span>
      </Dialog.Description>
    </Dialog.Header>
    <Dialog.Footer>
      <Button
        variant="outline"
        aria-label="Cancel leaving team"
        onclick={close}
      >
        Cancel
      </Button>
      <Button
        variant="destructive"
        aria-label="Confirm leaving team"
        onclick={handleLeaveTeam}>Leave</Button
      >
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>
