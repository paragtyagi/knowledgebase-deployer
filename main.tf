provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  version    = "~> 2.54"
}

resource "aws_instance" "knowledgebase_app" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "production"
  user_data     = data.template_file.setup_app.rendered

  provisioner "file" {
    source      = "confs/app/"
    destination = "/tmp"
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
    }
  }

  security_groups = [
    aws_security_group.ssh.name,
    aws_security_group.app_servers.name,
    aws_security_group.http.name,
  ]

  tags = {
    Name        = var.tag_app_name
    Project     = var.tag_project
    Environment = var.tag_environment
  }
}

resource "aws_instance" "knowledgebase_db" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "production"
  user_data     = data.template_file.setup_db.rendered

  provisioner "file" {
    source      = "confs/db/"
    destination = "/tmp"
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
    }
  }

  security_groups = [
    aws_security_group.ssh.name,
    aws_security_group.postgres.name,
  ]

  tags = {
    Name        = var.tag_db_name
    Project     = var.tag_project
    Environment = var.tag_environment
  }
}

data "template_file" "setup_db" {
  template = file("templates/setup_db.tpl")

  vars = {
    postgresql_version = var.postgresql_version
    db_name            = var.db_name
    db_user            = var.db_user
    db_password        = var.db_password
    instance_name      = var.tag_db_name
  }
}

data "template_file" "setup_app" {
  template = file("templates/setup_app.tpl")

  vars = {
    instance_name              = var.tag_app_name
    python_version             = var.python_version
    admin_username             = var.admin_username
    admin_email                = var.admin_email
    admin_password             = var.admin_password
    git_branch_name            = var.git_branch_name
    git_repo_url               = var.git_repo_url
    db_name                    = var.db_name
    db_user                    = var.db_user
    db_password                = var.db_password
    db_host                    = aws_instance.knowledgebase_db.private_ip
    db_port                    = var.db_port
    project_folder             = var.project_folder
  }
}