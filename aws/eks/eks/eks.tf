provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/aws/eks/eks.tf"
    region = "ap-northeast-1"
  }
}

resource "aws_iam_role" "eks_service_role" {
  name = "eks_service_role"
  assume_role_policy = "${file("./files/service_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = "${aws_iam_role.eks_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role = "${aws_iam_role.eks_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_cloudformation_stack" "vpc"{
  name = "eks-vpc"
  template_url = "https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-08-30/amazon-eks-vpc-sample.yaml"
}

resource "aws_eks_cluster" "sample" {
  name = "sample"
  role_arn = "${aws_iam_role.eks_service_role.arn}"
  vpc_config {
    subnet_ids = ["${split(",", aws_cloudformation_stack.vpc.outputs.SubnetIds)}"]
    security_group_ids = ["${aws_cloudformation_stack.vpc.outputs.SecurityGroups}"]
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws --region ${var.region} eks update-kubeconfig --name ${aws_eks_cluster.sample.name}"
  }
}

resource "aws_cloudformation_stack" "worker_node"{
  name = "eks-worker-node"
  template_url = "https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-08-30/amazon-eks-nodegroup.yaml"
  parameters {
    ClusterName = "${aws_eks_cluster.sample.name}"
    ClusterControlPlaneSecurityGroup = "${aws_cloudformation_stack.vpc.outputs.SecurityGroups}"
    NodeGroupName = "worker"
    NodeImageId = "${lookup(var.worker_node_image_id, var.region)}"
    KeyName = "default"
    VpcId = "${aws_cloudformation_stack.vpc.outputs.VpcId}"
    Subnets = "${aws_cloudformation_stack.vpc.outputs.SubnetIds}"
  }
  capabilities = ["CAPABILITY_IAM"]
}

data "template_file" "aws_auth_cm" {
  template = "${file("./files/aws-auth-cm.yaml")}"
  vars {
    instance_role_arn = "${aws_cloudformation_stack.worker_node.outputs.NodeInstanceRole}"
  }
}

resource "local_file" "aws_auth_cm" {
  content = "${data.template_file.aws_auth_cm.rendered}"
  filename = "files/aws-auth-cm-rendered.yaml"
}

resource "null_resource" "kubectl_apply_config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.aws_auth_cm.filename}"
  }
  depends_on = ["null_resource.kubeconfig"]
}
