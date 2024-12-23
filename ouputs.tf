output "instance_id" {
  description = "The ID of the newly created EC2 instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.main.arn
}

output "instance_key_name" {
  description = "The name of the key pair used to launch the EC2 instance"
  value       = aws_instance.main.key_name
}

output "ssh_connection_command" {
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.main.public_ip}"
  description = "SSH command to connect to the EC2 instance"
}

output "sg_id" {
  value = aws_security_group.allow_ssh[0].id
  description = "ID of the security group to allow SSH access"
}