provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "github.com/ericdahl/tf-vpc"
}
