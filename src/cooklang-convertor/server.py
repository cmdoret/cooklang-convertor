import os
from typing import List

import openai
import requests
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

# Initialize FastAPI app
app = FastAPI()

# Allow CORS for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve Static Files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Directory to store uploaded files temporarily
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Load Cooklang EBNF Grammar
with open("assets/cooklang.gbnf", "r") as f:
    cooklang_grammar = f.read()

# Load Example System Prompt
with open("assets/examples.md", "r") as f:
    examples_prompt = f.read()

# In-Memory System Prompt Storage
default_system_prompt = f"Here are example recipes in Cooklang format:\n\n{examples_prompt}\n\nConvert the recipe below to Cooklang format. Give me the cooklang file and nothing else.\n\n"

# VLLM API Configuration
VLLM_API_URL = "http://localhost:8000/v1/chat/completions"
openai.api_base = VLLM_API_URL


@app.post("/upload/")
async def upload_files(files: List[UploadFile] = File(...)):
    """
    Endpoint to handle file uploads.
    Accepts multiple files and stores them temporarily.
    """
    if not files:
        raise HTTPException(status_code=400, detail="No files uploaded.")

    uploaded_files = []

    for file in files:
        file_path = os.path.join(UPLOAD_DIR, file.filename)

        # Save the uploaded file temporarily
        with open(file_path, "wb") as f:
            f.write(await file.read())

        uploaded_files.append({"filename": file.filename, "path": file_path})

    return JSONResponse(content={"uploaded_files": uploaded_files})


@app.post("/convert/")
async def convert_file(filename: str = Form(...), system_prompt: str = Form(None)):
    """
    Endpoint to convert an uploaded file to Cooklang format.
    """
    file_path = os.path.join(UPLOAD_DIR, filename)
    file_path = os.path.join(UPLOAD_DIR, filename)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found.")

    # Read the file content
    with open(file_path, "r") as f:
        recipe = f.read()

    # Use the provided system prompt or fall back to the default system prompt
    context = system_prompt if system_prompt else default_system_prompt

    print(context)

    # Call VLLM API for Cooklang Conversion
    try:
        from openai import OpenAI

        client = OpenAI()

        response = client.chat.completions.create(
            model="Qwen/Qwen3-8B-AWQ",
            messages=[
                {
                    "role": "system",
                    "content": context,
                },
                {"role": "user", "content": recipe},
            ],
            extra_body={"structured_outputs": {"grammar": cooklang_grammar}},
        )
        print(f"VLLM API response: {response}")  # Debugging log

        converted_recipe = response.choices[0].message.content
    except Exception as e:
        print(f"Error during VLLM API call: {e}")  # Debugging log
        raise HTTPException(
            status_code=500, detail=f"Error during conversion: {str(e)}"
        )

    return JSONResponse(
        content={"filename": filename, "cooklang_recipe": converted_recipe}
    )


# Settings Model
class Settings(BaseModel):
    system_prompt: str


# In-Memory Settings Storage
settings = {"system_prompt": "Default prompt"}


@app.post("/settings/system_prompt/")
async def update_system_prompt(new_prompt: str = Form(...)):
    """
    Endpoint to update the system prompt.
    """
    global default_system_prompt
    default_system_prompt = new_prompt
    return {"message": "System prompt updated successfully!"}


@app.get("/settings/system_prompt/")
async def get_system_prompt():
    """
    Endpoint to retrieve the current system prompt.
    """
    return {"system_prompt": default_system_prompt}


@app.get("/")
async def root():
    """
    Root endpoint to verify the server is running.
    """
    return {"message": "Welcome to the Cooklang Convertor API!"}
