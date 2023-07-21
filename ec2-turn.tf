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
}