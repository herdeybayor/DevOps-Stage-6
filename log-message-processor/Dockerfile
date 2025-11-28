# Dockerfile for Python Log Message Processor
FROM python:3.8-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

# No exposed port (background worker)

# Run the application
CMD ["python", "main.py"]

