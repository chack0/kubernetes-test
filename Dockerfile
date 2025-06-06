FROM ubuntu:latest AS builder

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

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
RUN flutter build web --release --no-tree-shake-icons

# --- DEBUGGING START: These lines are crucial for diagnosis ---
# List the contents of the 'build' directory (should contain 'web')
RUN echo "--- Listing /home/jenkins/app/build ---"
RUN ls -al /home/jenkins/app/build

# List the contents of the 'build/web' directory (should contain your Flutter files)
RUN echo "--- Listing /home/jenkins/app/build/web ---"
RUN ls -al /home/jenkins/app/build/web

# Attempt to print the content of index.html to ensure it's not empty or missing
RUN echo "--- Content of /home/jenkins/app/build/web/index.html ---"
RUN cat /home/jenkins/app/build/web/index.html
# --- DEBUGGING END ---

# Stage 2: Serve the built app with Nginx
FROM nginx:alpine
# Copy the built Flutter app from the builder stage to Nginx's serving directory
COPY --from=builder /home/jenkins/app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]