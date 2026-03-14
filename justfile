set positional-arguments
set dotenv-load
set shell := ["bash", "-cue"]
root_dir := `git rev-parse --show-toplevel`

# List all recipes
[private]
default:
  just --list --no-aliases

# Serve the convertor for development
serve:
  OPENAI_API_KEY=abc OPENAI_BASE_URL=http://localhost:8000/v1/ uv run uvicorn src.cooklang-convertor.server:app --host 0.0.0.0 --port 1337 --reload

# Deploy the stack.
deploy:
  docker compose up

# Enter a development shell.
[group('general')]
develop:
    just nix::develop default

# Format the whole repository.
[group('general')]
format *args:
    treefmt "$@"


# Docker compose management
mod compose 'tools/just/compose.just'
# Nix deployments
mod nix 'tools/just/nix.just'
