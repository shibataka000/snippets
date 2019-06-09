resource "aws_security_group" "web_service" {
  name = "terraform_v0.12_module_sample"

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
