#!/bin/bash

# FluxRouter Phase 2 Verification Script
# Validates ONLY Phase 2 specific objectives and requirements.
# Assumes Phase 1 is working and tests only the NEW Phase 2 features.

# Source the shared test library
source "$(dirname "$0")/test-lib.sh"

main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                FluxRouter Phase 2 Verification                    ║"
    echo "║  Validates Phase 2 specific objectives and requirements           ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}Starting Phase 2 verification at $(date)${NC}\n"
    echo -e "${CYAN}Note: This script assumes Phase 1 is working and tests only NEW Phase 2 features${NC}\n"
    
    print_header "PHASE 2 PREREQUISITES"
    run_test "Backend Directory Structure" "test -d ../backend && test -f ../backend/Dockerfile && test -f ../backend/app.py" ""
    run_test "Backend Container Present" "docker ps --format '{{.Names}}' | grep -q fluxrouter-backend" ""
    run_test "Updated Compose File" "grep -q 'fluxrouter-backend' ../docker-compose.yml" ""
    
    print_header "BACKEND API CONTAINER"
    run_test "Backend Container Running" "docker ps --format '{{.Names}} {{.Status}}' | grep fluxrouter-backend" "Up"
    run_test "Backend Health Check" "docker inspect --format='{{.State.Health.Status}}' fluxrouter-backend" "healthy"
    run_test "Backend Internal Port" "docker ps --format '{{.Names}} {{.Ports}}' | grep fluxrouter-backend" "5000/tcp"
    run_test "Backend Not Externally Exposed" "! docker ps --format '{{.Names}} {{.Ports}}' | grep fluxrouter-backend | grep -q '0.0.0.0'" ""
    
    print_header "NGINX PROXY ROUTING - API ENDPOINTS"
    run_test "API Health Endpoint" "curl -s http://localhost/api/health" '"status":"ok"' "true"
    run_test "API Info Endpoint" "curl -s http://localhost/api/info" "FluxRouter Backend API" "true"
    run_test "API Status Endpoint" "curl -s http://localhost/api/status" "environment" "true"
    run_test "API Version Information" "curl -s http://localhost/api/info" '"version":"2.0.0"' ""
    
    print_header "ENVIRONMENT VARIABLES"
    run_test "Environment File Exists" "test -f ../.env" ""
    run_test "Backend Environment Variables" "docker exec fluxrouter-backend env | grep FLASK_ENV" "FLASK_ENV"
    run_test "Secret Key Configuration" "docker exec fluxrouter-backend env | grep SECRET_KEY" "SECRET_KEY"
    
    print_header "HEALTH CHECKS - PHASE 2"
    run_test "Backend Docker Health Check" "docker inspect fluxrouter-backend --format='{{.Config.Healthcheck.Test}}'" "api/health"
    run_test "Backend Health via Proxy" "curl -s http://localhost/api/health | jq -r '.service'" "fluxrouter-backend"
    run_test "Backend Response Time" "time curl -s http://localhost/api/health >/dev/null" "real"
    
    print_header "INTERNAL COMMUNICATION - PHASE 2"
    run_test "Proxy to Backend Network" "docker exec fluxrouter-proxy ping -c 2 backend" "2 packets transmitted, 2 packets received"
    run_test "Backend Service Name Resolution" "docker exec fluxrouter-proxy nslookup backend" "backend"
    run_test "Backend Port Accessibility" "docker exec fluxrouter-proxy nc -z backend 5000" ""
    
    print_header "API CONTENT VALIDATION"
    run_test "Health Endpoint JSON Structure" "curl -s http://localhost/api/health | jq -r '.timestamp'" "2025"
    run_test "Info Endpoint Lists All APIs" "curl -s http://localhost/api/info | jq -r '.endpoints[]' | wc -l" "3"
    run_test "Status Endpoint Shows Environment" "curl -s http://localhost/api/status | jq -r '.environment'" "development"
    
    print_header "NGINX ROUTING CONFIGURATION"
    run_test "API Route Configuration" "docker exec fluxrouter-proxy grep -q 'location /api/' /etc/nginx/nginx.conf" ""
    run_test "Backend Upstream Configuration" "docker exec fluxrouter-proxy grep -q 'backend_api' /etc/nginx/nginx.conf" ""
    run_test "Proxy Pass to Backend" "docker exec fluxrouter-proxy grep -q 'proxy_pass.*backend' /etc/nginx/nginx.conf" ""
    
    print_header "DIRECT ACCESS BLOCKING - PHASE 2"
    local backend_ip
    backend_ip=$(docker inspect fluxrouter-backend --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | head -1)
    run_failure_test "Direct Backend HTTP Access" "timeout 5 curl -s --connect-timeout 3 http://$backend_ip:5000" "timeout"
    run_failure_test "Direct Backend API Access" "timeout 5 curl -s --connect-timeout 3 http://$backend_ip:5000/api/health" "timeout"

    # --- Summary ---
    print_summary
    echo -e "\n${GREEN}${BOLD}🎉 ALL PHASE 2 TESTS PASSED!${NC}"
    echo -e "${GREEN}✅ Backend API container deployed and working${NC}"
    echo -e "${GREEN}✅ NGINX routing updated for /api endpoints${NC}"
    echo -e "${GREEN}✅ Environment variable management implemented${NC}"
    echo -e "${GREEN}✅ Health checks working for all services${NC}"
    echo -e "${GREEN}✅ Phase 2 requirements fully met${NC}"
}

# Execute the main function
main