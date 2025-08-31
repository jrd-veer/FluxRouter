#!/usr/bin/env python3
"""
Unit tests for FluxRouter Backend API
"""

import unittest
import json
from app import app


class FluxRouterBackendTests(unittest.TestCase):
    """Test cases for the FluxRouter Backend API"""

    def setUp(self):
        """Set up test client"""
        self.app = app.test_client()
        self.app.testing = True

    def test_health_check_endpoint(self):
        """Test the health check endpoint"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'ok')
        self.assertEqual(data['service'], 'fluxrouter-backend')
        self.assertIn('timestamp', data)
        self.assertIn('version', data)

    def test_api_info_endpoint(self):
        """Test the API info endpoint"""
        response = self.app.get('/api/info')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['name'], 'FluxRouter Backend API')
        self.assertIn('version', data)
        self.assertIn('endpoints', data)
        self.assertIsInstance(data['endpoints'], list)

    def test_api_status_endpoint(self):
        """Test the API status endpoint"""
        response = self.app.get('/api/status')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertIn('uptime', data)
        self.assertIn('environment', data)
        self.assertIn('debug_mode', data)

    def test_404_error_handler(self):
        """Test 404 error handling"""
        response = self.app.get('/api/nonexistent')
        self.assertEqual(response.status_code, 404)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Not Found')
        self.assertEqual(data['status_code'], 404)

    def test_405_error_handler(self):
        """Test 405 error handling"""
        response = self.app.post('/api/health')  # POST to GET-only endpoint
        self.assertEqual(response.status_code, 405)
        
        data = json.loads(response.data)
        self.assertEqual(data['error'], 'Method Not Allowed')
        self.assertEqual(data['status_code'], 405)

    def test_security_headers(self):
        """Test that security headers are present"""
        response = self.app.get('/api/health')
        
        # Check security headers
        self.assertEqual(response.headers.get('X-Content-Type-Options'), 'nosniff')
        self.assertEqual(response.headers.get('X-XSS-Protection'), '1; mode=block')
        self.assertEqual(response.headers.get('X-Frame-Options'), 'DENY')
        self.assertEqual(response.headers.get('Referrer-Policy'), 'strict-origin-when-cross-origin')
        
        # Server header should be removed
        self.assertIsNone(response.headers.get('Server'))

    def test_content_type_json(self):
        """Test that API endpoints return JSON content type"""
        endpoints = ['/api/health', '/api/info', '/api/status']
        
        for endpoint in endpoints:
            with self.subTest(endpoint=endpoint):
                response = self.app.get(endpoint)
                self.assertEqual(response.content_type, 'application/json')


if __name__ == '__main__':
    unittest.main()

