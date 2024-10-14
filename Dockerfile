# Use an official Python runtime as a base image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Flask and Werkzeug specific versions
RUN pip install --upgrade pip && \
    pip install Flask==2.0.3 Werkzeug==2.0.3

# Copy the SSL certificate and key into the container
COPY wildcard-cert.pem /app/wildcard-cert.pem
COPY wildcard-key.pem /app/wildcard-key.pem

# Ensure the SSL files have appropriate permissions
RUN chmod 600 /app/wildcard-cert.pem /app/wildcard-key.pem

# Expose port 8080 for Flask app (or the port you're using)
EXPOSE 8080

# Define environment variable for Flask
ENV FLASK_APP=app.py

# Run the Flask app with SSL
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]

