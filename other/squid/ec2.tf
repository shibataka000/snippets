provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "ubuntu" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("cloudinit.sh")}"
}
