provider "aws" {
  region = "ap-northeast-1"
}

data "aws_ami" "windows_server" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [
      # "Windows_Server-2016-English-Full-Base-*"
      # "Windows_Server-2012-R2_RTM-English-64Bit-Base-*"
      # "Windows_Server-2012-RTM-English-64Bit-Base-*"
      # "windows_server-2008-R2_SP1-English-64Bit-Base-*"
      "Windows_Server-2008-SP2-English-64Bit-Base-*"
    ]
  }
}

data "aws_security_group" "default" {
  name = "default"
}

resource "aws_instance" "windows_server" {
  ami = "${data.aws_ami.windows_server.image_id}"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.medium"
  key_name = "default"
  iam_instance_profile = "SSM"
  tags {
    "Patch Group" = "patchgroup01"
  }
}

output "instance_id" {
  value = "${aws_instance.windows_server.id}"
}

output "public_ip" {
  value = "${aws_instance.windows_server.public_ip}"
}
