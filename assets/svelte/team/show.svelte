<script lang="ts">
  import { modals } from "svelte-modals";
  import { flip } from "svelte/animate";
  import type { LiveSvelteProps, Form } from "$lib/liveSvelte";
  import type { Team } from "$lib/team/types";
  import type { User, Contributor } from "$lib/accounts/types";
  import { Input } from "$lib/ui/input";
  import * as Table from "$lib/ui/table";
  import * as Card from "$lib/ui/card";
  import * as Select from "$lib/ui/select";
  import { debounce } from "$lib/shared/debounce";
  import { Calendar, Users, Trash2 } from "lucide-svelte";
  import DeleteContributorModal from "./delete_contributor_modal.svelte";

  let {
    team,
    live,
    owner,
    members,
    current_user,
    roles,
  }: LiveSvelteProps<{
    team: Form<Team>;
    current_user: User;
    owner: User;
    members: Contributor[];
    roles: Contributor["role"][];
  }> = $props();

  let form = team.data;
  let errors = $derived(team.errors);

  function handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    live.pushEvent("save", { team: form });
  }

  const handleValidate = debounce(function () {
    live.pushEvent("validate", { team: form });
  }, 300);

  function handleRoleChange(member: Contributor, role: string) {
    live.pushEvent(`update_contributor:${member.id}`, {
      contributor: { role },
    });
  }
</script>

<Card.Root class="grid grid-rows-[auto_1fr_auto]">
  <Card.Header>
    <Card.Title>Team</Card.Title>
  </Card.Header>
  <Card.Content>
    <form onsubmit={handleSubmit} class="flex flex-col gap-2">
      <Input
        bind:value={form.title}
        error={errors.title}
        onkeyup={handleValidate}
      />
      <div class="text-sm flex justify-between gap-2">
        <span class="text-muted-foreground flex items-center gap-1">
          <Calendar class="size-4" /> Creation date
        </span>
        <span>{form.inserted_at}</span>
      </div>
      <div class="text-sm flex justify-between gap-2">
        <span class="text-muted-foreground flex items-center gap-1">
          <Calendar class="size-4" /> Modification date
        </span>
        <span>{form.updated_at}</span>
      </div>
      <div class="text-sm flex justify-between gap-2">
        <span class="text-muted-foreground flex items-center gap-1">
          <Users class="size-4" /> Owner
        </span>
        <span>{owner.name}</span>
      </div>
    </form>
    <Table.Root aria-label="Team members">
      <Table.Header>
        <Table.Row>
          <Table.Head class="w-1/3">Contributor</Table.Head>
          <Table.Head class="w-1/3">Role</Table.Head>
          <Table.Head class="w-1/3">Joined</Table.Head>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {#each members as member (member.id)}
          <div class="contents" animate:flip={{ duration: 200 }}>
            <Table.Row aria-label="Member {member.user.name} form">
              <Table.Cell class="font-medium">{member.user.name}</Table.Cell>
              <Table.Cell aria-label="Role for {member.user.name}">
                {#if member.user.id === owner.id}
                  <span>{member.role}</span>
                {:else}
                  <Select.Root
                    selected={{ value: member.role, label: member.role }}
                    onSelectedChange={(v) => {
                      handleRoleChange(member, v.value);
                    }}
                  >
                    <Select.Trigger class="w-32">
                      <Select.Value />
                    </Select.Trigger>
                    <Select.Content>
                      {#each roles as role}
                        <Select.Item value={role}>{role}</Select.Item>
                      {/each}
                    </Select.Content>
                  </Select.Root>
                {/if}
              </Table.Cell>
              <Table.Cell class="flex items-center gap-2">
                {member.inserted_at}
                {#if current_user.id == owner.id && member.role !== "owner"}
                  <Trash2
                    onclick={() =>
                      modals.open(DeleteContributorModal, {
                        contributor: member,
                        team: team.data,
                        live: live,
                      })}
                    class="size-4 flex-shrink-0 cursor-pointer hover:bg-muted"
                    aria-label="Delete {member.user.name} from team"
                  />
                {/if}
              </Table.Cell>
            </Table.Row>
          </div>
        {/each}
      </Table.Body>
    </Table.Root>
  </Card.Content>
</Card.Root>
