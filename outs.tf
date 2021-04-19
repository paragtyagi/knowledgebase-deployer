output "aws_db_instance_public_ip" {
  value       = aws_instance.knowledgebase_db.public_ip
  description = "The public IP address of the DB server instance."
}

output "aws_app_instance_public_ip" {
  value       = aws_instance.knowledgebase_app.public_ip
  description = "The public IP address of the App server instance."
}

output "aws_app_instance_public_dns" {
  value       = aws_instance.knowledgebase_app.public_dns
  description = "The public DNS address of the App server instance."
}
