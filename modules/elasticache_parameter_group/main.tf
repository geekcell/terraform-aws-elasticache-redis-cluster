resource "aws_elasticache_parameter_group" "main" {
  name   = var.name
  family = var.family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}
