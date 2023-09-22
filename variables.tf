# Context
variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
}

# AWS Elasticache Redis Cluster
variable "apply_immediately" {
  default     = true
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
  type        = bool
}

variable "at_rest_encryption_enabled" {
  default     = true
  description = "Whether to enable encryption at rest."
  type        = bool
}

variable "kms_key_id" {
  description = "The ARN of the AWS KMS to encrypt data at rest. Uses the AWS service managed encryption if not specified."
  default     = null
  type        = string
}

variable "enable_customer_managed_kms" {
  description = "If enabled, will create a customer managed KMS key for at-rest encryption."
  default     = false
  type        = bool
}

variable "auto_minor_version_upgrade" {
  default     = false
  description = "Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window."
  type        = string
}

variable "data_tearing_enabled" {
  default     = false
  description = "Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type."
  type        = bool
}

variable "description" {
  default     = "Managed by Terraform"
  description = "The description of the all resources."
  type        = string
}

variable "engine" {
  default     = "redis"
  description = " Name of the cache engine to be used for the clusters in this replication group."
  type        = string
}

variable "engine_version" {
  default     = "7.0"
  description = "The version number of the cache engine to be used for the cache clusters in this replication group."
  type        = string
}

variable "maintenance_window" {
  default     = "Mon:00:00-Mon:03:00"
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed."
  type        = string
}

variable "node_type" {
  description = "The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
  type        = string
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2"
  type        = number
}

variable "port" {
  default     = 6379
  description = "Port number on which each of the cache nodes will accept connections."
  type        = number
}

variable "replication_group_id" {
  description = "ID of the replication group to which this cluster should belong."
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with this replication group."
  type        = list(string)
}

variable "snapshot_retention_limit" {
  default     = 7
  description = "Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  type        = number
}

variable "snapshot_window" {
  default     = "03:30-05:30"
  description = "Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster."
  type        = string
}

variable "transit_encryption_enabled" {
  default     = true
  description = "Whether to enable encryption in transit."
  type        = bool
}

variable "vpc_subnet_group_name" {
  description = "Subnet group name for the Elasticache cluster."
  type        = string
}

# Auth Token
variable "auth_token_length" {
  description = "The length of the generated auth token."
  default     = 24
  type        = number
}

variable "auth_token_special_characters" {
  description = "Whether to include special characters in the generated auth token."
  default     = false
  type        = bool
}

# Parameter Group
variable "parameter_group_name" {
  description = "The name of the ElastiCache parameter group. Defaults to the cluster name."
  default     = null
  type        = string
}

variable "parameter_group_family" {
  description = "The family of the ElastiCache parameter group. Defaults to engine and engine_version."
  default     = null
  type        = string
}

variable "parameters" {
  description = "Set custom parameters via a parameter group."
  default     = []
  type = list(object({
    name  = string
    value = string
  }))
}

# Logging
variable "log_destination_type" {
  default     = "cloudwatch-logs"
  description = "For CloudWatch Logs use `cloudwatch-logs` or for Kinesis Data Firehose use `kinesis-firehose`. Only 'cloudwatch-logs' supported at the moment."
  type        = string
}

variable "log_format" {
  default     = "text"
  description = "Valid values are `json` or `text`."
  type        = string
}

variable "log_type" {
  default     = ["slow-log", "engine-log"]
  type        = list(string)
  description = "Type of logs, slow-log and engine-log"

  validation {
    condition = alltrue([
      for type in var.log_type : contains(["slow-log", "engine-log"], type)
    ])
    error_message = "The allowed log types are 'slow-log' and 'engine-log'."
  }
}

variable "log_retention_in_days" {
  description = "The number of days log events are kept in CloudWatch Logs."
  default     = 30
  type        = number
}

variable "log_skip_destroy" {
  description = "Whether to skip the deletion of the log groups when deleting the log group resources."
  default     = false
  type        = bool
}

variable "log_enable_customer_managed_kms" {
  description = "Whether to enable customer managed KMS key for CloudWatch Logs encryption."
  default     = false
  type        = bool
}

# SNS Topic
variable "enable_sns_sse_encryption" {
  description = "Enable SSE Encryption for SNS Topic."
  default     = true
  type        = bool
}

variable "sns_kms_master_key_id" {
  description = "The ID of an AWS KMS key for the SNS topic."
  default     = "alias/aws/sns"
  type        = string
}

variable "sns_event_recipients" {
  default     = []
  description = "Recipients of the ElastiCache SNS event topic. Should be a list of E-Mails."
  type        = list(string)
}
