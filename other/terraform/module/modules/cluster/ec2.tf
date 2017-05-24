variable "cluster_name" {}

resource "aws_instance" "ap" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  tags {
    Name = "${var.cluster_name}_web"
  }
}

resource "aws_instance" "db" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  tags {
    Name = "${var.cluster_name}_db"
  }
}

resource "aws_instance" "web" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  tags {
    Name = "${var.cluster_name}_web"
  }
}

output "web_public_ip" {
  value = "${aws_instance.web.public_ip}"
}
