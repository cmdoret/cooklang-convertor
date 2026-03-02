# cooklang-convertor

LLM-based tool to migrate recipes from freeform text document to cooklang

Deploys a webserver and a vllm service.
Drag and drop text files to convert and the server will convert them to cooklang recipes.

## How to use

1. Start the server with `docker compose up`
2. In your browser, go to `http://localhost:1337`
3. Drag and drop files.

## How it works

The official BNF syntax from the cooklang spec is used to constrain token generation via vllm's structured output grammar.




