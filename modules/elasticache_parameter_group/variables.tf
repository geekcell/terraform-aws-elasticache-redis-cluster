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
  default     = []
  description = "The name and Values of the Elasticache parameters."
  type = list(object({
    name  = string
    value = string
  }))
}

variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
}
