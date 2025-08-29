# FluxRouter Backend Dockerfile
# Built from Alpine base for security and size 

FROM alpine:3.18

# Install Python and system dependencies
RUN apk add --no-cache \
    python3~=3.11 \
    py3-pip~=23.1 \
    py3-wheel~=0.40

# Create application user for security
RUN addgroup -g 1000 -S appuser && \
    adduser -u 1000 -S appuser -G appuser

# Set working directory
WORKDIR /app

# Copy requirements first
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Set proper ownership
RUN chown -R appuser:appuser /app

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/health')" || exit 1

# Switch to non-root user
USER appuser

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Start the application using gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "--log-level", "info", "app:app"]


