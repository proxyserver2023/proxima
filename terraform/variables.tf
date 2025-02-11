variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Project Name"
  type        = string
  default     = "alexandria"
}

variable "stage" {
  description = "Stage"
  type        = string
  default     = "dev"
}
