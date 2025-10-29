ARG DEVSHA=""
ARG RUNSHA=""

ARG BASEURL="docker.io/democbarker"

## UV Build Stage

FROM $BASEURL/dhi-python:3.13-dev$DEVSHA AS uv-build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create venv to make UV happy
RUN python -m venv venv

RUN /app/venv/bin/pip install uv
RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    /app/venv/bin/python -m uv sync --active --frozen --no-managed-python --force-reinstall

## UV Runtime Stage

FROM $BASEURL/dhi-python:3.13$RUNSHA AS uv-runtime-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=uv-build-stage \
    /app/venv venv

ENV PATH="/app/venv/bin:$PATH"

COPY app.py .

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]

## PIP build stage
FROM $BASEURL/dhi-python:3.13-dev$DEVSHA AS pip-build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt


## PIP Final stage
FROM $BASEURL/dhi-python:3.13$RUNSHA AS pip-runtime-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=pip-build-stage \
    /opt/python-${PYTHON_VERSION}/lib/python3.13/site-packages/ \
    /opt/python-${PYTHON_VERSION}/lib/python3.13/site-packages/
COPY app.py .
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]