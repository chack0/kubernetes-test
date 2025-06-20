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
# This copies everything from your Jenkins workspace's repo root into /home/jenkins/app
COPY . .

# --- DEBUGGING START: Check the SOURCE web/index.html ---
# List contents of the 'web' directory (where your source index.html should be)
RUN echo "--- Listing /home/jenkins/app/web (source directory) ---"
RUN ls -al /home/jenkins/app/web

# Attempt to print the content of the source index.html
RUN echo "--- Content of /home/jenkins/app/web/index.html (source file) ---"
RUN cat /home/jenkins/app/web/index.html
# --- DEBUGGING END ---


# Install dependencies for your Flutter app
RUN flutter pub get

# Build the web app
RUN flutter build web --release --no-tree-shake-icons

# --- WORKAROUND START: Explicitly copy index.html if Flutter isn't putting it there ---
# This command will copy the source index.html to the expected build output location.
RUN echo "--- Attempting to copy web/index.html to build/web/index.html as a workaround ---"
RUN cp web/index.html build/web/index.html
RUN echo "--- Verifying copied index.html in build/web ---"
RUN ls -al build/web/index.html
# --- WORKAROUND END ---


# --- DEBUGGING START: Check the BUILD OUTPUT (should now contain index.html) ---
# List contents of the 'build' directory (should contain 'web')
RUN echo "--- Listing /home/jenkins/app/build (output directory) ---"
RUN ls -al /home/jenkins/app/build

# List contents of the 'build/web' directory (should contain your compiled Flutter files AND index.html)
RUN echo "--- Listing /home/jenkins/app/build/web (compiled output) ---"
RUN ls -al /home/jenkins/app/build/web

# Attempt to print the content of the COMPILED index.html (this should now succeed!)
RUN echo "--- Content of /home/jenkins/app/build/web/index.html (compiled file) ---"
RUN cat /home/jenkins/app/build/web/index.html
# --- DEBUGGING END ---


# Stage 2: Serve the built app with Nginx
FROM nginx:alpine
# Copy the built Flutter app from the builder stage to Nginx's serving directory
COPY --from=builder /home/jenkins/app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]