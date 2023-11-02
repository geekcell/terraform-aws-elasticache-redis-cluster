terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
