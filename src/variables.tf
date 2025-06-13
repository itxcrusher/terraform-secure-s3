# src/variables.tf
variable "app-names-list" {
  description = <<EOF
List of strings, each in the form:
  <AppName>-<Environment>-<KeyGroupName>

Example:
[
  "test-dev-keygroupdev",
  "test-qa-keygroupqa",
  "test-prod-keygroupprod"
]
EOF
  type        = list(string)
}
