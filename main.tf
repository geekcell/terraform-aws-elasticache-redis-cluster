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
  parameter_group_name = module.elasticache_parameter_group.name

  # Auto failover
  automatic_failover_enabled = var.num_cache_clusters >= 2 ? true : false

  # Multi AZ
  multi_az_enabled = var.num_cache_clusters >= 2 ? true : false

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

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

  # KMS
  kms_key_id = module.kms.key_arn

  # SNS Notification
  notification_topic_arn = module.sns.arn

  dynamic "log_delivery_configuration" {
    for_each = var.log_type
    content {
      destination      = module.cloudwatch_log_group[log_delivery_configuration.value].name
      destination_type = var.destination_type
      log_format       = var.log_format
      log_type         = log_delivery_configuration.value
    }
  }

  tags = var.tags
}

module "cloudwatch_log_group" {
  source   = "github.com/geekcell/terraform-aws-cloudwatch-log-group?ref=v1.0"
  for_each = toset(var.log_type)

  name = "/elasticache-${var.engine}/cluster/${var.replication_group_id}/log/${each.key}"
}

module "elasticache_parameter_group" {
  source = "./modules/elasticache_parameter_group/"

  name = var.replication_group_id
}

module "kms" {
  source = "github.com/geekcell/terraform-aws-kms?ref=v1.0"

  alias = format("alias/%s", "elasticache/cluster/${var.engine}/${var.replication_group_id}")
}

module "sns" {
  source = "github.com/geekcell/terraform-aws-sns-email-notification?ref=v1.0"

  name = var.replication_group_id

  email_addresses = var.elasticache_event_recipients
}

resource "random_password" "main_password" {
  length  = 24
  special = false
}
