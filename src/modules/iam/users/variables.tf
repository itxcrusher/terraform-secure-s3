variable "user_name" {
  description = "IAM user name"
  type        = string
}

variable "create_console_password" {
  description = "Create a console password for this user?"
  type        = bool
  default     = false
}

variable "password_length" {
  description = "Length of autogenerated console password"
  type        = number
  default     = 20
}

variable "policy_arns" {
  description = "AWS-managed or custom policy ARNs to attach directly to user"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to add to the user"
  type        = map(string)
  default     = {}
}
