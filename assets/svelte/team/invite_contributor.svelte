<script lang="ts">
  import type { LiveSvelteProps, Form } from "$lib/liveSvelte";
  import * as Popover from "$lib/ui/popover";
  import type { Team } from "$lib/team";
  import type { Contributor } from "$lib/accounts";
  import { Button } from "$lib/ui/button";
  import { MultiInput } from "$lib/ui/input";
  import * as Select from "$lib/ui/select";

  let {
    team,
    roles,
  }: LiveSvelteProps<{ team: Form<Team>; roles: Contributor["role"][] }> =
    $props();
</script>

<Popover.Root portal={null}>
  <Popover.Trigger asChild let:builder>
    <Button builders={[builder]} variant="outline" size="xs">Add member</Button>
  </Popover.Trigger>
  <Popover.Content align="end" class="w-128">
    <div class="grid gap-4">
      <div class="space-y-2">
        <h4 class="font-medium leading-none">Invite member</h4>
        <p class="text-muted-foreground text-sm">
          Invite member to {team.data.title} team.
        </p>
      </div>
      <div class="grid grid-cols-3 items-center gap-4">
        <MultiInput placeholder="Email" class="col-span-2" />
        <Select.Root multiple>
          <Select.Trigger class="col-span-1">
            <Select.Value placeholder="Role" />
          </Select.Trigger>
          <Select.Content>
            {#each roles as role}
              <Select.Item value={role}>{role}</Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
      </div>
      <Button size="xs" disabled>Invite</Button>
    </div>
  </Popover.Content>
</Popover.Root>
