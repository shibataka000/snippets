provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/other/nginx/nginx.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "ubuntu_16_04" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

data "aws_security_group" "default" {
  name = "default"
}

resource "aws_instance" "nginx" {
  ami = "${data.aws_ami.ubuntu_16_04.image_id}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.micro"
  key_name = "default"
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/aws_default")}"
  }
  provisioner "remote-exec" {
    script = "./install_nginx.sh"
  }
}

output "ssh" {
  value = "ssh ubuntu@${aws_instance.nginx.public_dns}"
}
