# Infrastructure Drift Detection - Quick Start Guide

## What is Drift Detection?

Drift detection automatically alerts you when your actual AWS infrastructure differs from your Terraform configuration. This prevents configuration drift and maintains infrastructure consistency.

## How It Works (Simple)

```
You make code changes
         ↓
Workflow automatically runs
         ↓
Terraform compares current state vs desired state
         ↓
Drift detected? → 📧 Email sent to you
         ↓
You review and approve changes
         ↓
Terraform applies the changes
         ↓
Infrastructure updated
```

## Quick Start

### 1️⃣ Trigger Drift Detection

```bash
gh workflow run infra-deploy.yml --ref main
```

Or make changes to Terraform files and push:
```bash
# Edit infrastructure files
echo "# test" >> infra/terraform/main.tf

# Commit and push
git add infra/terraform/main.tf
git commit -m "Update infrastructure"
git push origin main
```

### 2️⃣ Check Your Email

You'll receive an email like:

```
📧 Subject: 🚨 Infrastructure Drift Detected - DevOps Stage 6

What changed:
- Maybe an EC2 instance was deleted
- Maybe security group was modified
- Maybe new resources are needed

Action: Review the plan and approve in GitHub
```

### 3️⃣ Review & Approve

Visit your GitHub Actions:
```
https://github.com/herdeybayor/DevOps-Stage-6/actions
```

Look for the Infrastructure Deployment run and click "Review deployments" to approve.

### 4️⃣ Done ✅

Terraform applies the changes automatically after approval.

---

## What Triggers Email Alerts?

**Email Sent When:**
- ✅ Infrastructure drift detected (changes found)
- ✅ Deployment fails (Terraform apply error)
- ✅ Deployment succeeds (everything applied)

**No Email When:**
- ⏭️ No drift detected (infrastructure already matches)
- ⏭️ Running on a pull request (not production)

---

## Common Drift Scenarios

### Scenario 1: Someone Deletes a Resource in AWS

```
Someone manually deletes a security group in AWS console
         ↓
You trigger drift detection
         ↓
Terraform detects it's missing
         ↓
📧 Email: "Infrastructure drift detected! 1 resource will be recreated"
         ↓
You approve
         ↓
Terraform recreates the security group ✅
```

### Scenario 2: You Update Terraform

```
You add a new S3 bucket to infra/terraform/s3.tf
         ↓
git push origin main
         ↓
Workflow auto-triggers
         ↓
📧 Email: "Drift detected! 1 new resource will be created"
         ↓
You approve
         ↓
Terraform creates the S3 bucket ✅
```

### Scenario 3: Someone Modifies Tags in AWS

```
Someone adds tags to an EC2 instance in AWS console
         ↓
You trigger drift detection
         ↓
Terraform sees the tags don't match
         ↓
📧 Email: "Drift detected! 1 resource will be modified"
         ↓
You approve
         ↓
Terraform updates tags to match configuration ✅
```

---

## Email Examples

### Drift Detected Email

```
From: DevOps CI/CD
To: herdeybayor4real@gmail.com
Subject: 🚨 Infrastructure Drift Detected - DevOps Stage 6

Infrastructure drift has been detected in the DevOps Stage 6 project.

Repository: herdeybayor/DevOps-Stage-6
Branch: main
Commit: abc123...
Triggered by: you

Action Required:
Please review the Terraform plan and approve the workflow to apply changes.

View the workflow run: https://github.com/herdeybayor/DevOps-Stage-6/actions/runs/123456789

This is an automated notification from your CI/CD pipeline.
```

### Success Email

```
From: DevOps CI/CD
Subject: ✅ Infrastructure Deployment Successful - DevOps Stage 6

Infrastructure deployment completed successfully!

Repository: herdeybayor/DevOps-Stage-6
Branch: main

Your application should now be accessible at: https://stage6.hng.codeforgex.dev
```

### Failure Email

```
From: DevOps CI/CD
Subject: ❌ Infrastructure Deployment Failed - DevOps Stage 6

Infrastructure deployment failed!

Repository: herdeybayor/DevOps-Stage-6
Branch: main

Please check the workflow logs: https://github.com/herdeybayor/DevOps-Stage-6/actions/runs/123456789
```

---

## Commands Reference

### Trigger Drift Detection
```bash
gh workflow run infra-deploy.yml --ref main
```

### View Workflow Runs
```bash
gh run list --workflow infra-deploy.yml
```

### View Latest Run Details
```bash
gh run view $(gh run list --workflow infra-deploy.yml --limit 1 --json databaseId -q '.[0].databaseId')
```

### View Run Logs
```bash
gh run view <run-id> --log
```

### List GitHub Secrets
```bash
gh secret list
```

---

## Approval Process

When drift is detected and email is sent:

1. Go to GitHub: https://github.com/herdeybayor/DevOps-Stage-6
2. Click **Actions** tab
3. Click **Infrastructure Deployment** workflow
4. Click the latest failed/waiting run
5. Scroll down to "Wait for Manual Approval" job
6. Click the blue **Review deployments** button
7. Select **production** environment
8. Click **Approve and deploy** or **Reject**

---

## Troubleshooting

### Email Not Received?

Check:
1. Spam folder
2. Gmail account is correct (herdeybayor4real@gmail.com)
3. Secrets are set: `gh secret list | grep GMAIL`
4. Check workflow logs for email send errors

### Drift Not Detected?

This could mean:
- Infrastructure already matches configuration ✅ (Good!)
- Workflow didn't run (check triggers in `.github/workflows/infra-deploy.yml`)
- Changed files don't match watched paths

### Approval Stuck?

The approval is waiting for you to manually approve. To proceed:
1. Go to GitHub Actions
2. Click the run
3. Find "Wait for Manual Approval" job
4. Click "Review deployments"
5. Click "Approve and deploy"

---

## Key Points

✅ **Drift Detection is Automatic**
- Happens every time you push to `infra/terraform/` or `infra/ansible/`
- Or manually with `gh workflow run`

✅ **Email Alerts Are Immediate**
- Sent within seconds of drift detection
- High priority flag set
- Includes all necessary information

✅ **Manual Approval Required**
- No changes applied without your approval
- Safe to review before applying
- Can reject changes if needed

✅ **Complete Audit Trail**
- Every change tracked in GitHub
- Workflow logs available
- Commit history preserved

---

## Your Configuration

**Email Recipient:** herdeybayor4real@gmail.com
**Notification Method:** Gmail SMTP (smtp.gmail.com:587)
**Approval Environment:** production
**Terraform Version:** 1.6.0
**AWS Region:** us-east-1

---

## Next Actions

1. **Check your email** for the test drift notification
2. **Review the workflow run** in GitHub Actions
3. **Practice approval** by approving the test run
4. **Make real changes** to infrastructure files
5. **Monitor emails** going forward

---

## Support

Need help with drift detection?

1. Check the logs: `gh run view <run-id> --log`
2. Review the full guide: `INFRASTRUCTURE-DRIFT-TESTING.md`
3. Check test results: `DRIFT-TESTING-RESULTS.md`

---

**Drift Detection is Ready!** 🚀

Your infrastructure is now protected against configuration drift with automatic email alerts.
