/**
 * Terraform AWS Elasticache Redis
 *
 * Introducing the AWS ElastiCache Redis Cluster Terraform Module, a highly efficient solution for creating and managing
 * your Redis clusters within Amazon Web Services (AWS). This module has been expertly crafted to provide you with a
 * simple and streamlined way to create and manage your Redis clusters within AWS ElastiCache.
 *
 * Our team of experts has years of experience working with AWS ElastiCache and has a deep understanding of the best
 * practices and configurations. By using this Terraform module, you can be sure that your Redis clusters are created
 * and managed in a secure, efficient, and scalable manner.
 *
 * This module offers a preconfigured solution for creating Redis clusters, saving you time and effort in the process.
 * Whether you're looking to improve the performance of your applications or to implement a highly available and
 * scalable cache, this module has you covered.
 *
 * So, if you're looking for a convenient and reliable solution for creating and managing your Redis clusters within
 * AWS ElastiCache, look no further than the AWS ElastiCache Redis Cluster Terraform Module. Give it a try and see the
 * difference it can make in your AWS setup!
 */
resource "aws_elasticache_replication_group" "redis" {
  # Naming
  replication_group_id = var.replication_group_id
  description          = var.description

  # The engine version to use
  engine         = var.engine
  engine_version = var.engine_version

  # Cluster settings
  data_tiering_enabled = var.data_tearing_enabled
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters

  # Parameters
  parameter_group_name = length(var.parameters) > 0 ? module.elasticache_parameter_group[0].name : null

  # Auto failover
  automatic_failover_enabled = var.num_cache_clusters >= 2 ? true : false

  # Multi AZ
  multi_az_enabled = var.num_cache_clusters >= 2 ? true : false

  # Encryption
  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  kms_key_id                 = var.enable_customer_managed_kms ? module.kms[0].key_arn : var.kms_key_id

  # Network
  port               = var.port
  security_group_ids = var.security_group_ids
  subnet_group_name  = var.vpc_subnet_group_name

  # Backup
  final_snapshot_identifier = "${var.replication_group_id}-final"
  snapshot_retention_limit  = var.snapshot_retention_limit
  snapshot_window           = var.snapshot_window

  # Maintenance
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  maintenance_window         = var.maintenance_window

  # Token
  auth_token = random_password.main_password.result

  # SNS Notification
  notification_topic_arn = module.sns.arn

  # Log Delivery
  dynamic "log_delivery_configuration" {
    for_each = var.log_type

    content {
      destination      = module.cloudwatch_log_group[log_delivery_configuration.value].name
      destination_type = var.log_destination_type

      log_format = var.log_format
      log_type   = log_delivery_configuration.value
    }
  }

  tags = var.tags
}

resource "random_password" "main_password" {
  length  = var.auth_token_length
  special = var.auth_token_special_characters
}

module "elasticache_parameter_group" {
  count = length(var.parameters) > 0 ? 1 : 0

  source = "./modules/elasticache_parameter_group/"

  name       = coalesce(var.parameter_group_name, var.replication_group_id)
  family     = coalesce(var.parameter_group_family, "${var.engine}${var.engine_version}")
  parameters = var.parameters

  tags = var.tags
}

module "cloudwatch_log_group" {
  for_each = var.log_destination_type == "cloudwatch-logs" ? toset(var.log_type) : []

  source  = "geekcell/cloudwatch-log-group/aws"
  version = ">= 2.0.0, < 3.0.0"

  name = "/elasticache-${var.engine}/cluster/${var.replication_group_id}/log/${each.key}"

  retention_in_days           = var.log_retention_in_days
  skip_destroy                = var.log_skip_destroy
  enable_customer_managed_kms = var.log_enable_customer_managed_kms

  tags = var.tags
}

module "kms" {
  count = var.enable_customer_managed_kms ? 1 : 0

  source  = "geekcell/kms/aws"
  version = ">= 1.0.0, < 2.0.0"

  alias = "elasticache/cluster/${var.engine}/${var.replication_group_id}"
  tags  = var.tags
}

module "sns" {
  source  = "geekcell/sns-email-notification/aws"
  version = ">= 1.0.0, < 2.0.0"

  name            = "${var.replication_group_id}-elasticache"
  email_addresses = var.sns_event_recipients

  enable_sns_sse_encryption = var.enable_sns_sse_encryption
  sns_kms_master_key_id     = var.sns_kms_master_key_id

  tags = var.tags
}
