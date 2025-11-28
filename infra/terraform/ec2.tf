# EC2 instance for the application
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_server.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update
              apt-get upgrade -y

              # Set hostname
              hostnamectl set-hostname ${var.project_name}-server

              # Install Docker
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update
              apt-get install -y docker-ce docker-ce-cli containerd.io

              # Install Docker Compose Plugin (Docker Compose v2)
              apt-get install -y docker-compose-plugin

              # Also create a symlink for docker-compose command
              ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

              # Add ubuntu user to docker group
              usermod -aG docker ubuntu

              # Create application directory
              mkdir -p /opt/devops-app
              chown ubuntu:ubuntu /opt/devops-app

              # Create a marker file to indicate instance is initialized
              touch /var/tmp/instance-initialized
              EOF

  # Ensure instance is fully initialized before considering it ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for instance to be fully initialized...'",
      "while [ ! -f /var/tmp/instance-initialized ]; do sleep 5; done",
      "echo 'Instance initialized successfully'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.key_name}.pem")
      host        = self.public_ip
      timeout     = "5m"
    }
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

# Elastic IP for the instance
resource "aws_eip" "app_server" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

