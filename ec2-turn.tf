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
    description      = "UDP port 1"
    from_port        = 3478
    to_port          = 3478
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "UDP port 2"
    from_port        = 5349
    to_port          = 5349
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TCP port 1"
    from_port        = 3478
    to_port          = 3478
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TCP port 2"
    from_port        = 5349
    to_port          = 5349
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}