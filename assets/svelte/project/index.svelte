<script lang="ts">
  import Plus from "lucide-svelte/icons/plus";
  import Folders from "lucide-svelte/icons/folders";
  import Pencil from "lucide-svelte/icons/pencil";
  import Copy from "lucide-svelte/icons/copy";
  import Trash from "lucide-svelte/icons/trash-2";

  import * as Card from "$lib/ui/card";
  import { Button } from "$lib/ui/button";
  import { Badge } from "$lib/ui/badge";

  let { projects } = $props();
</script>

<Card.Root class="grid grid-rows-[auto_1fr_auto]">
  <Card.Header>
    <Card.Title aria-label="Projects"
      ><Folders class="size-4" />Projects</Card.Title
    >
    <div class="flex justify-end">
      <a
        href={"/projects/new"}
        aria-label="Create new project"
        data-phx-link="patch"
        data-phx-link-state="push"
      >
        <Button size="xs" variant="outline"><Plus class="size-4" />New</Button>
      </a>
    </div>
  </Card.Header>
  <Card.Content class="overflow-auto grid grid-cols-1 gap-2 content-start">
    {#each projects as { languages, statistics, ...project }}
      <div class="grid grid-cols-[auto_1fr] gap-1">
        <div class="grid grid-rows-[auto_1fr_auto] gap-1">
          <a
            href="/projects/{project.id}/edit"
            aria-label="Edit {project.name} project"
            data-phx-link="patch"
            data-phx-link-state="push"
          >
            <Button variant="secondary" size="icon" class="size-6">
              <Pencil class="size-4" />
            </Button>
          </a>

          <Button
            variant="secondary"
            size="icon"
            class="size-6"
            phx-click="duplicate_project"
            phx-value-id={project.id}
            aria-label="Duplicate {project.name} project"
          >
            <Copy class="size-4" />
          </Button>

          <a
            href="/projects/{project.id}/delete"
            aria-label="Delete {project.name} project"
          >
            <Button variant="secondary" size="icon" class="size-6">
              <Trash class="size-4" />
            </Button>
          </a>
        </div>
        <a
          href="/projects/{project.id}?section=settings"
          data-phx-link="patch"
          data-phx-link-state="push"
        >
          <Card.Root>
            <Card.Content
              aria-label="Project {project.name} card"
              class="grid grid-cols-[1fr,1fr,auto] h-full gap-2"
            >
              <h4 class="text-lg font-medium text-primary truncate">
                {project.name}
              </h4>
              <div
                class="flex flex-wrap content-start gap-1 truncate"
                role="list"
                aria-label="Project {project.name} languages"
              >
                {#each languages as { title, wals_code, iso_code, glotto_code }}
                  <Badge variant="secondary" role="listitem">
                    {title || wals_code || iso_code || glotto_code}
                  </Badge>
                {/each}
              </div>
              <div
                class="grid lg:grid-cols-4 grid-cols-1 lg:grid-rows-2 grid-rows-4 gap-2"
                role="group"
                aria-label="Project {project.name} statistics"
              >
                <div
                  class="flex flex-row items-center gap-2 lg:flex-col lg:items-start"
                >
                  <span class="text-sm uppercase whitespace-normal"
                    >Languages</span
                  >
                  <span
                    class="text-sm text-muted-foreground"
                    aria-label="Project {project.name} languages count"
                    >{statistics.languages_count}</span
                  >
                </div>
                <div
                  class="flex flex-row items-center gap-2 lg:flex-col lg:items-start"
                >
                  <span class="text-sm uppercase whitespace-normal">Keys</span>
                  <span
                    class="text-sm text-muted-foreground"
                    aria-label="Project {project.name} keys count"
                    >{statistics.keys_count}</span
                  >
                </div>
                <div
                  class="flex flex-row items-center gap-2 lg:flex-col lg:items-start"
                >
                  <span class="text-sm uppercase whitespace-normal">Files</span>
                  <span
                    class="text-sm text-muted-foreground"
                    aria-label="Project {project.name} files count"
                    >{statistics.files_count}</span
                  >
                </div>
                <div
                  class="flex flex-row items-center gap-2 lg:flex-col lg:items-start"
                >
                  <span class="text-sm uppercase whitespace-normal">Done</span>
                  <span
                    class="text-sm text-muted-foreground"
                    aria-label="Project {project.name} translation progress"
                    >{statistics.done}%</span
                  >
                </div>
              </div>
            </Card.Content>
          </Card.Root>
        </a>
      </div>
    {/each}
  </Card.Content>
</Card.Root>
