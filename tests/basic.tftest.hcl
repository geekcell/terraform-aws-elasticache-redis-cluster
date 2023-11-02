variables {
  name = "test-redis-cluster"
}

run "setup" {
  module {
    source = "./tests/network"
  }
}

run "basic_redis_cluster" {
  variables {
    replication_group_id  = var.name
    node_type             = "cache.t4g.micro"
    num_cache_clusters    = 2
    security_group_ids    = [run.setup.security_group_id]
    vpc_subnet_group_name = run.setup.elasticache_subnet_group_name
  }

  assert {
    condition     = length(aws_elasticache_replication_group.redis.arn) >= 0
    error_message = "Expected cluster to be created."
  }

  assert {
    condition     = length(output.primary_endpoint_address) >= 0
    error_message = "Expected primary endpoint to be included in output."
  }

  assert {
    condition     = length(output.reader_endpoint_address) >= 0
    error_message = "Expected reader endpoint to be included in output."
  }

  assert {
    condition     = length(output.auth_token) >= 0
    error_message = "Expected auth_token to be included in output."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.node_type == "cache.t4g.micro"
    error_message = "Expected node type to be cache.t4g.micro."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.num_cache_clusters == 2
    error_message = "Expected 2 cache clusters."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.engine == "redis"
    error_message = "Expected engine to be redis."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.engine_version == "7.0"
    error_message = "Expected engine version to be 7.0."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.multi_az_enabled == true
    error_message = "Expected multi AZ to be enabled."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.at_rest_encryption_enabled == true
    error_message = "Expected at rest encryption to be enabled."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.transit_encryption_enabled == true
    error_message = "Expected transit encryption to be enabled."
  }

  assert {
    condition     = length(random_password.main_password) >= 24
    error_message = "Expected random password to be created."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.auth_token == random_password.main_password.result
    error_message = "Expected auth token to match password."
  }

  assert {
    condition     = length(module.kms.key_arn) >= 0
    error_message = "Expected KMS key to be created."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.kms_key_id == module.kms.key_arn
    error_message = "Expected cluster KMS key to be created kms key."
  }

  assert {
    condition     = length(module.sns.arn) >= 0
    error_message = "Expected SNS topic to be created."
  }

  assert {
    condition     = aws_elasticache_replication_group.redis.notification_topic_arn == module.sns.arn
    error_message = "Expected cluster notification topic to match created SNS topic."
  }
}
