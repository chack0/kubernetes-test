FROM jenkins/inbound-agent:latest

USER root

# Install necessary dependencies for Flutter and file utility
RUN apt-get update && \
    apt-get install -y curl git xz-utils libglu1-mesa file

# Download Flutter SDK
RUN curl -f -L -o flutter_linux_arm64.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz

# Create Flutter install directory
RUN mkdir -p /opt/flutter

# Extract Flutter SDK and set ownership to jenkins user
RUN tar xf flutter_linux_arm64.tar.xz -C /opt/flutter --strip-components=1 && \
    rm flutter_linux_arm64.tar.xz && \
    chown -R jenkins:jenkins /opt/flutter

# Set Flutter environment variable for the jenkins user
ENV PATH="/opt/flutter/bin:${PATH}"

# Switch back to the jenkins user
USER jenkins
WORKDIR /home/jenkins/agent