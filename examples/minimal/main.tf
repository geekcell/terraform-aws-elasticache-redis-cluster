module "example" {
  source = "../../"

  replication_group_id  = "php-session"
  node_type             = "cache.t4g.micro"
  num_cache_clusters    = 2
  security_group_ids    = ["sg-12345678910"]
  vpc_subnet_group_name = "example"
}
