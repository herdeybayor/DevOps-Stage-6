# 📋 Setup Checklist for DevOps Stage 6

Use this checklist to ensure you have everything configured before deployment.

## ✅ Prerequisites

### Accounts & Services
- [ ] AWS Account created and activated
- [ ] Domain name purchased and accessible
- [ ] GitHub account with repository access
- [ ] Gmail account for notifications
- [ ] Docker Hub account (optional)

### Local Tools Installed
- [ ] Git installed: `git --version`
- [ ] Docker installed: `docker --version`
- [ ] Docker Compose installed: `docker compose version`
- [ ] Terraform installed: `terraform version`
- [ ] Ansible installed: `ansible --version`
- [ ] AWS CLI installed (optional): `aws --version`

## ✅ AWS Configuration

### Credentials
- [ ] AWS Access Key ID created
- [ ] AWS Secret Access Key saved securely
- [ ] AWS credentials configured: `aws configure` or set environment variables
- [ ] AWS region set to us-east-1 (or your preferred region)

### SSH Key Pair
- [ ] EC2 SSH key pair created in AWS Console
- [ ] .pem file downloaded
- [ ] .pem file moved to ~/.ssh/
- [ ] Permissions set: `chmod 400 ~/.ssh/your-key.pem`

### S3 Backend (Recommended)
- [ ] S3 bucket created for Terraform state
- [ ] Bucket versioning enabled
- [ ] DynamoDB table created for state locking
- [ ] backend.tf updated with bucket name

## ✅ Repository Setup

### Clone and Configure
- [ ] Repository forked (if not owner)
- [ ] Repository cloned locally
- [ ] .env file created from .env.example
- [ ] .env file updated with actual values
- [ ] Traefik initialized: `./init-traefik.sh`

### Git Configuration
- [ ] Git user configured: `git config --global user.name "Your Name"`
- [ ] Git email configured: `git config --global user.email "your@email.com"`
- [ ] Remote URL correct: `git remote -v`

## ✅ Terraform Setup

### Configuration Files
- [ ] terraform.tfvars created from example
- [ ] Key pair name updated in terraform.tfvars
- [ ] Domain name set in terraform.tfvars
- [ ] Let's Encrypt email set in terraform.tfvars
- [ ] JWT secret generated and set
- [ ] GitHub repo URL set in terraform.tfvars

### Initialization
- [ ] Terraform initialized: `cd infra/terraform && terraform init`
- [ ] Configuration validated: `terraform validate`
- [ ] Plan runs successfully: `terraform plan`

## ✅ Ansible Setup

### Installation
- [ ] Ansible installed
- [ ] community.docker collection installed: `ansible-galaxy collection install community.docker`
- [ ] Python Docker module available

### Configuration
- [ ] ansible.cfg reviewed
- [ ] Playbook syntax validated: `ansible-playbook --syntax-check playbook.yml`

## ✅ GitHub Secrets Configuration

### AWS Credentials
- [ ] AWS_ACCESS_KEY_ID added to GitHub Secrets
- [ ] AWS_SECRET_ACCESS_KEY added to GitHub Secrets

### SSH Configuration
- [ ] SSH_PRIVATE_KEY added (full .pem file contents)
- [ ] KEY_NAME added (without .pem extension)
- [ ] SERVER_IP added (will be updated after deployment)

### Application Configuration
- [ ] DOMAIN_NAME added
- [ ] LETSENCRYPT_EMAIL added
- [ ] JWT_SECRET added

### Email Notifications
- [ ] Gmail 2FA enabled
- [ ] Gmail App Password generated
- [ ] GMAIL_USERNAME added
- [ ] GMAIL_APP_PASSWORD added
- [ ] NOTIFICATION_EMAIL added

### Docker Registry (Optional)
- [ ] DOCKER_USERNAME added
- [ ] DOCKER_PASSWORD added

## ✅ DNS Configuration

### Domain Setup
- [ ] Domain registrar account accessible
- [ ] DNS management panel accessible
- [ ] Domain not currently in use (or backed up)

### DNS Records (Configure After Deployment)
- [ ] A record ready to create
- [ ] Know how to update DNS records
- [ ] TTL settings understood (recommend 300 seconds initially)

## ✅ Local Testing

### Docker Compose
- [ ] All services start: `docker compose up -d`
- [ ] All services healthy: `docker compose ps`
- [ ] Frontend accessible at http://localhost
- [ ] No error logs: `docker compose logs`
- [ ] Services stop cleanly: `docker compose down`

### Environment Variables
- [ ] .env file has all required variables
- [ ] JWT_SECRET is unique and secure
- [ ] No placeholder values remain

## ✅ Security Checklist

### Credentials
- [ ] No credentials in Git history
- [ ] .gitignore properly configured
- [ ] .env file NOT committed
- [ ] terraform.tfvars NOT committed
- [ ] SSH keys NOT committed

