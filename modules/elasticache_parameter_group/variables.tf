variable "family" {
  default     = "redis7"
  description = "The family of the ElastiCache parameter group."
  type        = string
}

variable "name" {
  description = "The name of the ElastiCache parameter group."
  type        = string
}

variable "parameters" {
  default = [
    {
      name  = "maxmemory-policy"
      value = "volatile-lru"
    }
  ]
  description = "The name and Values of the Elasticache parameters."
  type = list(object({
    name  = string
    value = string
  }))
}
