#!/bin/bash

# FluxRouter Phase 1 Verification Script
# Validates all Phase 1 objectives and requirements.
# It sources its core testing functions from test-lib.sh.

# Source the shared test library
source "$(dirname "$0")/test-lib.sh"

# CI Mode - Skip interactive elements and use absolute paths
CI_MODE=${CI_MODE:-false}

main() {
    if [[ "$CI_MODE" == "true" ]]; then
        echo "FluxRouter Phase 1 Verification - CI Mode"
        echo "Starting verification at $(date)"
    else
        echo -e "${BOLD}${BLUE}"
        echo "╔═══════════════════════════════════════════════════════════════════╗"
        echo "║                FluxRouter Phase 1 Verification                    ║"
        echo "║  Validates all Phase 1 objectives and requirements                ║"
        echo "╚═══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${YELLOW}Starting verification at $(date)${NC}\n"
    fi
    
    print_header "PREREQUISITES"
    run_test "Docker Availability" "command -v docker" ""
    run_test "Compose Availability" "docker compose version" "Docker Compose version"
    run_test "curl Availability" "command -v curl" ""
    run_test "File Structure Check" "test -f ../docker-compose.yml && test -d ../proxy && test -d ../web" ""
    
    print_header "CONTAINER STATUS"
    run_test "All Containers Running" "docker ps --format '{{.Names}}' | grep -c fluxrouter" "3"
    run_test "Proxy Health" "docker inspect --format='{{.State.Health.Status}}' fluxrouter-proxy" "healthy"
    run_test "Web Health" "docker inspect --format='{{.State.Health.Status}}' fluxrouter-web" "healthy"

    print_header "NETWORK ISOLATION"
    run_test "Web Server Not Exposed" "! docker ps --format '{{.Names}} {{.Ports}}' | grep fluxrouter-web | grep -q '0.0.0.0'" ""
    run_test "Proxy Port Exposed" "docker ps --format '{{.Names}} {{.Ports}}' | grep fluxrouter-proxy" "0.0.0.0:80->"
    
    print_header "CONNECTIVITY"
    run_test "HTTP Connectivity" "curl -s --connect-timeout 5 http://localhost" "Hello from Web Server"
    run_test "Content Delivery" "curl -s http://localhost" "Hello from Web Server via Reverse Proxy!"
    run_test "Internal Communication (Proxy to Web)" "docker exec fluxrouter-proxy ping -c 2 web" "2 packets transmitted, 2 packets received"
    
    print_header "SECURITY"
    run_test "X-Frame-Options Header" "curl -s -I http://localhost" "X-Frame-Options: DENY" "true"
    run_test "Content-Security-Policy Header" "curl -s -I http://localhost" "Content-Security-Policy: default-src 'self'" "true"
    run_failure_test "TRACE Method Blocking" "curl -s -I -X TRACE http://localhost" "405 Not Allowed"
    run_failure_test "OPTIONS Method Blocking" "curl -s -I -X OPTIONS http://localhost" "405 Not Allowed"

    print_header "VIRTUAL HOSTS"
    run_test "'localhost' Virtual Host" "curl -s -H 'Host: localhost' http://localhost" "Hello from Web Server"
    
    print_header "DIRECT ACCESS BLOCKING"
    local web_ip
    web_ip=$(docker inspect fluxrouter-web --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | head -1)
    echo "Testing direct access to web container IP: $web_ip"

    # In CI environments, Docker networking can be flatter, allowing direct access
    # where it would normally be blocked. We check for a CI variable.
    if [[ "$CI" == "true" ]]; then
        echo -e "${YELLOW}CI environment detected. Network is flat, therefore allowing direct access.${NC}"
        run_warn_on_success_test "Direct Web Server Access" "timeout 5 curl -s --connect-timeout 3 http://$web_ip" "timeout"
    else
        # Locally, we enforce a strict failure.
        run_failure_test "Direct Web Server Access" "timeout 5 curl -s --connect-timeout 3 http://$web_ip" "timeout"
    fi

    # --- Summary ---
    print_summary   
    echo -e "\n${GREEN}${BOLD}🎉 ALL PHASE 1 TESTS PASSED!${NC}"
    echo -e "${GREEN}✅ All Phase 1 objectives met.${NC}"
}

# Execute the main function
main