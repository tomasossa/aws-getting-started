variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "sa-east-1"
}

variable "task_definition_name" {
  description = "The name of the ECS task definition."
  type        = string
  default     = "learn-terraform-task"
}

