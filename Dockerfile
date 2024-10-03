# Use the smaller NGINX base image with fewer vulnerabilities
FROM nginx:alpine

# Set the working directory to /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

# Remove the default NGINX index page
RUN rm -rf ./*

# Copy your custom index.html to the NGINX HTML directory
COPY index.html .

# Create necessary NGINX cache directories with appropriate permissions
RUN mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx

# Ensure that NGINX does not run as root user
# Create a new non-root user and group
RUN addgroup -S nginxgroup && adduser -S nginxuser -G nginxgroup

# Change ownership of /usr/share/nginx/html to the new user
RUN chown -R nginxuser:nginxgroup /usr/share/nginx/html

# Change the permissions of index.html to read-only
RUN chmod 444 index.html

# Change NGINX PID file location to /tmp/nginx.pid where non-root can write
RUN sed -i 's|/var/run/nginx.pid|/tmp/nginx.pid|' /etc/nginx/nginx.conf

# Switch to non-root user
USER nginxuser

# Expose port 80 to be accessible from outside the container
EXPOSE 80

# Start the NGINX server
CMD ["nginx", "-g", "daemon off;"]
