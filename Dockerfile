FROM ubuntu:latest AS builder

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Docker (This is likely unnecessary for just building a Flutter web app)
# RUN apt-get update && apt-get install -y --no-install-recommends ...

# Add jenkins user and group (This is also likely unnecessary within the build container)
# RUN groupadd -g 999 jenkins || true
# RUN useradd -u 999 -g jenkins -m -d /home/jenkins jenkins || true
# RUN usermod -aG docker jenkins
# USER jenkins

# Set the Flutter version
ARG FLUTTER_VERSION=stable
ARG FLUTTER_CHANNEL=$FLUTTER_VERSION

# Clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /home/jenkins/flutter

# Checkout the specified channel
RUN cd /home/jenkins/flutter && git checkout $FLUTTER_CHANNEL

# Set the Flutter environment variable and add it to PATH
ENV FLUTTER_HOME="/home/jenkins/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Download and cache web SDK
RUN flutter doctor -v

# Set the working directory for your app
WORKDIR /home/jenkins/app

# Copy your Flutter app code into the container
COPY . .

# Install dependencies for your Flutter app
RUN flutter pub get

# Build the web app
RUN flutter build web --release

# Stage 2: Serve the built app with Nginx
FROM nginx:alpine
COPY --from=builder /home/jenkins/app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]