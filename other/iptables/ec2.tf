provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "client" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("cloud-init.sh")}"
}

resource "aws_instance" "rproxy" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("cloud-init.sh")}"
}

resource "aws_instance" "web" {
  ami = "ami-a21529cc"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-5a03023f"]
  key_name = "default"
  user_data = "${file("cloud-init.sh")}"
}

output "00" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${aws_instance.web.public_ip}"
}

output "01" {
  value = "tcpdump -n port 8000"
}

output "10" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${aws_instance.rproxy.public_ip}"
}

output "11" {
  value = "sysctl -w net.ipv4.ip_forward=1"
}

output "12" {
  value = "iptables -t nat -A PREROUTING -p tcp --dport 8000 -j DNAT --to-destination ${aws_instance.web.private_ip}"
}

output "13" {
  value = "tcpdump -n port 8000"
}

output "20" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${aws_instance.client.public_ip}"
}

output "21" {
  value = "curl ${aws_instance.web.private_ip}:8000"
}

output "22" {
  value = "curl ${aws_instance.rproxy.private_ip}:8000"
}
