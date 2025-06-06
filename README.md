# terraform-secure-s3

This repository provisions a locked-down S3 bucket that only serves objects via CloudFront signed URLs. It includes an IAM “presigner” user whose policy can be attached/detached easily.

## Directory Layout

.
├── README.md
├── deploy.sh
├── generate_keypair.sh
└── terraform
├── cloudfront.tf
├── iam_presigner.tf
├── keys/
├── outputs.tf
├── providers.tf
├── s3_bucket.tf
├── terraform.tfvars
└── variables.tf

ruby
Copy
Edit

- **generate_keypair.sh**: Creates an RSA key-pair for CloudFront (private/public).  
- **deploy.sh**: Runs Terraform (`init` → `plan` → `apply`).  
- **terraform/**: All Terraform code.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed locally (v1.0+).
2. AWS CLI configured with credentials that have permissions to manage S3, CloudFront, and IAM.
3. OpenSSL installed (for key‐pair generation).

## Usage

1. **Clone & enter repo**  
   ```bash
   git clone <repo-url> terraform-secure-s3
   cd terraform-secure-s3
Generate CloudFront key-pair

bash
Copy
Edit
./generate_keypair.sh
This will produce:

terraform/keys/private_key.pem

terraform/keys/public_key.pem

Do not commit private_key.pem (it’s in .gitignore).

Populate terraform/terraform.tfvars

ini
Copy
Edit
bucket_name         = "your-unique-bucket-name"
public_key_path     = "keys/public_key.pem"
public_key_name     = "myapp-cf-public-key"
presigner_user_name = "presigner"
allowed_ip_cidr     = ""          # optional
region              = "us-east-1" # override if needed
Deploy Terraform

bash
Copy
Edit
./deploy.sh
This runs terraform init, terraform plan, and terraform apply -auto-approve.

Outputs will display:

S3 bucket name

CloudFront domain

Key Group ID

Presigner user’s access key ID (secret access key is in state)

Test

Upload an object to the bucket.

Generate a CloudFront-signed URL (use private_key.pem + Key Group ID).

Visit the signed URL: you should see the object.

Direct S3 access (without a signed URL) should be denied.

