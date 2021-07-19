provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/ecs/fargate/fargate.tf"
    region = "ap-northeast-1"
  }
}
