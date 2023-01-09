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

variable "auto_minor_version_upgrade" {
  default     = false
  description = "Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window."
  type        = string
}

variable "automatic_failover_enabled" {
  default     = false
  description = " Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails."
  type        = bool
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

variable "elasticache_event_recipients" {
  default     = []
  description = "Recipients of the elasticache events."
  type        = list(string)
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

variable "multi_az_enabled" {
  default     = false
  description = "Specifies whether to enable Multi-AZ Support for the replication group."
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

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the cache subnet group."
  type        = list(string)
}

variable "transit_encryption_enabled" {
  default     = true
  description = "Whether to enable encryption in transit."
  type        = bool
}

variable "vpc_id" {
  description = "The VPC ID where resources are created."
  type        = string
}

variable "vpc_subnet_group_name" {
  description = "Subnet group name for the Elasticache cluster."
  type        = string
}

# Cloudwatch log group delivery
variable "destination_type" {
  default     = "cloudwatch-logs"
  description = "For CloudWatch Logs use `cloudwatch-logs` or for Kinesis Data Firehose use `kinesis-firehose`."
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
    error_message = "The log_type allowed are only slow-log and engine-log."
  }
}
