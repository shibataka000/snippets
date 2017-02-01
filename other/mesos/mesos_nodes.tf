provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "mesos_master" {
  ami = "ami-a21529cc"
  instance_type = "t2.large"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("setup_mesos.sh")}"
}

resource "aws_instance" "mesos_agent_1" {
  ami = "ami-a21529cc"
  instance_type = "t2.large"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("setup_mesos.sh")}"
}

resource "aws_instance" "mesos_agent_2" {
  ami = "ami-a21529cc"
  instance_type = "t2.large"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("setup_mesos.sh")}"
}

output "mesos_master.public_ip" {
  value = "${aws_instance.mesos_master.public_ip}"
}

output "mesos_agent_1.public_ip" {
  value = "${aws_instance.mesos_agent_1.public_ip}"
}

output "mesos_agent_2.public_ip" {
  value = "${aws_instance.mesos_agent_2.public_ip}"
}
