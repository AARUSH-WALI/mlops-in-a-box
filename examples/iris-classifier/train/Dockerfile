# Training container for Vertex AI Custom Training Jobs
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY train.py .

# Vertex AI passes training environment variables such as AIP_MODEL_DIR
ENTRYPOINT ["python", "train.py"]
