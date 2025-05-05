FROM ubuntu:latest

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set the Flutter version (you can adjust this)
ARG FLUTTER_VERSION=stable
ARG FLUTTER_CHANNEL=$FLUTTER_VERSION

# Clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /opt/flutter

# Checkout the specified channel
RUN cd /opt/flutter && git checkout $FLUTTER_CHANNEL

# Set the Flutter environment variable and add it to PATH
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Download and cache web SDK (optional, but good for web builds)
RUN flutter doctor -v

# Set the working directory for your app
WORKDIR /app

# Copy your Flutter app code into the container
COPY . .

# Install dependencies for your Flutter app
RUN flutter pub get

# Build the web app (you can adjust build commands based on your needs)
RUN flutter build web --release

# You might want to use a separate stage for serving the built web app
# For example, using a lightweight web server like Nginx

FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]