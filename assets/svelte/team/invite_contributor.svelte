<script lang="ts">
  import type { LiveSvelteProps, Form } from "$lib/liveSvelte";
  import * as Popover from "$lib/ui/popover";
  import type { Team } from "$lib/team";
  import type { Contributor, ContributorInvite } from "$lib/accounts";
  import { Button } from "$lib/ui/button";
  import { MultiInput } from "$lib/ui/input";
  import * as Select from "$lib/ui/select";
  import { createForm } from "felte";

  type Props = LiveSvelteProps<{
    team: Form<Team>;
    roles: Contributor["role"][];
    invite: Form<ContributorInvite>;
  }>;

  let { team, roles, live, invite }: Props = $props();

  // Form helper below doesn't reflect the actual from errors
  // so we need to derive the errors from props
  let errors = $derived(invite.errors);

  let { form, data, isValid } = createForm<ContributorInvite>({
    onSubmit: (values) => {
      live?.pushEvent("invite_contributors", values);
    },
    initialValues: invite.data,
    validate: async (values) => {
      return new Promise((resolve) => {
        live?.pushEvent("validate_contributors", values, ({ errors }) => {
          resolve(errors);
        });
      });
    },
  });
</script>

<Popover.Root>
  <Popover.Trigger asChild let:builder>
    <Button builders={[builder]} variant="outline" size="xs">Add member</Button>
  </Popover.Trigger>
  <Popover.Content align="end" class="w-[32rem]">
    <div class="grid gap-4">
      <div class="space-y-2">
        <h4 class="font-medium leading-none">Invite member</h4>
        <p class="text-muted-foreground text-sm">
          Invite member to {team.data.title} team.
        </p>
      </div>
      <form class="flex flex-col gap-4" use:form>
        <div class="flex gap-4 items-start">
          <input type="hidden" name="team_id" value={team.data.id} />
          <MultiInput
            name="emails"
            placeholder="Email"
            class="w-2/3"
            error={errors.emails}
            bind:value={$data.emails}
          />
          <Select.Root
            name="role"
            selected={{ value: $data.role, label: $data.role }}
            onSelectedChange={({ value }) => {
              $data.role = value;
            }}
          >
            <Select.Trigger class="w-1/3">
              <Select.Value placeholder="role" />
            </Select.Trigger>
            <Select.Content>
              {#each roles as role}
                <Select.Item value={role}>{role}</Select.Item>
              {/each}
            </Select.Content>
          </Select.Root>
        </div>
        <Button type="submit" size="xs" class="self-start">Invite</Button>
      </form>
    </div>
  </Popover.Content>
</Popover.Root>
