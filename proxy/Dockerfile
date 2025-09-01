# Build from Alpine Linux
FROM alpine:3.18

# Install NGINX, OpenSSL and create directories
RUN apk add --no-cache \
    nginx~=1.24 \
    wget~=1.21 \
    openssl~=3.1 && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/lib/nginx/tmp && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp

# Set proper ownership for nginx user (already created by nginx package)
RUN chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /var/lib/nginx && \
    chown -R nginx:nginx /var/cache/nginx

# Copy NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Generate SSL certificate and set proper permissions
RUN mkdir -p /etc/nginx/ssl && \
    openssl genrsa -out /etc/nginx/ssl/server.key 2048 && \
    openssl req -new -x509 -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -days 365 \
        -subj "/C=US/ST=State/L=City/O=FluxRouter/OU=DevOps/CN=localhost" && \
    chown -R nginx:nginx /etc/nginx/ssl && \
    chmod 600 /etc/nginx/ssl/server.key && \
    chmod 644 /etc/nginx/ssl/server.crt && \
    chmod 644 /etc/nginx/nginx.conf

# Expose ports 80 and 443
EXPOSE 80 443

# Health check (use HTTP for internal health check to avoid SSL complexity)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run as non-root user
USER nginx

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]

