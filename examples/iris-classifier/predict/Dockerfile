# Serving container for Vertex AI Online Predictions
FROM python:3.11-slim

WORKDIR /app

# Install curl for health check probing
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY predict.py .

# Expose default Vertex AI serving port
EXPOSE 8080

# Environment variables with Vertex AI defaults
ENV AIP_HTTP_PORT=8080
ENV AIP_HEALTH_ROUTE=/health
ENV AIP_PREDICT_ROUTE=/predict

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["uvicorn", "predict:app", "--host", "0.0.0.0", "--port", "8080"]
