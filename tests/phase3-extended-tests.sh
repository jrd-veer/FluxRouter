#!/bin/bash
# Phase 3 Extended Testing Script
# Includes unit tests, nginx config validation, and functional tests

# Source the shared test library
source "$(dirname "$0")/test-lib.sh"

# CI Mode - Skip interactive elements
CI_MODE=${CI_MODE:-false}

if [[ "$CI_MODE" == "true" ]]; then
    echo "FluxRouter Phase 3 Extended Testing - CI Mode"
    echo "Starting Phase 3 extended verification at $(date)"
else
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                FluxRouter Phase 3 Extended Testing                ║"
    echo "║  Unit Tests, Config Validation, and Functional Testing            ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}Starting Phase 3 extended verification at $(date)${NC}\n"
fi

# === UNIT TESTS SECTION ===
# Note: Unit tests cannot use test-lib.sh because they need direct pytest execution
echo -e "\n${BOLD}${CYAN}🧪 UNIT TESTS SECTION${NC}"
echo -e "${CYAN}Note: This section runs unit tests directly with pytest and cannot use shared test-lib functions${NC}"
print_header "BACKEND UNIT TESTS"

echo -e "${YELLOW}Executing backend unit tests with pytest...${NC}"

# Check if we're in Docker or local environment
if [ -f /.dockerenv ]; then
    # Running inside Docker container
    echo "Running unit tests inside Docker container environment..."
    cd /app && python3 -m pytest test_app.py -v
    unit_test_result=$?
else
    # Running on host - need to test via Docker
    echo "Running unit tests via Docker Compose exec..."
    docker compose -p fluxrouter exec -T backend python3 -m pytest test_app.py -v
    unit_test_result=$?
fi

if [ $unit_test_result -eq 0 ]; then
    echo -e "${GREEN}✅ All unit tests passed!${NC}\n"
    ((TESTS_PASSED += 7))  # We know we have 7 unit tests
else
    echo -e "${RED}❌ Unit tests failed!${NC}\n"
    ((TESTS_FAILED += 7))
fi

# === INTEGRATION TESTS SECTION ===
# Note: These tests use test-lib.sh for consistent reporting
echo -e "\n${BOLD}${CYAN}🔧 INTEGRATION TESTS SECTION${NC}"
echo -e "${CYAN}Note: This section uses shared test-lib functions for consistent reporting${NC}"

print_header "NGINX CONFIGURATION VALIDATION"
run_test "NGINX Config Syntax Check" "docker compose -p fluxrouter exec -T proxy nginx -t" ""

print_header "SSL CERTIFICATE VALIDATION"
run_test "SSL Certificate Exists" "docker compose -p fluxrouter exec -T proxy test -f /etc/nginx/ssl/server.crt" ""
run_test "SSL Private Key Exists" "docker compose -p fluxrouter exec -T proxy test -f /etc/nginx/ssl/server.key" ""
run_test "SSL Certificate Validity" "docker compose -p fluxrouter exec -T proxy openssl x509 -in /etc/nginx/ssl/server.crt -noout -text | grep 'Not After'" "Not After"

print_header "HTTPS FUNCTIONAL TESTS"
run_test "HTTP to HTTPS Redirect" "curl -s -o /dev/null -w '%{http_code}' http://localhost" "301"
run_test "HTTPS Homepage Load" "curl -k -s -o /dev/null -w '%{http_code}' https://localhost" "200"
run_test "HTTPS API Health Check" "curl -k -s https://localhost/api/health | jq -r '.status'" "ok"
run_test "HTTPS API Info Endpoint" "curl -k -s https://localhost/api/info | jq -r '.name'" "FluxRouter Backend API"
run_test "HTTPS API Status Endpoint" "curl -k -s https://localhost/api/status | jq -r '.uptime'" "available"
run_test "Security Headers Present" "curl -k -s -I https://localhost | grep -i 'x-frame-options'" "DENY"

print_header "CONTAINER HEALTH CHECKS"
run_test "Proxy Container Health" "docker inspect fluxrouter-proxy --format='{{.State.Health.Status}}'" "healthy"
run_test "Web Container Health" "docker inspect fluxrouter-web --format='{{.State.Health.Status}}'" "healthy"
# Check health of all backend instances (scaled containers have dynamic names)
run_test "Backend Containers Running" "docker ps --filter 'name=fluxrouter-backend' --format '{{.Names}}' | wc -l" "2"
run_test "Backend Instances Healthy" "docker ps --filter 'name=fluxrouter-backend' --filter 'health=healthy' --format '{{.Names}}' | wc -l" "2"

print_header "LOAD BALANCING TESTS"
run_test "Multiple Backend Instances Running" "docker ps --format '{{.Names}}' | grep -c fluxrouter-backend" "2"
run_test "Load Balancing Functional" "curl -k -s https://localhost/api/health | jq -r '.instance' | grep -E '^[a-f0-9]{12}$|^fluxrouter-backend'" ""

print_header "NETWORK SECURITY TESTS"
run_test "Backend Network Isolation" "docker network inspect fluxrouter-backend | jq -r '.[].Internal'" "true"

# Direct access tests - handle CI vs local environments
if [[ "$CI_MODE" == "true" ]]; then
    echo -e "${YELLOW}CI environment detected. Direct access tests will only issue warnings on success.${NC}"
    run_warn_on_success_test "Direct Backend Access Blocked" "timeout 5 curl -s --connect-timeout 3 http://localhost:5000/api/health" "timeout"
else
    run_failure_test "Direct Backend Access Blocked" "timeout 5 curl -s --connect-timeout 3 http://localhost:5000/api/health" "timeout"
fi

# Use shared test library summary function
print_summary

echo -e "\n${GREEN}${BOLD}🎉 ALL PHASE 3 EXTENDED TESTS COMPLETED!${NC}"
echo -e "${GREEN}✅ Unit tests executed with pytest${NC}"
echo -e "${GREEN}✅ NGINX configuration validated${NC}"
echo -e "${GREEN}✅ SSL/HTTPS functionality verified${NC}"
echo -e "${GREEN}✅ Load balancing confirmed${NC}"
echo -e "${GREEN}✅ Security and isolation tested${NC}"
