provider "aws" {
  region = "ap-northeast-1"
}

module "sample" {
  source = "../modules/cluster"
  cluster_name = "sample123"
}

output "ssh" {
  value = "ssh -i ~/.ssh/ec2_default.pem ubuntu@${module.sample.web_public_ip}"
}
