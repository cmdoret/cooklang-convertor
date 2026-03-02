# cooklang-convertor

This is an experiment to use LLM-based tools with structured output to migrate recipes from freeform text document to valid cooklang files.

Deploys a compose stack with a webserver and a vllm service.
Drag and drop text files to convert and the server will convert them to cooklang recipes.

## Requirements

* 12GB VRAM
* docker
* Nvidia GPU

## TODO

* [ ] Batch directory conversion
* [ ] Batch export
* [ ] Manual output editing
* [ ] Progress bar

## How to use

1. Start the server with `docker compose up`
2. In your browser, go to `http://localhost:1337`
3. Drag and drop files.
4. click convert.

## How it works

The repo defines a GNBF grammar for cooklang.
Qwen3-8B-AWQ is run with reasoning + structured outputs to enforce the responses to conform to the cooklang grammar.
