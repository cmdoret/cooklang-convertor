# cooklang-convertor

This is an experiment to use LLM-based tools with structured output to migrate recipes from freeform text document to valid cooklang files.

Deploys a compose stack with a webserver and a vllm service.
Drag and drop text files to convert and the server will convert them to cooklang recipes.

## Requirements

### needed

- 12GB VRAM
- docker
- Nvidia GPU

### needed

- just
- nix
- direnv

## How to use

1. Start the inference server with `just deploy` (or `docker compose up`).
1. Start the server with `just serve` (or the corresponding command in justfile)
1. In your browser, go to `http://localhost:1337`
1. Drag and drop files.
1. click convert.

## How it works

The repo defines a GNBF grammar for cooklang (see `./assets`).
Qwen3-8B-AWQ is run with reasoning + structured outputs to enforce the responses to conform to the cooklang grammar.


## Conclusion

A 8B model does not seem powerful enough to use with grammars, it is unable to generate valid tokens and results in very long blocking time and truncated files.
