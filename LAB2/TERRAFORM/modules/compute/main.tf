resource "aws_instance" "public-instance" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.public_ec2_security_group_ids # Changed
  subnet_id = var.public_subnet_id
  tags = {
    Name = "NT548 Demo Public"
  }
}
resource "aws_instance" "private-instance" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.private_ec2_security_group_ids # Changed
  subnet_id = var.private_subnet_id
  tags = {
    Name = "NT548 Demo Private"
  }
}
resource "aws_eip" "demo-eip" {
  instance = aws_instance.public-instance.id
}