# Use the official Ubuntu 20.04 as a parent image
FROM ubuntu:20.04

# Set environment variables to prevent prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install Node.js and npm
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    apt-get install -y build-essential && \
    curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /usr/src/app

# Copy the rest of the application code
COPY . .

RUN rm -rf node_modules
RUN npm install

# Expose the port the app runs on
EXPOSE 4000

# Define the command to run the application
CMD ["node", "app.js"]
# CMD ["tail", "-f", "/dev/null"]

