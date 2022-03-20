provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/aws/rds/aurora-postgresql"
    region = "ap-northeast-1"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier  = "aurora-postgresql-demo"
  engine              = "aurora-postgresql"
  availability_zones  = data.aws_availability_zones.available.names # ["ap-northeast-1a", "ap-northeast-1c"]
  database_name       = "mydb"
  master_username     = "postgres"
  master_password     = "postgres"
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "postgresql" {
  count              = 2
  identifier         = "aurora-postgresql-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
}
