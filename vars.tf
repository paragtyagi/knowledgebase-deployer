variable "aws_access_key" {
  type        = string
  description = "[ENV VARIABLE] Your AWS Access ID"
}

variable "aws_secret_key" {
  type        = string
  description = "[ENV VARIABLE] Your AWS Secret Key"
}

variable "region" {
  type        = string
  description = "[ENV VARIABLE] The AWS region to create things in."
}

variable "ami" {
  type        = string
  description = "[ENV VARIABLE] The Amazon Machine Image to use."
}

variable "instance_type" {
  type        = string
  description = "[ENV VARIABLE] The EC2 Instance type to use."
}

variable "tag_db_name" {
  type        = string
  description = "[ENV VARIABLE] The Name tag of the DB instance creating."
}

variable "tag_app_name" {
  type        = string
  description = "[ENV VARIABLE] The Name tag of the App instance creating."
}

variable "tag_project" {
  type        = string
  description = "[ENV VARIABLE] The Project tag of the instance creating."
}

variable "tag_environment" {
  type        = string
  description = "[ENV VARIABLE] The Environment tag of the instance creating."
}

variable "postgresql_version" {
  type        = string
  description = "[ENV VARIABLE] The version of Postgresql to install."
}

variable "private_key" {
  type        = string
  description = "[ENV VARIABLE] Path of private key to access your AWS instance."
}

variable "key_name" {
  type        = string
  description = "[ENV VARIABLE] Name of the Key Pair on AWS"
}

variable "db_name" {
  type        = string
  description = "[ENV VARIABLE] Database name."
}

variable "db_user" {
  type        = string
  description = "[ENV VARIABLE] Database username."
}

variable "db_password" {
  type        = string
  description = "[ENV VARIABLE] Database password"
}

variable "db_port" {
  type        = string
  description = "[ENV VARIABLE] Database port"
}

variable "admin_username" {
  type        = string
  description = "[ENV VARIABLE] Username for creating superuser on application"
}

variable "admin_email" {
  type        = string
  description = "[ENV VARIABLE] Email for creating superuser on application"
}

variable "admin_password" {
  type        = string
  description = "[ENV VARIABLE] Password for creating superuser on application"
}

variable "git_branch_name" {
  type        = string
  description = "[ENV VARIABLE] Repo branch name to clone"
}

variable "git_repo_url" {
  type        = string
  description = "[ENV VARIABLE] Repo URL"
}

variable "python_version" {
  type        = string
  description = "[ENV VARIABLE] Python version"
}

variable "project_folder" {
  type        = string
  description = "[ENV VARIABLE] Project Folder"
}
