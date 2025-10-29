ARG DEVSHA=""
ARG RUNSHA=""

ARG BASEURL="docker.io/democbarker"

FROM $BASEURL/dhi-python:3.13-dev$DEVSHA AS build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create venv to make UV happy
RUN python -m venv venv

RUN /app/venv/bin/pip install uv
RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    /app/venv/bin/python -m uv sync --active --frozen --no-managed-python --force-reinstall

## -----------------------------------------------------
## Final stage

FROM $BASEURL/dhi-python:3.13$RUNSHA AS runtime-stage

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

