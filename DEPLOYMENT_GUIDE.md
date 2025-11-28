# 🚀 Complete Deployment Guide

This guide walks you through deploying the DevOps Stage 6 application from scratch.

## 📋 Pre-Deployment Checklist

### ✅ Required Accounts & Services

- [ ] AWS Account with billing enabled
- [ ] Domain name registered (from Namecheap, GoDaddy, etc.)
- [ ] GitHub account
- [ ] Gmail account (for notifications)
- [ ] Docker Hub account (optional)

### ✅ Required Tools Installed

- [ ] Git
- [ ] Terraform (v1.6.0+)
- [ ] Ansible (v2.9+)
- [ ] AWS CLI (optional but helpful)
- [ ] Docker & Docker Compose (for local testing)

### ✅ Required Credentials

- [ ] AWS Access Key ID and Secret Access Key
- [ ] AWS SSH Key Pair created and downloaded
- [ ] Gmail App Password generated
- [ ] GitHub Personal Access Token (if using private repo)

---

## 🎯 Step-by-Step Deployment

### Phase 1: Local Setup & Testing (30 minutes)

#### 1.1 Clone and Configure

```bash
# Clone the repository
git clone https://github.com/yourusername/DevOps-Stage-6.git
cd DevOps-Stage-6

# Create environment file
cp .env.example .env
```

#### 1.2 Edit .env File

```bash
nano .env
```

Update these values:
```env
DOMAIN_NAME=your-domain.com
LETSENCRYPT_EMAIL=your-email@example.com
JWT_SECRET=$(openssl rand -base64 32)
```

#### 1.3 Initialize Traefik

```bash
chmod +x init-traefik.sh
./init-traefik.sh
```

#### 1.4 Test Locally

```bash
# Start all services
docker compose up -d

# Check service status
docker compose ps

# View logs
docker compose logs -f

# Test frontend
curl http://localhost

# Stop services
docker compose down
```

**Expected Result**: All services should start successfully. Frontend accessible at http://localhost

---

### Phase 2: AWS Infrastructure Setup (20 minutes)

#### 2.1 Create AWS SSH Key Pair

```bash
# Via AWS Console:
# 1. Go to EC2 → Key Pairs → Create Key Pair
# 2. Name: devops-stage6-key
# 3. Download .pem file
# 4. Move to ~/.ssh/

mv ~/Downloads/devops-stage6-key.pem ~/.ssh/
chmod 400 ~/.ssh/devops-stage6-key.pem
```

#### 2.2 Configure AWS Credentials

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 2: AWS CLI (recommended)
aws configure
```

#### 2.3 Create S3 Bucket for Terraform State (Recommended)

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket devops-stage6-terraform-state-$(whoami) \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket devops-stage6-terraform-state-$(whoami) \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

#### 2.4 Update backend.tf

```bash
cd infra/terraform
nano backend.tf
```

Uncomment and update the S3 backend configuration with your bucket name.

---

### Phase 3: Terraform Configuration (15 minutes)

#### 3.1 Create terraform.tfvars

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Update with your values:
```hcl
aws_region         = "us-east-1"
environment        = "production"
instance_type      = "t3.medium"
key_name           = "devops-stage6-key"
domain_name        = "your-domain.com"
letsencrypt_email  = "your-email@example.com"
jwt_secret         = "your-generated-secret-key"
github_repo_url    = "https://github.com/yourusername/DevOps-Stage-6.git"
allowed_ssh_cidr   = "0.0.0.0/0"  # Restrict to your IP for better security
project_name       = "devops-stage6"
```

#### 3.2 Initialize Terraform

```bash
terraform init
```

**Expected Output**: "Terraform has been successfully initialized!"

#### 3.3 Validate Configuration

```bash
terraform validate
```

**Expected Output**: "Success! The configuration is valid."

#### 3.4 Plan Infrastructure

```bash
terraform plan
```

Review the plan. Should show ~15 resources to create.

---

### Phase 4: Ansible Setup (10 minutes)

#### 4.1 Install Ansible

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y ansible

# Python pip
pip install ansible
```

#### 4.2 Install Required Collections

```bash
ansible-galaxy collection install community.docker
```