### Access Control
- [ ] SSH key is password protected
- [ ] AWS account has MFA enabled
- [ ] GitHub account has 2FA enabled
- [ ] Gmail account has 2FA enabled

### Infrastructure
- [ ] Security groups reviewed
- [ ] SSH access restricted (update allowed_ssh_cidr)
- [ ] Only necessary ports open (22, 80, 443)
- [ ] Instance in private subnet (optional)

## ✅ CI/CD Configuration

### GitHub Actions
- [ ] Workflows exist in .github/workflows/
- [ ] Infrastructure workflow validated
- [ ] Application workflow validated
- [ ] Actions enabled in repository settings

### Environment Protection
- [ ] Production environment created
- [ ] Required reviewers configured
- [ ] Branch protection rules set

### Notifications
- [ ] Test email can be sent
- [ ] Email notifications configured correctly
- [ ] Notification email address verified

## ✅ Documentation

### Read and Understood
- [ ] Main README.md reviewed
- [ ] Infrastructure README.md reviewed
- [ ] DEPLOYMENT_GUIDE.md reviewed
- [ ] Know where to find troubleshooting info

### Interview Preparation
- [ ] Can explain the architecture
- [ ] Understand each component's purpose
- [ ] Know how CI/CD workflow works
- [ ] Can explain drift detection
- [ ] Understand Traefik configuration
- [ ] Know how SSL certificates work

## ✅ Pre-Deployment Verification

### Final Checks
- [ ] All previous sections completed
- [ ] AWS costs understood (t3.medium + EIP + data transfer)
- [ ] Backup plan in place
- [ ] Know how to access server via SSH
- [ ] Know how to roll back if needed

### Ready to Deploy
- [ ] Terraform plan reviewed and understood
- [ ] 1-2 hours allocated for deployment
- [ ] Monitoring setup ready
- [ ] Emergency contacts available

## 📊 Cost Estimate

Expected monthly AWS costs (us-east-1):
- EC2 t3.medium: ~$30-40
- Elastic IP: $0 (while attached)
- Data transfer: $5-15
- **Total: ~$35-55/month**

Add domain cost: ~$10-15/year

## 🚀 Deployment Order

When all checks are complete, follow this order:

1. ✅ Run local tests (`docker compose up -d`)
2. ✅ Deploy infrastructure (`terraform apply`)
3. ✅ Configure DNS with Elastic IP
4. ✅ Wait for SSL certificate (5-10 minutes)
5. ✅ Verify application is accessible
6. ✅ Test login and functionality
7. ✅ Push to GitHub to test CI/CD
8. ✅ Test drift detection workflow

## 📝 Post-Deployment Tasks

- [ ] Application accessible at https://domain.com
- [ ] SSL certificate valid (green padlock)
- [ ] Can login with test credentials
- [ ] TODO dashboard works
- [ ] API endpoints return expected errors
- [ ] GitHub Actions workflows successful
- [ ] Drift detection email received (if tested)
- [ ] SERVER_IP GitHub secret updated

## 🎓 Interview Preparation

- [ ] Architecture diagram understood
- [ ] Can explain each technology choice
- [ ] Know all commands used
- [ ] Understand infrastructure as code benefits
- [ ] Can explain CI/CD pipeline
- [ ] Know how to troubleshoot issues
- [ ] Presentation slides created
- [ ] Screenshots taken for submission

---

## ✨ Tips for Success

1. **Don't Rush**: Take time to understand each step
2. **Test Locally First**: Catch issues before AWS deployment
3. **Read Error Messages**: They usually tell you exactly what's wrong
4. **Keep Notes**: Document any issues and solutions
5. **Ask Questions**: Better to clarify than guess
6. **Backup Often**: Before major changes
7. **Monitor Costs**: Check AWS billing dashboard regularly
8. **Clean Up**: Destroy resources when testing is complete

---

## 🆘 If Something Goes Wrong

**Don't Panic!** Common issues:

1. **Terraform fails**: Check AWS credentials and permissions
2. **Ansible fails**: Verify SSH key and connectivity
3. **Services don't start**: Check logs with `docker compose logs`
4. **SSL not working**: Wait longer, check DNS, review Traefik logs
5. **Can't SSH**: Check security group allows your IP on port 22

**Worst Case**: Destroy and recreate:
```bash
terraform destroy
# Fix the issue
terraform apply
```

---

## ✅ Final Confirmation

Before proceeding to deployment:

- [ ] All items in this checklist are complete
- [ ] I understand what each component does
- [ ] I have backups of all credentials
- [ ] I have 1-2 hours available for deployment
- [ ] I'm ready to troubleshoot if needed
- [ ] I've read the deployment guide
- [ ] I'm prepared for the interview presentation

**If all checked, you're ready to deploy! 🚀**

Good luck! Remember: this is a learning experience. Take your time and enjoy the process.

---

**Last Updated**: $(date)
**Your Name**: _______________
**Deployment Date**: _______________

