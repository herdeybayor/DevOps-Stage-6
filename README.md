# 🚀 DevOps Stage 6 - Microservices TODO Application

A fully containerized, production-ready microservices application with automated infrastructure provisioning, deployment, and drift detection.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [Production Deployment](#production-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Services](#services)
- [Monitoring & Troubleshooting](#monitoring--troubleshooting)
- [Security](#security)

## 🎯 Overview

This project demonstrates a complete DevOps workflow for deploying a microservices-based TODO application with:

- **5 Microservices**: Frontend (Vue.js), Auth API (Go), Todos API (Node.js), Users API (Java), Log Processor (Python)
- **Infrastructure as Code**: Terraform for AWS provisioning
- **Configuration Management**: Ansible for server setup and deployment
- **Container Orchestration**: Docker Compose with Traefik reverse proxy
- **SSL/TLS**: Automatic HTTPS with Let's Encrypt
- **CI/CD**: GitHub Actions with drift detection and email notifications
- **Idempotent**: All operations can be run multiple times safely

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │   Traefik    │ (Reverse Proxy + SSL)
                  │   Port 80/443│
                  └──────┬───────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │Frontend │    │Auth API │    │Todos API│
    │ (Vue.js)│    │  (Go)   │    │(Node.js)│
    └─────────┘    └────┬────┘    └────┬────┘
                        │              │
                   ┌────▼─────┐   ┌────▼────┐
                   │Users API │   │  Redis  │
                   │ (Java)   │   └────┬────┘
                   └──────────┘        │
                                  ┌────▼────┐
                                  │   Log   │
                                  │Processor│
                                  │(Python) │
                                  └─────────┘
```

## 📦 Prerequisites

### For Local Development:
- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git

### For Production Deployment:
- AWS Account with appropriate permissions
- Domain name with DNS access
- Terraform (v1.6.0+)
- Ansible (v2.9+)
- SSH key pair for AWS EC2

### For CI/CD:
- GitHub account
- Gmail account with App Password (for notifications)
- Docker Hub account (optional, for image registry)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/DevOps-Stage-6.git
cd DevOps-Stage-6
```

### 2. Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your actual values
nano .env
```

### 3. Initialize Traefik

```bash
chmod +x init-traefik.sh
./init-traefik.sh
```

### 4. Start the Application

```bash
docker compose up -d
```

### 5. Access the Application

- **Frontend**: http://localhost (or your domain)
- **Traefik Dashboard**: http://localhost:8080 (if enabled)

### Default Login Credentials

- Username: `admin`
- Password: `Admin123`

Other test users:
- `hng` / `HngTech`
- `user` / `Password`

## 💻 Local Development

### Start Services

```bash
# Start all services
docker compose up -d

# Start specific service
docker compose up -d frontend

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f todos-api
```

### Rebuild Services

```bash
# Rebuild all services
docker compose up -d --build

# Rebuild specific service
docker compose up -d --build frontend
```

### Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## 🌐 Production Deployment

### Step 1: Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

### Step 2: Set Up Terraform Variables

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
nano terraform.tfvars
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan Infrastructure Changes

```bash
terraform plan
```

### Step 5: Apply Infrastructure

```bash
terraform apply -auto-approve
```

This will:
1. Provision AWS infrastructure (VPC, EC2, Security Groups)
2. Generate Ansible inventory
3. Install Docker and dependencies
4. Deploy the application
5. Configure Traefik with SSL

### Step 6: Configure DNS

Point your domain's A record to the Elastic IP output by Terraform:

```bash
terraform output instance_public_ip
```

### Step 7: Verify Deployment

Wait 2-5 minutes for SSL certificates to be issued, then access:
- https://your-domain.com

## 🔄 CI/CD Pipeline

### GitHub Secrets Configuration

Configure these secrets in your GitHub repository (Settings → Secrets → Actions):

**AWS Credentials:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**SSH Configuration:**
- `SSH_PRIVATE_KEY` - Your AWS key pair private key
- `KEY_NAME` - Name of your AWS key pair (without .pem)
- `SERVER_IP` - Your EC2 instance IP

**Application Configuration:**
- `DOMAIN_NAME` - Your domain (e.g., example.com)
- `LETSENCRYPT_EMAIL` - Email for SSL certificates
- `JWT_SECRET` - Secret key for JWT tokens

**Email Notifications:**
- `GMAIL_USERNAME` - Your Gmail address
- `GMAIL_APP_PASSWORD` - Gmail app password (not regular password)
- `NOTIFICATION_EMAIL` - Email to receive notifications

**Docker Registry (Optional):**
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

### Infrastructure Workflow

Triggers on changes to `infra/terraform/**` or `infra/ansible/**`

**Features:**
1. ✅ Terraform plan and validation
2. 🔍 Drift detection
3. 📧 Email notification on drift
4. ⏸️ Manual approval required
5. ✅ Terraform apply
6. 🤖 Automatic Ansible execution

### Application Workflow

Triggers on changes to any service or `docker-compose.yml`

**Features:**
1. 🔍 Detect changed services
2. 🏗️ Build only changed services
3. 📦 Push to Docker registry
4. 🚀 Deploy to production
5. ✅ Health checks
6. 📧 Deployment notifications
7. 🔄 Automatic rollback on failure

### Manual Approval for Infrastructure Changes

1. Navigate to Actions → Infrastructure Deployment
2. Click on the workflow run
3. Review the Terraform plan
4. Click "Review deployments"
5. Select "production" and click "Approve and deploy"

## 🔧 Services

### Frontend (Vue.js)
- **Port**: 80
- **Path**: `/`
- **Technology**: Vue.js 2, Webpack, Nginx
- **Health Check**: HTTP GET /

### Auth API (Go)
- **Port**: 8000
- **Path**: `/api/auth`
- **Technology**: Echo framework, JWT
- **Health Check**: HTTP GET /version

### Todos API (Node.js)
- **Port**: 8082
- **Path**: `/api/todos`
- **Technology**: Express.js, Redis
- **Health Check**: HTTP GET /health

### Users API (Java)
- **Port**: 8083
- **Path**: `/api/users`
- **Technology**: Spring Boot, H2 Database
- **Health Check**: HTTP GET /actuator/health

### Log Processor (Python)
- **Technology**: Redis subscriber, Zipkin integration
- **Function**: Processes logs from Redis queue

### Redis
- **Port**: 6379
- **Function**: Message queue and caching

### Traefik
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Function**: Reverse proxy, load balancer, SSL termination

## 📊 Monitoring & Troubleshooting

### Check Service Status

```bash
# SSH into server
ssh -i ~/.ssh/your-key.pem ubuntu@your-server-ip

# Check running containers
docker ps

# Check service logs
docker compose logs -f service-name

# Check Traefik logs
docker compose logs -f traefik
```

### Common Issues

**SSL Certificate Not Generated:**
- Ensure DNS is properly configured
- Check Traefik logs: `docker compose logs traefik`
- Verify domain in `.env` file
- Wait 5-10 minutes for Let's Encrypt validation

**Service Not Accessible:**
- Check if container is running: `docker ps`
- Check container logs: `docker compose logs service-name`
- Verify security group allows traffic on ports 80, 443
- Check Traefik dashboard for routing rules

**Database Connection Issues:**
- Ensure services start in correct order (Docker Compose handles this)
- Check if Redis is running: `docker compose ps redis`
- Verify environment variables are set correctly

### View Application Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f frontend
docker compose logs -f auth-api
docker compose logs -f todos-api
```

### Restart Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart frontend
```

## 🔒 Security

### Best Practices Implemented

✅ **SSL/TLS Encryption**: Automatic HTTPS with Let's Encrypt
✅ **Secrets Management**: Environment variables, GitHub Secrets
✅ **Firewall**: UFW configured to allow only necessary ports
✅ **Container Security**: Non-root users, minimal base images
✅ **Network Isolation**: Docker bridge network for inter-service communication
✅ **JWT Authentication**: Secure token-based authentication
✅ **Security Headers**: Traefik configured with security headers

### Recommendations

- Change default JWT_SECRET immediately
- Restrict SSH access to specific IP addresses
- Enable CloudFlare or AWS WAF for additional protection
- Implement rate limiting at Traefik level
- Regular security updates: `docker compose pull && docker compose up -d`
- Monitor logs for suspicious activity
- Use AWS Secrets Manager for production secrets

## 📚 Additional Resources

- [Infrastructure Documentation](infra/README.md)
- [Terraform Configuration](infra/terraform/)
- [Ansible Playbooks](infra/ansible/)
- [CI/CD Workflows](.github/workflows/)

## 🤝 Contributing

This is an individual project for HNG DevOps internship. For questions or issues, please create a GitHub issue.

## 📝 License

This project is created for educational purposes as part of the HNG DevOps internship program.

## 🎓 Author

Created for HNG DevOps Internship - Stage 6

---

**Built with ❤️ using Docker, Terraform, Ansible, and GitHub Actions**
