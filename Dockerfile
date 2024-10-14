FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install system dependencies (if needed)
RUN apt-get update && apt-get install -y \
    gcc \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the SSL certificate and key files
COPY wildcard-cert.pem /app/wildcard-cert.pem
COPY wildcard-key.pem /app/wildcard-key.pem

# Copy the rest of your application code
COPY . .

# Command to run your application
CMD ["python", "app.py"]

