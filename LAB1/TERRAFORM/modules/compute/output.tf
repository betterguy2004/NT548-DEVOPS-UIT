output "instance_ip_addr_public" {
  value = aws_eip.demo-eip.public_ip
}

output "instance_ip_addr_private" {
  value = [aws_instance.public-instance.private_ip, aws_instance.private-instance.private_ip]
}