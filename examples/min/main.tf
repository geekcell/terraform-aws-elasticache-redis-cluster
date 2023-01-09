module "example" {
  source = "../../"

  name_prefix           = "session-manager"
  node_type             = "cache.t4g.micro"
  num_cache_clusters    = 2
  replication_group_id  = "session"
  security_group_ids    = ["sg-12345678910"]
  subnet_ids            = ["subnet-12345678910"]
  vpc_id                = "vpc-012345678910"
  vpc_subnet_group_name = "example"
}
