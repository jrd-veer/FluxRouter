# FluxRouter - Containerized Web Platform

A fully containerized web platform built with modern DevOps practices, featuring a secure reverse proxy architecture, a dynamic API service, and a fully automated CI/CD pipeline.

## 📋 Project Phases

### ✅ Phase 1: Basic Level (Completed)

- Reverse proxy with NGINX
- Static web server container
- Docker Compose orchestration
- Security hardening & Network isolation

### ✅ Phase 2: Intermediate Level (Completed)

- Flask backend API with health endpoints
- Updated NGINX routing for API traffic
- Environment variable management
- Health checks for all services
- GitHub Actions CI/CD pipeline

### ✅ Phase 3: Expert Level (Completed)

- HTTPS with self-signed certificates
- HTTP to HTTPS redirection
- Unit tests for backend application
- Extended testing suite
- Custom backend image from Alpine
- Advanced CI/CD pipeline
- Horizontal scaling with Docker Compose
- Failure handling & load balancing

---

## 🏛️ Architecture and Design

The platform is designed around a classic reverse proxy model, providing a secure and scalable foundation. All inbound traffic is handled by a single NGINX proxy that routes requests to the appropriate internal services, which are completely isolated from the host machine.

### Overall Architecture

```mermaid
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'background': '#1A202C',
      'primaryColor': '#2D3748',
      'secondaryColor': '#4A5568',
      'primaryTextColor': '#F7FAFC',
      'secondaryTextColor': '#F7FAFC',
      'tertiaryTextColor': '#F7FAFC',
      'lineColor': '#81E6D9',
      'textColor': '#F7FAFC',
      'mainBkg': '#2D3748',
      'errorBkgColor': '#E06C75',
      'errorTextColor': '#F7FAFC',
      'clusterBkg': '#4A5568',
      'clusterBorder': '#81E6D9',
      'nodeBorder': '#81E6D9',
      'defaultLinkColor': '#81E6D9'
    }
  }
}%%
graph TB
    subgraph "Host Machine"
        Client[Client Browser]
    end

    subgraph "Docker Network: fluxrouter-frontend"
        Proxy[NGINX Reverse Proxy<br/>Port 80 Exposed]
    end

    subgraph "Docker Network: fluxrouter-backend"
        Web[NGINX Web Server<br/>Port 80 Internal]
        Backend[Flask API Server<br/>Port 5000 Internal]
    end

    Client -- "HTTP :80" --> Proxy
    Proxy -- "/ requests" --> Web
    Proxy -- "/api/ requests" --> Backend

    style Client fill:#2D3748,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC
    style Proxy fill:#4A5568,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC
    style Web fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style Backend fill:#2D3748,stroke:#4A5568,color:#F7FAFC
```

### Network Isolation

Network security is a key design feature, achieved using two custom Docker networks:

- **`fluxrouter-frontend`**: The external network for the reverse proxy. It's the only service with a port exposed to the host machine.
- **`fluxrouter-backend`**: A completely internal network. Services within this network are not reachable from the host, forcing all traffic through the security layers of the proxy.

