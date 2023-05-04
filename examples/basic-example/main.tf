module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 3.19"

  name = "${var.name}-main"
  cidr = "10.100.0.0/16"
  azs  = ["eu-central-1a", "eu-central-1b"]

  elasticache_subnets = ["10.100.10.0/24", "10.100.11.0/24"]
}

module "redis_security_group" {
  source = "github.com/geekcell/terraform-aws-security-group?ref=main"

  name   = "${var.name}-redis"
  vpc_id = module.vpc.vpc_id
}

module "basic-example" {
  source = "../../"

  replication_group_id  = var.name
  node_type             = "cache.t4g.micro"
  num_cache_clusters    = 2
  security_group_ids    = [module.redis_security_group.security_group_id]
  vpc_subnet_group_name = module.vpc.elasticache_subnet_group_name
}
