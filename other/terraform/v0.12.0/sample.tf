provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/other/terraform/v0.12.0/sample.tfstate"
    region = "ap-northeast-1"
  }
}

variable sample {
  type = object({
    n = number
    s = string
    ln = list(number)
    ls = list(string)
    ms = map(string)
  })
  default = {
    n = 1
    s = "a"
    ln = [1]
    ls = ["a"]
    ms = {key1 = "value1"}
  }
}

resource "aws_security_group" "web_service" {
  name = "terraform_v0.12_sample"
  description = null

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "sample" {
  source = "./module"
}

output "for_expressions_list" {
  value = [for s in ["a", "b", "c"]: upper(s) if s != "a"]
}

output "for_expressions_map" {
  value = {for s in ["a", "b", "c"]: s => upper(s)}
}

output "rich_types_in_module_inputs_variables_and_output_values" {
  value = var.sample
}

output "resource_and_module_object_value" {
  value = module.sample.sg.id
}
