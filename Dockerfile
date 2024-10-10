# Use the official Jenkins base image
FROM jenkins/jenkins:lts

# Switch to the root user
USER root

# Update package lists and install Git and Docker
RUN apt-get update && \
    apt-get install -y git docker.io && \
    apt-get clean

# Copy SSH key and set permissions
COPY /path/to/your/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Add GitHub to known hosts
RUN ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# Switch back to the Jenkins user
USER jenkins

