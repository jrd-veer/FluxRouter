## 🧭 Introduction

This Assessment assesses your ability to build a fully containerized platform using modern DevOps tools and practices. You will design, build, secure, and automate a multi-container setup from scratch, demonstrating skills in Docker, NGINX, Linux, and CI/CD. Your solution will evolve through multiple complexity levels, but must always maintain one key architectural requirement:

> **All web traffic must be routed through a reverse proxy (NGINX).**

No direct access to the application containers is allowed. All responses should flow through the proxy layer. You are free to choose your preferred programming language and tools within the assignment constraints. Where design decisions are involved (e.g. number of backend instances), your implementation should reflect your skill level, creativity, and understanding of production-like setups.

---

## ⏱️ Timeline

You have **one week** to complete the full assignment.

---

## 🔹 Phase 1: Basic Level

### 🎯 Objective

Build a minimal local web platform using containers, consisting of:

- A **reverse proxy (NGINX)**: the single entry point for all HTTP traffic
- One or more **web server container(s)** serving static HTML content

### 📌 Tasks

1. **Build a web server container**
   - Create a `Dockerfile` that installs and configures a basic web server.
   - Use `nginx`, `httpd`, or a minimal alternative.
   - The server must serve a simple HTML file (e.g., "Hello from Web Server via Reverse Proxy!").
   - It has to make use of virtual_hosts, and not just path rewrites.
   - Do not use full prebuilt images; start from `alpine` or `debian`.

2. **Build a reverse proxy container**
   - Create a second container with NGINX configured as a reverse proxy.
   - It must:
     - Listen on ports `80` and `443`.
     - Forward all incoming traffic to the internal web server(s).
   - Direct access to web server(s) must not be exposed to the host.

3. **Docker Compose setup**
   - Use `docker-compose.yml` to define both the reverse proxy and the web server container(s).
   - Define a custom Docker network so containers communicate by name.
   - Only expose the **reverse proxy** to the outside world.
   - You may choose to scale the web server component (e.g. `--scale web=2`), but it's not required.

4. **Security configuration**
   - Add hardening to the reverse proxy (examples):
     - Block HTTP methods like `TRACE` and `OPTIONS`.
     - Set headers including:
       - `X-Frame-Options: DENY`
       - `Content-Security-Policy: default-src 'self'`
   - Ensure no other containers are accessible directly from the host.

5. **Linux fundamentals**
   - Demonstrate command-line skills by:
     - Managing file permissions with `chmod` and `chown`.
     - Using tools like `curl`, `ping`, and `ip a` to test connectivity.
     - Using Docker CLI commands to verify network isolation.

6. **Verification**
   - Start the environment with `docker-compose up`.
   - Run a `curl` command against `http://localhost` and confirm:
     - The response comes from the web server.
     - The NGINX proxy is the entry point (confirm via headers or logs).
   - Do **not** expose or access the web server directly.

### 🧪 Example Test Command

```bash
curl -i http://yourwebsite.local

# Expected Output: HTML content from the webserver, with NGINX headers visible
```

---

## 🔸 Phase 2: Intermediate Level

### 🎯 Objective

Extend your solution with a backend application and automate deployment using CI/CD pipelines.

### 📌 Tasks

1. **Add a backend application container**
   - Write a simple API in Flask (Python) or Express (Node.js) whichever language you prefer.
   - Must include a health endpoint (e.g. `GET /api/health → { status: "ok" }`).
   - Build your own image starting from a minimal base.

2. **Update NGINX to proxy both web and API traffic**
   - Static site served at `/`.
   - API routed to `/api`.
   - Example:
     ```nginx
     location /api {
       proxy_pass http://backend:5000;
     }
     ```

3. **Manage services with Docker Compose**
   - Update `docker-compose.yml` to include the new backend.
   - Keep reverse proxy as the single exposed component.

4. **Health checks**
   - Add Docker `HEALTHCHECK` for both the backend and web server.
   - Use HTTP probes to `/` and `/api/health`.

5. **Environment variable usage**
   - Use `.env` files to inject values like ports, service names, and debug flags.

6. **CI/CD Pipeline with GitHub Actions**
   - On every push:
     - Build all Docker images.
     - Lint configuration files.
     - Validate Compose config with `docker-compose config`.
     - Test container availability via `curl` or equivalent.

---

## 🔺 Phase 3: Expert Level

### 🎯 Objective

Design a production-like system with HTTPS, observability, and robust deployment automation.

### 📌 Tasks

1. **Enable HTTPS**
   - Configure NGINX reverse proxy to serve over HTTPS.
   - Use:
     - A self-signed certificate for local testing **or**
     - Simulate Let's Encrypt with Certbot if applicable.
   - Redirect HTTP to HTTPS (301).

2. **Centralized logging**
   - Integrate a log stack such as:
     - ELK: Elasticsearch + Logstash + Kibana.
     - Loki + Promtail + Grafana.
   - All containers must forward logs to the central system.
   - Include both application logs and access logs.

3. **Custom backend image**
   - Build a backend image **from scratch** (no `python:3` or `node:18`).
   - Use base images like `alpine` and install only what's needed.

4. **Extended testing**
   - Add unit tests for the backend app (e.g. `pytest`, `jest`).
   - Run NGINX config validation with `nginx -t`.
   - Validate full platform with functional tests:
     - Homepage loads.
     - `/api/health` responds with 200.

5. **Advanced CI/CD pipeline**
   - Fully automated GitHub Actions:
     - Lint, test, build, deploy.
     - Run test suite.
     - Tag Docker images.
     - Auto-redeploy on push to `main`.

6. **Failure handling**
   - Configure auto-restart on container failure.
   - Add load balancing across multiple backend containers via NGINX upstream config.

---

## 🧪 Optional Debug Challenge

You're given:

- A broken `Dockerfile`
- A misconfigured `docker-compose.yml`
- Broken NGINX configs

### Task

- Identify and fix syntax errors, build issues, and runtime crashes.
- Log each error you found and how you fixed it.
- Example issues:
  - Wrong proxy hostnames
  - Port conflicts
  - Missing volumes or context paths

---

## 📦 Deliverables

Each phase builds on the previous. Deliverables must include:

| Component            | Description                                    |
|----------------------|------------------------------------------------|
| `Dockerfile`         | One for each container (web, backend)          |
| `docker-compose.yml` | Multi-service Compose setup                    |
| `nginx.conf`         | Reverse proxy config with routing and security |
| `.env`               | Environment variables (if used)                |
| `.github/workflows/` | CI/CD pipeline scripts                         |
| `docs/`              | Documentation (Markdown or PDF) including:     |
|                      | - How to run everything                        |
|                      | - Reverse proxy logic                          |
|                      | - Security and test plans                      |
|                      | - Architecture diagram (Expert level)          |

---

## 🧾 Evaluation Criteria

| Area                | Description                                              |
|---------------------|----------------------------------------------------------|
| **Technical Skill** | Use of Docker, NGINX, Compose, CI/CD                     |
| **Security**        | Reverse proxy config, blocked methods, headers, HTTPS    |
| **Clarity**         | Clear routing, only one entry point                      |
| **Problem Solving** | Debugging, logging, testing strategy                     |
| **Documentation**   | Architecture explanations, justifications, test coverage |
| **Code Quality**    | Image optimization, Docker layering, pipeline robustness |

---

## 🚀 Submission

You may submit your work via:

- GitHub repository (preferred)
- ZIP file with structured folders

---

Good luck! Take ownership, be creative, and build something production-worthy 💪