#!/usr/bin/env python3
"""
FluxRouter Backend API
Secure Flask application providing API endpoints for the FluxRouter.
"""

import os
import logging
from datetime import datetime
from flask import Flask, jsonify
from werkzeug.exceptions import HTTPException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Security configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-key-change-in-production')
app.config['DEBUG'] = os.environ.get('DEBUG', 'False').lower() == 'true'


# Security headers middleware
@app.after_request
def add_security_headers(response):
    """Add security headers to all responses"""
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    # Remove server identification
    response.headers.pop('Server', None)
    return response


# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint for container health monitoring"""
    try:
        health_data = {
            'status': 'ok',
            'timestamp': datetime.utcnow().isoformat(),
            'version': '2.0.0',
            'service': 'fluxrouter-backend'
        }
        logger.info("Health check requested - status: ok")
        return jsonify(health_data), 200
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({'status': 'error', 'message': 'Health check failed'}), 500


# Additional API endpoints for demonstration
@app.route('/api/info', methods=['GET'])
def api_info():
    """API information endpoint"""
    info_data = {
        'name': 'FluxRouter Backend API',
        'version': '2.0.0',
        'description': 'Backend service with API endpoints',
        'endpoints': [
            '/api/health',
            '/api/info',
            '/api/status'
        ]
    }
    return jsonify(info_data), 200


@app.route('/api/status', methods=['GET'])
def api_status():
    """System status endpoint"""
    status_data = {
        'uptime': 'available',
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'debug_mode': app.config['DEBUG'],
        'request_count': 'not_tracked'  # Could be improved with Redis/database
    }
    return jsonify(status_data), 200


# Error handlers
@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found',
        'status_code': 404
    }), 404


@app.errorhandler(405)
def method_not_allowed(error):
    """Handle 405 errors"""
    return jsonify({
        'error': 'Method Not Allowed',
        'message': 'The method is not allowed for this resource',
        'status_code': 405
    }), 405


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An internal server error occurred',
        'status_code': 500
    }), 500


# Handle all other HTTP exceptions
@app.errorhandler(HTTPException)
def handle_http_exception(error):
    """Handle all other HTTP exceptions"""
    return jsonify({
        'error': error.name,
        'message': error.description,
        'status_code': error.code
    }), error.code


if __name__ == '__main__':
    # Get configuration from environment
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'

    logger.info(f"Starting FluxRouter Backend API on {host}:{port}")
    logger.info(f"Debug mode: {debug}")

    # Run the application
    app.run(host=host, port=port, debug=debug)