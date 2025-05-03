FROM jenkins/inbound-agent:latest

USER root

# Install necessary dependencies for Flutter and file utility, including sudo
RUN apt-get update && \
    apt-get install -y curl git xz-utils libglu1-mesa file sudo

# Download Flutter SDK with error checking and verification
RUN curl -f -L -o flutter_linux_arm64.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz || exit 1
RUN ls -l flutter_linux_arm64.tar.xz
RUN file flutter_linux_arm64.tar.xz

# Extract Flutter SDK
RUN mkdir -p /opt/flutter && \
    tar xf flutter_linux_arm64.tar.xz -C /opt/flutter --strip-components=1 && \
    rm flutter_linux_arm64.tar.xz

# Set Flutter environment variable
ENV PATH="$PATH:/opt/flutter/bin"

# Switch back to the jenkins user
USER jenkins
WORKDIR /home/jenkins/agent