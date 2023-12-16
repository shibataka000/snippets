provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/step_functions/step_functions"
    region = "ap-northeast-1"
  }
}
