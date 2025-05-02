FROM nginx:stable-alpine

# Copy the built web app from the builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80 for the web app
EXPOSE 80

# Default command to start nginx
CMD ["nginx", "-g", "daemon off;"]

# Builder stage to build the Flutter web app
FROM flutter:stable as builder
WORKDIR /app
COPY . .
RUN flutter build web --release