#### 4.3 Test Ansible (After Infrastructure is Created)

This will be done automatically by Terraform, but you can test manually:

```bash
cd ../ansible
ansible --version
ansible-playbook --syntax-check playbook.yml
```

---

### Phase 5: Deploy Infrastructure (30-45 minutes)

#### 5.1 Deploy with Terraform

```bash
cd infra/terraform
terraform apply
```

Review the plan and type `yes` when prompted.

**This will take 15-20 minutes** and will:
1. ✅ Create VPC and networking
2. ✅ Launch EC2 instance
3. ✅ Configure security groups
4. ✅ Assign Elastic IP
5. ✅ Generate Ansible inventory
6. ✅ Run Ansible playbooks
7. ✅ Install Docker and dependencies
8. ✅ Deploy the application
9. ✅ Configure Traefik and SSL

#### 5.2 Get Server IP

```bash
terraform output instance_public_ip
```

Save this IP address.

---

### Phase 6: DNS Configuration (5 minutes + DNS propagation time)

#### 6.1 Update DNS Records

Go to your domain registrar (Namecheap, GoDaddy, etc.) and create:

**A Record:**
- Host: `@` (or your subdomain)
- Value: `<your-elastic-ip>`
- TTL: 300 seconds

**Optional CNAME (if using subdomain):**
- Host: `www`
- Value: `your-domain.com`
- TTL: 300 seconds

#### 6.2 Verify DNS Propagation

```bash
# Check DNS resolution
dig your-domain.com
nslookup your-domain.com

# Or use online tool: https://dnschecker.org
```

**Wait 5-15 minutes** for DNS to propagate globally.

---

### Phase 7: SSL Certificate Setup (5-10 minutes)

#### 7.1 Monitor Certificate Generation

```bash
# SSH into server
ssh -i ~/.ssh/devops-stage6-key.pem ubuntu@<your-server-ip>

# Check Traefik logs
cd /home/ubuntu/app
docker compose logs -f traefik
```

Look for messages about Let's Encrypt certificate generation.

#### 7.2 Verify SSL Certificate

```bash
# From your local machine
curl -I https://your-domain.com
```

Should return `200 OK` with valid SSL certificate.

Or visit in browser: https://your-domain.com

---

### Phase 8: GitHub Actions Setup (20 minutes)

#### 8.1 Configure GitHub Secrets

Go to your GitHub repo → Settings → Secrets and Variables → Actions → New repository secret

Add these secrets:

**AWS Credentials:**
```
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
```

**SSH Configuration:**
```
SSH_PRIVATE_KEY=<contents-of-your-pem-file>
KEY_NAME=devops-stage6-key
SERVER_IP=<your-elastic-ip>
```

**Application Configuration:**
```
DOMAIN_NAME=your-domain.com
LETSENCRYPT_EMAIL=your-email@example.com
JWT_SECRET=your-jwt-secret
```

**Email Notifications:**
```
GMAIL_USERNAME=your-email@gmail.com
GMAIL_APP_PASSWORD=your-16-digit-app-password
NOTIFICATION_EMAIL=your-email@gmail.com
```

**Docker Hub (Optional):**
```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password
```

#### 8.2 Generate Gmail App Password

1. Go to https://myaccount.google.com/security
2. Enable 2-Factor Authentication (if not already)
3. Go to "App passwords"
4. Generate new app password for "Mail"
5. Copy the 16-digit password (no spaces)

#### 8.3 Enable GitHub Actions

Go to Actions tab → Enable workflows if prompted

#### 8.4 Test Workflows

```bash
# Make a small change to trigger workflow
cd ../../
echo "# Test" >> README.md
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin main
```

Watch the Actions tab for workflow execution.

---

### Phase 9: Configure Production Environment (10 minutes)

#### 9.1 Set Up Protected Branches

GitHub → Settings → Branches → Add rule

- Branch name pattern: `main`
- ✅ Require a pull request before merging
- ✅ Require status checks to pass

#### 9.2 Configure Environment Protection

GitHub → Settings → Environments → New environment

- Name: `production`
- ✅ Required reviewers (add yourself)
- Save protection rules

