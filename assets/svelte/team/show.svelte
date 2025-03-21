<script lang="ts">
  import { Input } from "$lib/ui/input/index.js";

  import * as Card from "$lib/ui/card";
</script>

<Card.Root class="grid grid-rows-[auto_1fr_auto]">
  <Card.Header>
    <Card.Title>Team</Card.Title>
  </Card.Header>
  <Card.Content>
    <form on:submit|preventDefault={() => console.log("submit")}>
      <Input type="text" id="hostname" />
    </form>
  </Card.Content>
</Card.Root>
