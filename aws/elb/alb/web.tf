provider "aws" {
  region = "ap-northeast-1"
}

variable "vpc_id" {
  default = "vpc-3fac305a"
}

variable "subnet_ids" {
  default = ["subnet-c44132b3", "subnet-ba2ca7e3"]
}

variable "availability_zones" {
  default = ["ap-northeast-1a", "ap-northeast-1c"]
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

resource "aws_security_group_rule" "elb_to_instance" {
  security_group_id = "${data.aws_security_group.default.id}"
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = "${data.aws_security_group.default.id}"
  description = "elb_to_instance"
}

resource "aws_lb" "sample" {
  name = "sample"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${data.aws_security_group.default.id}"]
  subnets = "${var.subnet_ids}"
}

resource "aws_lb_listener" "sample" {
  load_balancer_arn = "${aws_lb.sample.arn}"
  port = "80"
  protocol  = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.sample.arn}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "sample" {
  name = "sample"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}

resource "aws_autoscaling_group" "sample" {
  availability_zones = "${var.availability_zones}"
  name = "sample"

  max_size = 2
  min_size = 2
  desired_capacity = 2
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.nginx.name}"

  target_group_arns = ["${aws_lb_target_group.sample.arn}"]
}

resource "aws_launch_configuration" "nginx" {
  image_id = "${data.aws_ami.ubuntu_16_04.image_id}"
  security_groups = ["${data.aws_security_group.default.id}"]
  instance_type = "t2.micro"
  key_name = "default"
  user_data = "${file("cloud-init.sh")}"
}

output "url" {
  value = "http://${aws_lb.sample.dns_name}"
}
