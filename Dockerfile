# syntax=docker/dockerfile:1.12
FROM python:3.12-slim AS base
# Create a non-root user
RUN useradd -m appuser
WORKDIR /app
ENV PORT=8080
EXPOSE $PORT
ENV HOST=0.0.0.0
# Install uv and langflow
RUN pip install --no-cache-dir uv && \
    mkdir -p /app/data && \
    chown -R appuser:appuser /app
# Install wxai requirements with uv (using --system flag) and download pyproject.toml
RUN uv pip install --system altair pandas numpy && \
    uv pip install --system -r https://requirements-installs-bucket.s3.eu-de.cloud-object-storage.appdomain.cloud/marimo-requirements.txt && \
    python -c "import urllib.request; urllib.request.urlretrieve('https://requirements-installs-bucket.s3.eu-de.cloud-object-storage.appdomain.cloud/pyproject.toml', '/app/pyproject.toml')"
# Create uv cache directory for appuser 
RUN mkdir -p /home/appuser/.cache/uv && \
    chown -R appuser:appuser /home/appuser && \
    chown appuser:appuser /app/pyproject.toml
# Install langflow
RUN uv pip install --system langflow
USER appuser
# Run langflow instead of marimo
CMD uv run langflow run --host $HOST --port $PORT
