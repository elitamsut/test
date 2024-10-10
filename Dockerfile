# Use the official Python image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install the required packages (Flask)
RUN pip install --no-cache-dir flask

# Expose port 8080 to the outside world
EXPOSE 8080

# Run app.py when the container launches
CMD ["python", "app.py"]