Now infrastructure changes will require manual approval!

---

### Phase 10: Verification & Testing (15 minutes)

#### 10.1 Access the Application

Visit: https://your-domain.com

**Expected**: Login page loads with valid SSL certificate

#### 10.2 Test Login

Credentials:
- Username: `admin`
- Password: `Admin123`

**Expected**: Redirects to TODO dashboard

#### 10.3 Test APIs Directly

```bash
# Auth API (should return "Not Found")
curl https://your-domain.com/api/auth

# Todos API (should return "invalid token")
curl https://your-domain.com/api/todos

# Users API (should return authorization error)
curl https://your-domain.com/api/users
```

#### 10.4 Test Drift Detection

```bash
# Make manual change in AWS Console
# e.g., change security group rule

# Run Terraform plan
cd infra/terraform
terraform plan
```

**Expected**: 
- Detects drift
- In CI/CD, would send email notification

---

## 🎉 Deployment Complete!

Your application is now:
- ✅ Running on AWS EC2
- ✅ Secured with HTTPS
- ✅ Fully containerized
- ✅ CI/CD enabled
- ✅ Drift detection active
- ✅ Auto-scaling ready (if configured)

---

## 📊 Post-Deployment Tasks

### Monitor Application

```bash
# SSH into server
ssh -i ~/.ssh/devops-stage6-key.pem ubuntu@<server-ip>

# Check services
docker compose ps

# View logs
docker compose logs -f

# Check resource usage
docker stats
```

### Regular Maintenance

```bash
# Update application
cd /home/ubuntu/app
git pull origin main
docker compose pull
docker compose up -d

# Cleanup unused images
docker image prune -f

# View disk usage
df -h
docker system df
```

### Backup Important Data

```bash
# Backup .env file
cp .env .env.backup

# Backup Traefik certificates
sudo tar -czf traefik-certs-backup.tar.gz traefik/acme.json

# Backup database (if using persistent storage)
docker compose exec users-api /backup.sh
```

---

## 🔧 Troubleshooting

### Issue: SSL Certificate Not Generated

**Solution:**
1. Verify DNS is pointing to correct IP
2. Wait 10-15 minutes
3. Check Traefik logs: `docker compose logs traefik`
4. Ensure ports 80, 443 are accessible
5. Try restarting Traefik: `docker compose restart traefik`

### Issue: Services Not Starting

**Solution:**
```bash
# Check logs
docker compose logs service-name

# Restart specific service
docker compose restart service-name

# Rebuild and restart
docker compose up -d --build service-name
```

### Issue: Terraform Apply Fails

**Solution:**
1. Check AWS credentials: `aws sts get-caller-identity`
2. Verify SSH key exists: `ls ~/.ssh/devops-stage6-key.pem`
3. Check Terraform logs for specific error
4. Try: `terraform refresh` then `terraform apply`

### Issue: Ansible Connection Timeout

**Solution:**
1. Verify security group allows SSH from your IP
2. Check if instance is running: `terraform state show aws_instance.app_server`
3. Test SSH manually: `ssh -i ~/.ssh/key.pem ubuntu@ip`
4. Wait 2-3 minutes for instance to fully boot

---

## 📚 Next Steps

1. **Security Hardening**:
   - Restrict SSH to your IP only
   - Enable CloudFlare for DDoS protection
   - Implement rate limiting
   - Set up AWS CloudWatch monitoring

2. **Performance Optimization**:
   - Configure Docker resource limits
   - Enable Redis persistence
   - Implement caching strategies
   - Add CDN for static assets

3. **Monitoring Setup**:
   - Add Prometheus + Grafana
   - Configure log aggregation
   - Set up uptime monitoring
   - Create custom alerts

4. **Backup Strategy**:
   - Automate database backups
   - Configure EBS snapshots
   - Implement disaster recovery plan
   - Test restoration procedures

---

## 🆘 Getting Help

- Review logs: `docker compose logs -f`
- Check documentation: [README.md](README.md)
- Verify all steps were completed
- Check GitHub Issues for common problems

**Remember**: This is a production deployment. Always test changes in a staging environment first!

---

**Good luck with your deployment! 🚀**

