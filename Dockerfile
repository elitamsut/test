FROM jenkins/jenkins:lts

USER root

# Install git
RUN apt-get update && apt-get install -y git

# Copy SSH key and set permissions
COPY /path/to/your/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Add GitHub to known hosts
RUN ssh-keyscan -H github.com >> /root/.ssh/known_hosts

USER jenkins

