# Infrastructure Drift Detection & Testing Guide

## Overview

The DevOps Stage 6 project includes comprehensive **Infrastructure Drift Detection** that:
- Automatically detects when actual infrastructure differs from Terraform configuration
- Sends email alerts when drift is detected
- Requires manual approval before applying changes
- Provides detailed Terraform plan summaries

## How Drift Detection Works

### Workflow Process

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Terraform Plan & Drift Detection Job                         │
│    - Runs terraform plan                                        │
│    - Converts plan to JSON                                      │
│    - Compares desired state vs actual state                     │
│    - Outputs number of resources with changes                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Check for Drift Logic                                        │
│    - If CHANGES > 0: has_changes=true                           │
│    - Outputs warning: "Infrastructure drift detected!"          │
│    - If NO changes: has_changes=false                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Send Drift Notification Email (if drift detected)            │
│    - To: NOTIFICATION_EMAIL                                     │
│    - Subject: 🚨 Infrastructure Drift Detected                  │
│    - Body: Repository, branch, commit, workflow link            │
│    - Priority: HIGH                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Wait for Manual Approval                                     │
│    - Blocks further progress until approved in GitHub           │
│    - Environment: production                                    │
│    - Only if drift detected and not pull request                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. Terraform Apply (after approval)                             │
│    - Applies the planned changes                                │
│    - Sends success or failure email                             │
│    - Updates infrastructure to match configuration              │
└─────────────────────────────────────────────────────────────────┘
```

## Required GitHub Secrets for Infrastructure Workflow

The following secrets must be configured for the Infrastructure Deployment workflow:

```
✅ AWS_ACCESS_KEY_ID         - AWS IAM access key
✅ AWS_SECRET_ACCESS_KEY     - AWS IAM secret key
✅ SSH_PRIVATE_KEY           - EC2 SSH deployment key
✅ KEY_NAME                  - EC2 key pair name
✅ DOMAIN_NAME               - Domain for the application
✅ LETSENCRYPT_EMAIL         - Email for Let's Encrypt certificates
✅ JWT_SECRET                - JWT secret for authentication
✅ GMAIL_USERNAME            - Gmail address for notifications
✅ GMAIL_APP_PASSWORD        - Gmail app password
✅ NOTIFICATION_EMAIL        - Email to receive drift alerts
```

## Test Scenarios for Drift Detection

### Test 1: Detect Deleted Security Group (Simulated Drift)

**What to do:**
1. Manually delete a security group from AWS console
2. Trigger the Infrastructure Deployment workflow
3. Terraform plan will detect the missing resource

**Expected Behavior:**
- ✅ Terraform plan shows resource recreation needed
- ✅ Drift detection email sent to NOTIFICATION_EMAIL
- ✅ Workflow pauses at "Wait for Manual Approval"
- ✅ Approve the workflow to recreate the resource

**How to trigger:**
```bash
# Manually trigger workflow
gh workflow run infra-deploy.yml --ref main

# Or make a change to Terraform files
echo "# test" >> infra/terraform/variables.tf
git add infra/terraform/variables.tf
git commit -m "Trigger drift detection test"
git push origin main
```

### Test 2: Detect Modified EC2 Instance (Simulated Drift)

**What to do:**
1. Modify EC2 instance tags/properties in AWS console
2. Trigger workflow
3. Plan detects differences

**Expected Behavior:**
- ✅ Terraform detects modified resource
- ✅ Plan shows old vs new values
- ✅ Email alert sent with `terraform show tfplan` output
- ✅ Manual approval required before applying

### Test 3: Detect New Resource Added to Terraform

**What to do:**
1. Add a new resource to a Terraform file (e.g., new S3 bucket)
2. Push to main branch
3. Workflow triggers automatically

**Expected Behavior:**
- ✅ Terraform plan shows new resource creation
- ✅ Drift email sent
- ✅ Approval required before resource is created

### Test 4: No Drift Scenario

**What to do:**
1. Run workflow with no changes to Terraform files
2. Trigger manually with `gh workflow run`

**Expected Behavior:**
- ✅ Terraform plan shows no changes
- ✅ has_changes=false
- ✅ No drift notification email sent
- ✅ No approval step needed
- ✅ Terraform apply skipped

## How to Trigger Drift Detection Tests

### Method 1: Manual Workflow Trigger (Recommended)

```bash
# Trigger the Infrastructure Deployment workflow
gh workflow run infra-deploy.yml --ref main

# Check status
gh run list --workflow infra-deploy.yml --limit 1

# View logs
gh run view <run-id> --log
```

### Method 2: Push Changes to Terraform Files

```bash
cd /Users/sherifdeenadebayo/Developer/DevOps-Stage-6

# Make a change to trigger workflow
echo "" >> infra/terraform/variables.tf

# Commit and push
git add infra/terraform/variables.tf
git commit -m "Test: Trigger infrastructure drift detection"
git push origin main
```

### Method 3: Pull Request (Safe Testing)

```bash
# Create a feature branch
git checkout -b test/drift-detection

# Make Terraform changes
echo "# test comment" >> infra/terraform/main.tf

# Commit and push
git add infra/terraform/main.tf
git commit -m "Test: Drift detection changes"
git push origin test/drift-detection

# Create PR - workflow will run in PR context
gh pr create --title "Test: Drift Detection" \
  --body "Testing infrastructure drift detection"

