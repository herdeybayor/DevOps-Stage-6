# Generate Ansible inventory file dynamically
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory/hosts.tpl", {
    app_server_ip  = aws_eip.app_server.public_ip
    ssh_user       = "ubuntu"
    ssh_key_file   = "~/.ssh/${var.key_name}.pem"
  })
  filename = "${path.module}/../ansible/inventory/hosts"

  depends_on = [
    aws_instance.app_server,
    aws_eip.app_server
  ]
}

# Create Ansible extra vars file
resource "local_file" "ansible_extra_vars" {
  content = templatefile("${path.module}/../ansible/extra_vars.yml.tpl", {
    domain_name       = var.domain_name
    letsencrypt_email = var.letsencrypt_email
    jwt_secret        = var.jwt_secret
    github_repo_url   = var.github_repo_url
    app_directory     = "/home/ubuntu/app"
  })
  filename = "${path.module}/../ansible/extra_vars.yml"

  depends_on = [
    aws_instance.app_server
  ]
}

# Wait for instance to be ready for SSH connections
resource "null_resource" "wait_for_instance" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for instance to be ready for SSH connections..."
      sleep 30
      max_attempts=30
      attempt=0
      while [ $attempt -lt $max_attempts ]; do
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.app_server.public_ip} "echo 'SSH connection successful'" 2>/dev/null; then
          echo "Instance is ready!"
          exit 0
        fi
        attempt=$((attempt + 1))
        echo "Attempt $attempt of $max_attempts failed. Retrying in 10 seconds..."
        sleep 10
      done
      echo "Failed to establish SSH connection after $max_attempts attempts"
      exit 1
    EOT
  }

  depends_on = [
    aws_instance.app_server,
    aws_eip.app_server,
    local_file.ansible_inventory
  ]
}

# Run Ansible playbook automatically after infrastructure is provisioned
resource "null_resource" "run_ansible" {
  triggers = {
    instance_id     = aws_instance.app_server.id
    inventory_hash  = local_file.ansible_inventory.content
    extra_vars_hash = local_file.ansible_extra_vars.content
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Running Ansible playbook..."
      cd ${path.module}/../ansible
      
      # Check if ansible is installed
      if ! command -v ansible-playbook &> /dev/null; then
        echo "Ansible is not installed. Please install Ansible first."
        echo "  Ubuntu/Debian: sudo apt-get install ansible"
        echo "  macOS: brew install ansible"
        echo "  pip: pip install ansible"
        exit 1
      fi
      
      # Install required Ansible collections
      ansible-galaxy collection install community.docker --force
      
      # Run the playbook
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i inventory/hosts \
        --extra-vars "@extra_vars.yml" \
        playbook.yml
    EOT

    environment = {
      ANSIBLE_FORCE_COLOR = "true"
    }
  }

  depends_on = [
    null_resource.wait_for_instance,
    local_file.ansible_inventory,
    local_file.ansible_extra_vars
  ]
}

# Output to confirm Ansible execution
output "ansible_status" {
  description = "Status of Ansible playbook execution"
  value       = "Ansible playbook has been triggered. Check logs for details."
  depends_on  = [null_resource.run_ansible]
}