```mermaid
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'background': '#111111',
      'primaryColor': '#2D3748',
      'secondaryColor': '#4A5568',
      'primaryTextColor': '#F7FAFC',
      'secondaryTextColor': '#F7FAFC',
      'tertiaryTextColor': '#F7FAFC',
      'lineColor': '#81E6D9',
      'textColor': '#F7FAFC',
      'mainBkg': '#2D3748',
      'clusterBkg': '#1A202C',
      'clusterBorder': '#81E6D9',
      'nodeBorder': '#81E6D9',
      'defaultLinkColor': '#81E6D9',
      'noteBkgColor': '#1A202C',
      'noteTextColor': '#F7FAFC',
      'noteBorderColor': '#4A5568'
    }
  }
}%%
graph TD
    subgraph "Host Machine"
        direction LR
        P((Port 80))
    end

    subgraph "Docker Environment"
        direction LR
        subgraph "fluxrouter-frontend Network"
            Proxy[Reverse Proxy Container]
        end

        subgraph "fluxrouter-backend Network (Internal)"
            Web[Web Container]
            Backend[API Container]
        end
    end

    P -- "Exposed" --> Proxy
    Proxy -- "Forwards /" --> Web
    Proxy -- "Forwards /api" --> Backend

    subgraph "Note on Isolation"
      note["Web & API containers are not<br/>accessible from the Host Machine.<br/>They can only be reached via the Proxy."]
    end

    style Host fill:#1A202C,stroke:#4A5568,color:#F7FAFC
    style P fill:#81E6D9,stroke:#1A202C,color:#1A202C,stroke-width:2px
    style Proxy fill:#4A5568,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC
    style Web fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style Backend fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style note fill:#1A202C,stroke:#4A5568,color:#F7FAFC
    style frontend fill:#1A202C,stroke:#81E6D9,color:#81E6D9
    style backend fill:#1A202C,stroke:#81E6D9,color:#81E6D9
```

---

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Git

### Scaling Backend Services

FluxRouter supports horizontal scaling of backend services:

```bash
# Start with 2 backend instances
docker compose up --scale backend=2 -d
```

See [Scaling Guide](docs/scaling.md) for more details.

### Running the Platform

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd FluxRouter

# 2. Run the setup script to create your .env file and generate a secret key
./setup.sh

# 3. Start all services
docker compose up -d

# 4. Check service status
docker compose ps
```

---

## 🔧 Services Breakdown

### Reverse Proxy (NGINX)

- **Image**: Custom NGINX on Alpine Linux.
- **Function**: The single entry point for all traffic. Routes requests, applies security policies, and terminates client connections.
- **Health Check**: `GET /health`
- **Security**: Blocks unwanted HTTP methods (TRACE, OPTIONS) and adds security headers.

### Web Server (NGINX)

- **Image**: Custom NGINX on Alpine Linux.
- **Function**: Serves the static HTML front-end content.
- **Health Check**: `GET /`
- **Access**: Internal network only. Cannot be accessed directly from the host.

### Backend API (Flask)

- **Image**: Custom Python 3 on Alpine, with Gunicorn for production.
- **Function**: Provides a RESTful API.
- **Health Check**: `GET /api/health`
- **Endpoints**:
  - `GET /api/health`: Confirms the service is running.
  - `GET /api/info`: Provides API metadata.
  - `GET /api/status`: Shows current application status.
- **Access**: Internal network only.

---

## 🧪 Testing

### Manual Testing

Once the platform is running, you can test the different components.

```bash
# Test the web server
curl http://localhost/

# Test the API health endpoint
curl http://localhost/api/health | jq .

# Test API info endpoint
curl http://localhost/api/info | jq .

# Test for security headers
curl -I http://localhost/

