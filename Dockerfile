FROM nginx:stable-alpine

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy the built Flutter web app to the Nginx static files directory
COPY build/web /usr/share/nginx/html

# Expose port 80 for the web app
EXPOSE 80

# Optionally, you can add custom Nginx configuration here if needed
# COPY nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]