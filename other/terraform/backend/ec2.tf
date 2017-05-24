provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-bucket"
    key = "terraform_backend_sample.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_instance" "ubuntu" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
}

output "ssh" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${aws_instance.ubuntu.public_ip}"
}
