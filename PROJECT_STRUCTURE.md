# 📁 Project Structure

Complete directory structure of the DevOps Stage 6 project.

```
DevOps-Stage-6/
│
├── .github/
│   └── workflows/
│       ├── infra-deploy.yml          # Infrastructure CI/CD workflow
│       └── app-deploy.yml            # Application deployment workflow
│
├── auth-api/                          # Go Authentication Service
│   ├── Dockerfile                     # Multi-stage Go build
│   ├── main.go
│   ├── user.go
│   ├── tracing.go
│   ├── go.mod
│   ├── go.sum
│   └── README.md
│
├── frontend/                          # Vue.js Frontend
│   ├── Dockerfile                     # Multi-stage Vue.js + Nginx
│   ├── nginx.conf                     # Nginx configuration
│   ├── package.json
│   ├── package-lock.json
│   ├── index.html
│   ├── src/
│   │   ├── main.js
│   │   ├── auth.js
│   │   ├── zipkin.js
│   │   ├── components/
│   │   │   ├── App.vue
│   │   │   ├── AppNav.vue
│   │   │   ├── Login.vue
│   │   │   ├── Todos.vue
│   │   │   ├── TodoItem.vue
│   │   │   └── common/
│   │   │       └── Spinner.vue
│   │   ├── router/
│   │   │   └── index.js
│   │   ├── store/
│   │   │   ├── index.js
│   │   │   ├── state.js
│   │   │   ├── mutations.js
│   │   │   └── plugins.js
│   │   └── assets/
│   │       └── logo.png
│   ├── build/                         # Webpack build configuration
│   ├── config/                        # Environment configuration
│   ├── static/
│   └── README.md
│
├── todos-api/                         # Node.js Todos Service
│   ├── Dockerfile                     # Node.js build
│   ├── server.js
│   ├── routes.js
│   ├── todoController.js
│   ├── package.json
│   ├── package-lock.json
│   └── README.md
│
├── users-api/                         # Java Spring Boot Users Service
│   ├── Dockerfile                     # Multi-stage Maven build
│   ├── pom.xml
│   ├── mvnw
│   ├── mvnw.cmd
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/elgris/usersapi/
│   │   │   │       ├── UsersApiApplication.java
│   │   │   │       ├── api/
│   │   │   │       │   └── UsersController.java
│   │   │   │       ├── models/
│   │   │   │       │   ├── User.java
│   │   │   │       │   └── UserRole.java
│   │   │   │       ├── repository/
│   │   │   │       │   └── UserRepository.java
│   │   │   │       ├── security/
│   │   │   │       │   ├── AccessUserFilter.java
│   │   │   │       │   └── JwtAuthenticationFilter.java
│   │   │   │       └── configuration/
│   │   │   │           └── SecurityConfiguration.java
│   │   │   └── resources/
│   │   │       ├── application.properties
│   │   │       └── data.sql
│   │   └── test/
│   │       └── java/
│   └── README.md
│
├── log-message-processor/             # Python Log Processor
│   ├── Dockerfile                     # Python build
│   ├── main.py
│   ├── requirements.txt
│   └── README.md
│
├── infra/                             # Infrastructure as Code
│   ├── terraform/                     # AWS Infrastructure
│   │   ├── backend.tf                 # S3 backend configuration
│   │   ├── variables.tf               # Input variables
│   │   ├── main.tf                    # VPC and networking
│   │   ├── ec2.tf                     # EC2 instance
│   │   ├── security_groups.tf         # Security groups
│   │   ├── ansible.tf                 # Terraform-Ansible integration
│   │   ├── outputs.tf                 # Output values
│   │   └── terraform.tfvars.example   # Variable template
│   │
│   ├── ansible/                       # Configuration Management
│   │   ├── ansible.cfg                # Ansible configuration
│   │   ├── playbook.yml               # Main playbook
│   │   ├── extra_vars.yml.tpl         # Variables template
│   │   ├── inventory/
│   │   │   ├── hosts.tpl              # Inventory template
│   │   │   └── hosts.example          # Example inventory
│   │   └── roles/
│   │       ├── dependencies/          # Dependencies role
│   │       │   ├── tasks/
│   │       │   │   └── main.yml
│   │       │   └── handlers/
│   │       │       └── main.yml
│   │       └── deploy/                # Deployment role
│   │           ├── tasks/
│   │           │   └── main.yml
│   │           ├── handlers/
│   │           │   └── main.yml
│   │           └── templates/
│   │               └── env.j2
│   └── README.md                      # Infrastructure documentation
│
├── traefik/                           # Traefik Configuration
│   ├── traefik.yml                    # Main Traefik config
│   ├── config/
│   │   └── middleware.yml             # Middleware configuration
│   └── acme.json                      # SSL certificates (generated)
│
├── setup-scripts/                     # Setup Automation Scripts
│   ├── setup-local.sh                 # Local environment setup
│   └── setup-aws.sh                   # AWS backend setup
│
├── docker-compose.yml                 # Main orchestration file
├── init-traefik.sh                    # Traefik initialization script
│
├── .env.example                       # Environment variables template
├── .gitignore                         # Git ignore rules
├── .dockerignore                      # Docker ignore rules
│
├── README.md                          # Main documentation
├── DEPLOYMENT_GUIDE.md                # Step-by-step deployment guide
├── SETUP_CHECKLIST.md                 # Setup verification checklist
├── IMPLEMENTATION_SUMMARY.md          # Implementation overview
├── PROJECT_STRUCTURE.md               # This file
│
└── stage-6-task.txt                   # Original task requirements
```

