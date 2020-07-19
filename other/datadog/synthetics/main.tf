provider "aws" {
  region = "ap-northeast-1"
}

provider "datadog" {
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/other/datadog/synthetics.tf"
    region = "ap-northeast-1"
  }
}

resource "datadog_synthetics_test" "test_api" {
  type    = "api"
  subtype = "http"
  request = {
    method = "GET"
    url    = "https://www.example.org"
  }
  request_headers = {
    Content-Type   = "application/json"
    Authentication = "Token: 123456789"
  }
  assertions = [
    {
      type     = "statusCode"
      operator = "is"
      target   = "200"
    }
  ]
  locations = ["aws:eu-central-1"]
  options = {
    tick_every = 900
  }
  name    = "An API test on example.org"
  tags    = ["foo:bar", "foo", "env:test"]
  message = "Notify"
  status  = "live"
}

resource "datadog_synthetics_test" "test_ssl" {
  type    = "api"
  subtype = "ssl"
  request = {
    host = "example.org"
    port = 443
  }
  assertions = [
    {
      type     = "certificate"
      operator = "isInMoreThan"
      target   = 30
    }
  ]
  locations = ["aws:eu-central-1"]
  options = {
    tick_every         = 900
    accept_self_signed = true
  }
  name    = "An API test on example.org"
  message = "Notify"
  tags    = ["foo:bar", "foo", "env:test"]
  status  = "live"
}

resource "datadog_synthetics_test" "test_browser" {
  type = "browser"
  request = {
    method = "GET"
    url    = "https://app.datadoghq.com"
  }
  device_ids = ["laptop_large"]
  locations  = ["aws:eu-central-1"]
  options = {
    tick_every = 3600
  }
  name    = "A Browser test on app.datadoghq.com"
  message = "Notify"
  tags    = ["foo:bar", "foo", "env:test"]
  status  = "paused"
}
