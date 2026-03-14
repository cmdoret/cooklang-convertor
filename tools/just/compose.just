# List all compose recipes

ctr := "sudo docker"
root_dir := `git rev-parse --show-toplevel`
stacks_dir := "src/stacks"

[private]
default:
    just --unsorted --list compose --no-aliases 

[private]
cmd stack *args:
    @cd {{ root_dir }} \
    && echo {{ ctr }} compose \
      --env-file {{ stacks_dir }}/{{ stack }}/.env \
      -f {{ stacks_dir }}/{{ stack }}/compose.yaml \
      {{ args }}

# Start compose stack
up stack *args:
    @cd {{ root_dir }} && \
       just compose::cmd {{ stack }} up \
          --detach \
          --force-recreate \
          --remove-orphans \
          {{ args }}

# Stop compose stack
down stack *args:
    @cd {{ root_dir }} && \
    just compose::cmd {{ stack }} down {{ args }}

# Follow logs from a stack
logs stack *args:
    @cd {{ root_dir }} && \
      just compose::cmd {{ stack }} logs -f {{ args }}

# List running stacks
ls *args:
    @cd {{ root_dir }} && \
      {{ ctr }} compose ls {{ args }}

# Start all stacks
all-up *args:
    #!/usr/bin/env bash
    set -euo pipefail

    cd {{ root_dir }}
    for path in $(find {{ stacks_dir }} -name 'compose.yaml'); do \
      $(just compose::up ${path} {{ args }})
    done

# Stop all stacks
all-down *args:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{ root_dir }}
    for path in $(find {{ stacks_dir }} -name 'compose.yaml'); do \
      $(just compose::down ${path} {{ args }} )
    done
