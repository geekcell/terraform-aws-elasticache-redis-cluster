/**
 * Terraform AWS Elasticache Redis module
 *
 * Terraform module which creates a AWS Elasticache Redis cluster.

 * The focus on this module lies within it's simplicity by providing default values
 * that should make sense for most use cases.
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
  security_group_ids = [var.security_group_ids]
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
}

module "cloudwatch_log_group" {
  source   = "../terraform-aws-cloudwatch-log-group"
  for_each = toset(var.log_type)

  name = "/elasticache-${var.engine}/cluster/${var.replication_group_id}/log/${each.key}"
}

module "elasticache_parameter_group" {
  source = "./modules/elasticache_parameter_group/"

  name = var.replication_group_id
}

module "kms" {
  source = "../terraform-aws-kms"

  alias = format("alias/%s", "elasticache/cluster/${var.engine}/${var.replication_group_id}")
}

module "sns" {
  source = "github.com/geekcell/terraform-aws-sns-email-notification"

  name = var.replication_group_id

  email_addresses = var.elasticache_event_recipients
}

resource "random_password" "main_password" {
  length  = 24
  special = false
}
