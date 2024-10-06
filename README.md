# Flask Hello World Application

This is a simple Flask application that returns "Hello, World!" when accessed. It is packaged as a Helm chart for easy deployment on Kubernetes.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Accessing the Application](#accessing-the-application)

## Prerequisites

- Kubernetes cluster (e.g., k3d)
- Helm installed on your local machine
- `kubectl` installed and configured to connect to your Kubernetes cluster

## Installation

To install the Helm chart for this application, follow these steps:

1. Clone this repository:

   ```bash
   git clone https://github.com/elitamsut/test.git
   cd test/flask-hello-world
   helm install flask-hello-world .


## Accessing the Application
http://customer2-app-127-0-0-1.nip.io:8080/
