# Use an official Nginx image to serve the web app
FROM nginx:alpine

# Copy the build output from Flutter to the Nginx HTML folder
COPY build/web /usr/share/nginx/html

# Expose port 80 for the web app
EXPOSE 80