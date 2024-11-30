variable "environment" {
  description = "The deployment environment. Valid values are development, staging, or production."
  type        = string
  default     = "development"
  validation {
    condition     = contains(["staging", "production", "development"], var.environment)
    error_message = "Environment must be one of staging, production, or development."
  }
}
