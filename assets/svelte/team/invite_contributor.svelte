<script lang="ts">
  import type { LiveSvelteProps, Form } from "$lib/liveSvelte";
  import * as Popover from "$lib/ui/popover";
  import type { Team } from "$lib/team";
  import type { Contributor, ContributorInvite } from "$lib/accounts";
  import { Button } from "$lib/ui/button";
  import { MultiInput } from "$lib/ui/input";
  import * as Select from "$lib/ui/select";
  import { createForm } from "felte";
  import { validator } from "@felte/validator-superstruct";
  import { object, string, size, array } from "superstruct";

  type Props = LiveSvelteProps<{
    team: Form<Team>;
    roles: Contributor["role"][];
  }>;

  let { team, roles, live }: Props = $props();

  // So-so
  const struct = object({
    emails: size(array(string()), 1, Infinity),
    role: string(),
  });

  const { form, data, errors } = createForm<ContributorInvite>({
    onSubmit: (values) => {
      live?.pushEvent("invite_contributors", values);
    },
    extend: validator({ struct }),
    initialValues: {
      emails: [],
      role: "viewer",
    },
  });
</script>

<Popover.Root open={true} portal={null}>
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
      <form class="grid grid-cols-3 items-center gap-4" use:form>
        <MultiInput
          placeholder="Email"
          class="col-span-2"
          error={$errors.emails}
          onValueChange={(v) => {
            $data.emails = v;
          }}
        />
        <Select.Root
          name="role"
          selected={{ value: $data.role, label: $data.role }}
          onSelectedChange={({ value }: { value: string }) => {
            $data.role = value;
          }}
        >
          <Select.Trigger class="col-span-1">
            <Select.Value placeholder="Role" />
          </Select.Trigger>
          <Select.Content>
            {#each roles as role}
              <Select.Item value={role}>{role}</Select.Item>
            {/each}
          </Select.Content>
        </Select.Root>
        <Button type="submit" size="xs">Invite</Button>
      </form>
    </div>
  </Popover.Content>
</Popover.Root>