## 📊 File Count by Type

### Infrastructure (19 files)
- Terraform: 8 files
- Ansible: 10 files
- GitHub Actions: 2 files

### Application (5 services)
- Dockerfiles: 5 files
- Service code: Multiple files per service

### Configuration (6 files)
- Docker Compose: 1 file
- Traefik: 2 files
- Environment: 3 files

### Documentation (5 files)
- READMEs: 2 files
- Guides: 3 files

### Scripts (3 files)
- Setup scripts: 2 files
- Init scripts: 1 file

**Total: 40+ configuration/infrastructure files**

## 🎯 Key Directories Explained

### Root Level
Contains Docker Compose orchestration and main documentation.

### `.github/workflows/`
GitHub Actions CI/CD pipelines for infrastructure and application deployment.

### `infra/`
Complete infrastructure as code - Terraform for AWS provisioning, Ansible for configuration.

### Service Directories
- `auth-api/` - Authentication service (Go)
- `frontend/` - User interface (Vue.js)
- `todos-api/` - TODO management (Node.js)
- `users-api/` - User management (Java)
- `log-message-processor/` - Log processing (Python)

### `traefik/`
Reverse proxy configuration with SSL/TLS certificates.

### `setup-scripts/`
Helper scripts for initial setup and configuration.

## 🔄 Configuration Flow

```
.env.example → .env (local)
    ↓
terraform.tfvars.example → terraform.tfvars
    ↓
Terraform generates → Ansible inventory & variables
    ↓
Ansible creates → Application .env on server
    ↓
Docker Compose uses → .env for service configuration
```

## 📝 Important Files

### Must Configure Before Deployment
1. `.env` - Application environment variables
2. `infra/terraform/terraform.tfvars` - Infrastructure variables
3. GitHub Secrets - CI/CD credentials

### Auto-Generated (Do Not Edit)
1. `infra/ansible/inventory/hosts` - Generated by Terraform
2. `infra/ansible/extra_vars.yml` - Generated by Terraform
3. `traefik/acme.json` - Generated by Let's Encrypt

### Templates (Used for Generation)
1. `.env.example` - Template for `.env`
2. `terraform.tfvars.example` - Template for `terraform.tfvars`
3. `infra/ansible/inventory/hosts.tpl` - Template for inventory
4. `infra/ansible/extra_vars.yml.tpl` - Template for variables
5. `infra/ansible/roles/deploy/templates/env.j2` - Template for server .env

## 🚫 What's Ignored

### `.gitignore` excludes:
- `.env` files (except `.env.example`)
- Terraform state files
- Ansible generated files
- SSH keys
- Node modules
- Build artifacts
- Logs

### `.dockerignore` excludes:
- Git directory
- Documentation
- Infrastructure code
- CI/CD workflows
- Development files

## 🔐 Security-Sensitive Files

**Never commit these files:**
- `.env` - Contains secrets
- `terraform.tfvars` - Contains AWS credentials
- `*.pem` - SSH private keys
- `terraform.tfstate` - May contain sensitive data
- `infra/ansible/inventory/hosts` - Contains server IPs
- `traefik/acme.json` - Contains SSL certificates

## 📦 Dependencies

### Frontend
- Node.js 12+
- Vue.js 2
- Bootstrap Vue
- Webpack

### Auth API
- Go 1.18+
- Echo framework
- JWT library

### Todos API
- Node.js 12+
- Express.js
- Redis client
- Zipkin

### Users API
- Java 8+
- Spring Boot 1.5
- H2 Database
- JWT

### Log Processor
- Python 3.8+
- Redis library
- Zipkin Python

### Infrastructure
- Terraform 1.6+
- Ansible 2.9+
- AWS CLI (optional)

## 🎓 Learning Resources

Each directory contains:
- README.md with specific documentation
- Comments in configuration files
- Example files for reference

Key learning files:
1. `README.md` - Overall architecture
2. `infra/README.md` - Infrastructure details
3. `DEPLOYMENT_GUIDE.md` - Deployment process
4. `SETUP_CHECKLIST.md` - Verification steps

## 🔄 Update Workflow

When updating the project:

1. **Application Changes**: Edit service code → Push to Git → CI/CD deploys
2. **Infrastructure Changes**: Edit Terraform → Push → Drift detection → Manual approval → Apply
3. **Configuration Changes**: Edit Ansible → Push → Infrastructure workflow runs
4. **Documentation Updates**: Edit markdown files → Push → No deployment needed

## 🎯 Interview Focus Areas

Understanding this structure helps explain:
- Separation of concerns (app vs infra)
- Infrastructure as Code principles
- CI/CD automation
- Security best practices
- Container orchestration
- Service mesh architecture

---

**This structure follows DevOps best practices for:**
- ✅ Version control
- ✅ Infrastructure as Code
- ✅ Configuration Management
- ✅ CI/CD automation
- ✅ Container orchestration
- ✅ Documentation
- ✅ Security

**All files are organized logically and follow industry standards.**

