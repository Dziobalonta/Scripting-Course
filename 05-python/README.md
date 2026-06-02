# AI Restaurant Assistant (Local LLM & Flask)

A fully functional, AI-powered restaurant assistant utilizing a local Large Language Model (Gemma4 2B) via the Ollama engine. The chatbot is capable of taking orders, verifying allergens, estimating preparation times, and securely extracting delivery addresses. The entire system communicates with a custom backend REST API written in Flask.

## Tech Stack
* **Python 3.11** (Alpine-based Docker Image)
* **Ollama** (Model: `gemma4:e2b`)
* **Flask** (REST API Backend)
* **Docker**

## Prerequisites
1. Install and run [Ollama](https://ollama.com/) on your host machine.
2. Pull the required language model:
   ```bash
   ollama run gemma4:e2b
   ```
3. Runing via docker
   ```bash
   docker-compose up -d api
   docker-compose run bot
   ```