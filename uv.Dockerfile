FROM docker.io/democbarker/dhi-python:3.13-dev@sha256:8618da1bf0111e2050d3a22484ccf7cde5c5ea0dbe4e45f7184584e21bbb508e AS build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV UV_COMPILE_BYTECODE=0
WORKDIR /app

# Create venv to make UV happy
RUN python -m venv venv

RUN /app/venv/bin/pip install uv
RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    /app/venv/bin/python -m uv sync --active --frozen --no-managed-python --force-reinstall

## -----------------------------------------------------
## Final stage
FROM docker.io/democbarker/dhi-python:3.13@sha256:1efb666ab69200d7aa5516143190d82a3d171177b655a43b708c9ee0878eb1c5 AS runtime-stage

LABEL org.opencontainers.image.base.name="docker.io/democbarker/dhi-python:3.13"
LABEL org.opencontainers.image.base.digest="docker.io/democbarker/dhi-python:3.13@sha256:1efb666ab69200d7aa5516143190d82a3d171177b655a43b708c9ee0878eb1c5"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=build-stage \
    /app/venv \
    venv


ENV PATH="/app/venv/bin:$PATH"

COPY app.py .

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]

