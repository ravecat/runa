<script lang="ts">
  import { Input } from "$lib/ui/input";
  import * as Card from "$lib/ui/card";

  let { team, live } = $props();

  function handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    live?.pushEvent("save_", { team: team.data });
  }
</script>

<Card.Root class="grid grid-rows-[auto_1fr_auto]">
  <Card.Header>
    <Card.Title>Team</Card.Title>
  </Card.Header>
  <Card.Content>
    <form onsubmit={handleSubmit}>
      <Input bind:value={team.data.title} />
    </form>
  </Card.Content>
</Card.Root>
