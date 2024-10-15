# Use an official Python runtime as a base image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Flask, Werkzeug, and Gunicorn
RUN pip install --upgrade pip && \
    pip install Flask==2.0.3 Werkzeug==2.0.3 gunicorn

# Copy the SSL certificate and key into the container
COPY wildcard-cert.pem /app/wildcard-cert.pem
COPY wildcard-key.pem /app/wildcard-key.pem

# Ensure the SSL files have appropriate permissions
RUN chmod 600 /app/wildcard-cert.pem /app/wildcard-key.pem

# Expose port 8080 for HTTPS
EXPOSE 8080

# Run Gunicorn with HTTPS enabled
CMD ["gunicorn", "-b", "0.0.0.0:8080", "--certfile=/app/wildcard-cert.pem", "--keyfile=/app/wildcard-key.pem", "app:app"]

