terraform {
  required_providers {
    aws = {
      configuration_aliases = [aws.alternate]
      source                = "hashicorp/aws"
      version               = "~> 4.57.0"
    }
  }
  required_version = ">= 0.14.9"

  # We store terraform terraform.tfstate on s3 in order to make it persistent and sharable.
  # https://www.terraform.io/docs/language/settings/backends/index.html 
  backend "s3" {
    profile = "lorenzosfienti"
    bucket  = "lorenzosfienti-terraform"
    key     = "terraform-itlorenzosfientiinfo.tfstate"
    region  = "us-east-1"
  }
}

# Configure default AWS Provider
provider "aws" {
  profile = "lorenzosfienti"
  region  = "us-east-1"

  default_tags {
    tags = {
      "ilpost:created-by"  = "terraform"
      "ilpost:project-url" = "https://github.com/lorenzosfienti/it.lorenzosfienti.info.terraform"
    }
  }
}