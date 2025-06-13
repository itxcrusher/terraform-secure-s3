# src/variables.tf

# variable "app-names-list" {
#   description = <<EOF
# List of strings, each in the form:
#   <AppName>-<Environment>-<KeyGroupName>

# Example:
# [
#   "test-dev-keygroupdev",
#   "test-qa-keygroupqa",
#   "test-prod-keygroupprod"
# ]
# EOF
#   type        = list(string)
# }


variable "apps_yaml_path" {
  description = "Relative path to the YAML manifest"
  type        = string
  default     = "./apps.yaml"
}

variable "env_filter" {
  description = "Optional – deploy only one environment (dev/qa/prod). Empty = all"
  type        = string
  default     = ""
}
