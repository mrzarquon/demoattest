FROM democbarker/dhi-python:3.13-dev AS build-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt

## -----------------------------------------------------
## Final stage
FROM democbarker/dhi-python:3.13 AS runtime-stage

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=build-stage \
    /opt/python-${PYTHON_VERSION}}/lib/python3.13/site-packages/ \
    /opt/python-${PYTHON_VERSION}/lib/python3.13/site-packages/
COPY app.py .
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host=0.0.0.0", "--port=8000"]