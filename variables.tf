variable "admin_username" {
  type        = string
  description = "The administrator username for the Linux virtual machine."
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "The administrator password for the Linux virtual machine."
  sensitive   = true
}