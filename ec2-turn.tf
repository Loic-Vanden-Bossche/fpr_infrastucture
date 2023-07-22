resource "aws_instance" "turn-server" {
  ami           = "ami-05b5a865c3579bbc4"
  instance_type = "t2.micro"

  user_data = templatefile("${path.module}/scripts/install-run-turn-server.sh", {
    turn_username = "var.turn_username"
    turn_password = "var.turn_password"
  })

  tags = {
    Name  = "fpr-turn-server"
    Owner = "Terraform"
  }

  vpc_security_group_ids = [aws_security_group.turn-server_sg.id]
}

resource "aws_security_group" "turn-server_sg" {
  name        = "fpr-turn-server-sg"
  description = "Security group for the turn server"

  ingress {
    description = "UDP port range 1"
    from_port   = 32355
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "UDP port range 2"
    from_port   = 3478
    to_port     = 3479
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "UDP port range 1"
    from_port   = 32355
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "UDP port range 2"
    from_port   = 3478
    to_port     = 3479
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSL Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}