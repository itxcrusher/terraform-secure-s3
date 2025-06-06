#!/usr/bin/env bash
# -------------------------------------------------------------------
# deploy.sh
#
# Wrapper script to initialize, plan, and apply Terraform configuration
# located under the 'terraform/' folder. Expects terraform.tfvars in that folder.
#
# Usage:
#   ./deploy.sh [optional: path/to/custom.tfvars]
#
# Examples:
#   ./deploy.sh
#   ./deploy.sh terraform/custom.tfvars
# -------------------------------------------------------------------

set -e

# Default tfvars path
TFVARS_PATH="terraform/terraform.tfvars"
if [[ -n "$1" ]]; then
  TFVARS_PATH="$1"
fi

echo "🏗  Changing directory → terraform/"
cd terraform

# 1) terraform init
echo "🔄 terraform init …"
terraform init

# 2) terraform fmt (optional but recommended)
echo "🖌  terraform fmt …"
terraform fmt

# 3) terraform validate (sanity check)
echo "✔️  terraform validate …"
terraform validate

# 4) terraform plan
echo "📊 terraform plan using ${TFVARS_PATH} …"
terraform plan -var-file="${TFVARS_PATH}"

# 5) terraform apply
echo "⚙️  terraform apply (auto-approve) …"
terraform apply -auto-approve -var-file="${TFVARS_PATH}"

echo "🚀 Terraform deploy finished!"
