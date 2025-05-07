FROM ubuntu:latest

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Add jenkins user and group (if it doesn't exist)
RUN groupadd -g 999 jenkins || true
RUN useradd -u 999 -g jenkins -m -d /home/jenkins jenkins || true

# Add jenkins user to the docker group
RUN usermod -aG docker jenkins

# Switch to the jenkins user for subsequent commands
USER jenkins

# Set the Flutter version (you can adjust this)
ARG FLUTTER_VERSION=stable
ARG FLUTTER_CHANNEL=$FLUTTER_VERSION

# Clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /home/jenkins/flutter

# Checkout the specified channel
RUN cd /home/jenkins/flutter && git checkout $FLUTTER_CHANNEL

# Set the Flutter environment variable and add it to PATH
ENV FLUTTER_HOME="/home/jenkins/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Download and cache web SDK (optional, but good for web builds)
RUN flutter doctor -v

# Set the working directory for your app
WORKDIR /home/jenkins/app

# Copy your Flutter app code into the container
COPY . .

# Install dependencies for your Flutter app
RUN flutter pub get

# Build the web app (you can adjust build commands based on your needs)
RUN flutter build web --release

# You might want to use a separate stage for serving the built web app
# For example, using a lightweight web server like Nginx

FROM nginx:alpine
COPY --from=1 /home/jenkins/app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]