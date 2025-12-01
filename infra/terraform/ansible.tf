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

# Output Ansible inventory and variables for separate workflow
output "ansible_inventory_file" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "ansible_vars_file" {
  description = "Path to generated Ansible variables"
  value       = local_file.ansible_extra_vars.filename
}

output "server_ip" {
  description = "EC2 instance public IP for Ansible"
  value       = aws_eip.app_server.public_ip
}

output "instance_ready_message" {
  description = "Run Ansible separately using the generated inventory"
  value       = "Terraform infrastructure created. Run separate Ansible workflow to deploy application."
}

