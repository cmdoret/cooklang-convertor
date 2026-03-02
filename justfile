# Serve the convertor for development
serve:
  OPENAI_API_KEY=abc OPENAI_BASE_URL=http://localhost:8000/v1/ uv run uvicorn src.cooklang-convertor.server:app --host 0.0.0.0 --port 1337 --reload

# Deploy the stack.
deploy:
  docker compose up
