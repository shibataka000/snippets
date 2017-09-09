provider "aws" {
  region = "ap-northeast-1"
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

resource "aws_instance" "ubuntu_16_04" {
  ami = "${data.aws_ami.ubuntu_16_04.image_id}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.medium"
  key_name = "default"
  user_data = "${file("cloud-init.sh")}"
}

output "ssh" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${aws_instance.ubuntu_16_04.public_ip}"
}

output "http" {
  value = "http://${aws_instance.ubuntu_16_04.public_ip}:5601"
}