# Approve the PR to merge (or close to cleanup)
```

## Email Alerts Configuration

### Drift Detection Email

**When sent:** When `has_changes > 0`

**Subject:** `🚨 Infrastructure Drift Detected - DevOps Stage 6`

**Recipients:** `NOTIFICATION_EMAIL` secret (currently: herdeybayor4real@gmail.com)

**Content:**
- Repository and branch info
- Commit that triggered detection
- Who triggered it (GitHub actor)
- Link to workflow run
- Instructions to review and approve

### Success Email

**When sent:** After `terraform apply` succeeds

**Subject:** `✅ Infrastructure Deployment Successful - DevOps Stage 6`

**Content:**
- Deployment completion confirmation
- Application URL
- Workflow run link

### Failure Email

**When sent:** If `terraform apply` fails

**Subject:** `❌ Infrastructure Deployment Failed - DevOps Stage 6`

**Content:**
- Failure notification
- Link to check logs

## Monitoring Drift Detection

### Via GitHub CLI

```bash
# List infrastructure deployment runs
gh run list --workflow infra-deploy.yml

# View latest run details
gh run view $(gh run list --workflow infra-deploy.yml --limit 1 --json databaseId -q '.[0].databaseId')

# View specific job logs
gh run view <run-id> --job "Terraform Plan & Drift Detection"

# Stream logs as they happen
gh run watch <run-id>
```

### Via GitHub Web UI

1. Go to: https://github.com/herdeybayor/DevOps-Stage-6
2. Click **Actions** tab
3. Select **Infrastructure Deployment** workflow
4. View latest run with drift status

## Terraform Drift Detection Details

### What Gets Checked

The drift detection script (`infra/terraform`) checks:

1. **Resource Changes:** Detects resources that need to be created, modified, or destroyed
2. **State Differences:** Compares actual AWS state vs Terraform state
3. **No-Op Detection:** Filters out operations that don't change anything

### Detection Logic

```bash
# Convert plan to JSON
terraform show -json tfplan > tfplan.json

# Count all resource changes
CHANGES=$(jq -r '.resource_changes // [] | length' tfplan.json)

# Count actual changes (exclude no-op)
ACTUAL_CHANGES=$(jq -r '[.resource_changes[] | select(.change.actions != ["no-op"])] | length' tfplan.json)

# If changes > 0, set has_changes=true and send email
if [ "$ACTUAL_CHANGES" -gt "0" ]; then
  echo "has_changes=true" >> $GITHUB_OUTPUT
fi
```

## Manual Approval Process

When drift is detected:

1. **Email Alert Received**
   - Check your email for drift notification
   - Review the Terraform plan in workflow summary

2. **Review Changes**
   - Go to GitHub Actions → Infrastructure Deployment run
   - Review "Generate Plan Summary" step
   - Check what resources will be changed

3. **Approve in GitHub**
   - Workflow pauses at "Wait for Manual Approval" job
   - In the workflow run, click "Review deployments"
   - Click "Approve and deploy"
   - Or comment to reject changes

4. **Apply Confirmation**
   - Terraform apply job runs automatically
   - Success email sent when complete
   - Infrastructure updated to match configuration

## Current Status

**Configured:** ✅ All 10 secrets configured
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- SSH_PRIVATE_KEY
- KEY_NAME
- DOMAIN_NAME
- LETSENCRYPT_EMAIL
- JWT_SECRET
- GMAIL_USERNAME
- GMAIL_APP_PASSWORD
- NOTIFICATION_EMAIL

**Infrastructure Files:** ✅ Present
- `infra/terraform/` - EC2, security groups, networking
- `infra/ansible/` - Provisioning playbooks

**Email Alerts:** ✅ Configured and ready
- Gmail SMTP: smtp.gmail.com:587
- Recipient: herdeybayor4real@gmail.com

## Next Steps

1. **Trigger a test drift detection:**
   ```bash
   gh workflow run infra-deploy.yml --ref main
   ```

2. **Monitor the workflow** and check your email for drift notifications

3. **Practice manual approval** by reviewing and approving changes

4. **Set up additional tests** by modifying Terraform files and pushing changes

## Troubleshooting

### Issue: Secrets not configured

**Solution:** Run the following to set missing secrets:
```bash
# Check what secrets are configured
gh secret list

# Add missing secrets
gh secret set AWS_ACCESS_KEY_ID -b "your-key"
gh secret set AWS_SECRET_ACCESS_KEY -b "your-secret"
# etc...
```

### Issue: Drift detection not sending emails

**Check:**
1. GMAIL_USERNAME and GMAIL_APP_PASSWORD are correct
2. Gmail account has "Less secure app access" enabled OR using app password
3. NOTIFICATION_EMAIL is valid
4. Check spam folder for emails

### Issue: Terraform plan fails

**Check:**
1. AWS credentials are valid
2. Terraform state file exists in S3 backend
3. SSH key has correct permissions (600)
4. AWS region and resources match configuration

---

## Summary

Your infrastructure drift detection is **fully configured and ready** with:
- ✅ Automatic drift detection on every plan
- ✅ Email alerts when changes detected
- ✅ Manual approval workflow
- ✅ Terraform apply on approval
- ✅ Success/failure notifications

Simply trigger the workflow and monitor your email for drift alerts!
