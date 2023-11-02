module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name                = "${var.name}-main"
  cidr                = "10.100.0.0/16"
  azs                 = ["eu-central-1a", "eu-central-1b"]
  private_subnets     = ["10.100.1.0/24", "10.100.2.0/24"]
  elasticache_subnets = ["10.100.10.0/24", "10.100.11.0/24"]
}

module "redis_security_group" {
  source  = "geekcell/security-group/aws"
  version = ">= 2.0.0, < 3.0.0"

  name   = "${var.name}-redis"
  vpc_id = module.vpc.vpc_id
}