# Verify that dangerous HTTP methods are blocked (should return 405 Not Allowed)
curl -X TRACE http://localhost/
```

### Automated Testing & CI/CD

The project includes two test scripts for local validation:

- `./tests/phase1-verify.sh`: Validates all Phase 1 objectives.
- `./tests/phase2-verify.sh`: Performs quick checks on Phase 2 functionality.

For comprehensive, automated testing, the GitHub Actions CI/CD pipeline is used.

---

## 🚀 CI/CD Pipeline

The GitHub Actions pipeline automates the validation, testing, and security scanning of the entire platform on every push to the `master` or `dev` branches.

### Pipeline Visualization

```mermaid
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'background': '#1A202C',
      'primaryColor': '#2D3748',
      'secondaryColor': '#4A5568',
      'primaryTextColor': '#F7FAFC',
      'secondaryTextColor': '#F7FAFC',
      'tertiaryTextColor': '#F7FAFC',
      'lineColor': '#81E6D9',
      'textColor': '#F7FAFC',
      'mainBkg': '#2D3748',
      'clusterBkg': '#4A5568',
      'clusterBorder': '#81E6D9',
      'nodeBorder': '#81E6D9',
      'defaultLinkColor': '#81E6D9'
    }
  }
}%%
graph TD;
    subgraph "GitHub Repository"
        A[Push to 'master' or 'dev'] --> B{GitHub Actions};
    end

    subgraph "CI/CD Pipeline on Ubuntu Runner"
        B --> C{1. Lint & Validate};
        C --> D{2. Build & Test};
        D --> E{3. Security Scan};
    end

    subgraph "Lint & Validate Job"
        C --> C1[yamllint];
        C --> C2[hadolint];
        C --> C3[flake8];
        C --> C4[docker-compose config];
    end

    subgraph "Build & Test Job"
        D --> D1[Build Images];
        D1 --> D2[Run Containers];
        D2 --> D3[Run Automated Tests];
        D3 --> D4[Cleanup];
    end

    subgraph "Security Scan Job ('master' only)"
        E --> E1[Trivy Vulnerability Scan];
        E1 --> E2[Upload SARIF Report];
    end

    %% Styling
    style A fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style B fill:#81E6D9,stroke:#2D3748,color:#1A202C
    style C fill:#4A5568,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC
    style D fill:#4A5568,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC
    style E fill:#4A5568,stroke:#81E6D9,stroke-width:2px,color:#F7FAFC

    style C1,C2,C3,C4 fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style D1,D2,D3,D4 fill:#2D3748,stroke:#4A5568,color:#F7FAFC
    style E1,E2 fill:#2D3748,stroke:#4A5568,color:#F7FAFC
```

### Pipeline Stages

1. **Lint & Validate**: Checks all source code for style errors and syntax issues (`flake8`, `yamllint`, `hadolint`).
2. **Build & Test**: Builds all Docker images, runs the full container stack, and executes a suite of integration tests against the live services.
3. **Security Scan**: On pushes to `master`, it runs a Trivy vulnerability scan against the codebase and Docker images.

---

## 🔒 Security Features

### Network Security

- ✅ **Internal-only Networks**: The `web` and `backend` services are on an internal network and cannot be reached from the host.
- ✅ **Single Entry Point**: The only way to access the system is through the reverse proxy on port 80.

### Application Security

- ✅ **Security Headers**: The reverse proxy adds key security headers like `X-Frame-Options` and `Content-Security-Policy`.
- ✅ **HTTP Method Filtering**: Dangerous methods like `TRACE` and `OPTIONS` are blocked.
- ✅ **Non-Root Execution**: All containers run their processes as an unprivileged user.

### Infrastructure Security

- ✅ **Minimal Base Images**: All images are built on `alpine` to reduce the attack surface.
- ✅ **Health Checks**: Docker health checks ensure that failing containers are automatically restarted.
- ✅ **Automated Scanning**: The CI/CD pipeline includes vulnerability scanning.

---

## 🔧 Configuration

### Environment Variables

Configuration is managed through a `.env` file, which is created from `env.example`.

- `ENVIRONMENT`: Sets the application environment (e.g., `development`).
- `FLASK_ENV`: Sets the Flask environment (`production` or `development`).
- `DEBUG`: Toggles debug mode (`true` or `false`).
- `SECRET_KEY`: A long, random string used for cryptographic signing.

> **Note:** The `.env` file should **never** be committed to version control.

---

## 📁 Project Structure

```
FluxRouter/
├── .github/workflows/    # CI/CD pipeline workflow
├── backend/              # Flask API service source
├── proxy/                # NGINX reverse proxy configuration
├── tests/                # Verification scripts
├── web/                  # Static web server source
├── docker-compose.yml    # Main service orchestration file
├── .env.example          # Template for environment variables
└── README.md             # This file
```
