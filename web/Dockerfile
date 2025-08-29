# Build from Alpine Linux for minimal footprint
FROM alpine:3.18

# Install NGINX and create necessary directories
RUN apk add --no-cache \
    nginx~=1.24 \
    wget~=1.21 && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/lib/nginx/tmp && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /usr/share/nginx/html

# Set proper ownership for nginx user (already created by nginx package)
RUN chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /var/lib/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html

# Copy static content
COPY src/ /usr/share/nginx/html/

# Copy NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chmod 644 /usr/share/nginx/html/* && \
    chmod 644 /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Run as non-root user
USER nginx

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]

