# Terraform Secure S3

This repository provisions a locked-down S3 bucket that only serves objects via CloudFront signed URLs. It includes an IAM “presigner” user whose policy can be attached/detached easily.

## Directory Layout

.
├── README.md
├── deploy.sh
├── generate\_keypair.sh
└── terraform
    ├── cloudfront.tf
    ├── iam\_presigner.tf
    ├── keys/
    ├── outputs.tf
    ├── providers.tf
    ├── s3\_bucket.tf
    ├── terraform.tfvars
    └── variables.tf

* **generate\_keypair.sh**: Creates an RSA key-pair for CloudFront (private/public).
* **deploy.sh**: Runs Terraform (`init` → `plan` → `apply`).
* **terraform/**: All Terraform code.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed locally (version 1.0 or higher).
2. AWS CLI configured with credentials that have permissions to manage S3, CloudFront, and IAM.
3. OpenSSL installed (for key-pair generation).

## Usage

1. **Clone & enter repo**
   `git clone <repo-url> terraform-secure-s3`
   `cd terraform-secure-s3`

2. **Generate CloudFront key-pair**
   `./generate_keypair.sh`

   * This will produce:

     * `terraform/keys/private_key.pem`
     * `terraform/keys/public_key.pem`
   * **Do not commit** `private_key.pem` (it’s in `.gitignore`).

3. **Populate `terraform/terraform.tfvars`**
   bucket\_name         = "your-unique-bucket-name"
   public\_key\_path     = "keys/public\_key.pem"
   public\_key\_name     = "myapp-cf-public-key"
   presigner\_user\_name = "presigner"
   allowed\_ip\_cidr     = ""           (optional)
   region              = "us-east-1"  (override if needed)

4. **Deploy Terraform**
   `./deploy.sh`

   * This runs `terraform init`, `terraform plan`, and `terraform apply -auto-approve`.
   * Outputs will display:

     * S3 bucket name
     * CloudFront domain
     * Key Group ID
     * Presigner user’s access key ID (secret access key is in state)

5. **Test**

   * Upload an object to the bucket.
   * Generate a CloudFront-signed URL (use `private_key.pem` + Key Group ID).
   * Visit the signed URL: you should see the object.
   * Direct S3 access (without a signed URL) should be denied.

---

### Notes

* **Key Management**: Terraform only uses `public_key.pem`. Keep `private_key.pem` secure and never commit it.
* **IAM Policy Tweaks**: By default, the presigner policy allows only `s3:GetObject`. To add `s3:ListBucket`, edit the policy in `iam_presigner.tf` and re-apply Terraform.
* **Custom Domains/SSL**: We use the default CloudFront certificate (`*.cloudfront.net`). To use a custom domain, replace the viewer certificate block in `cloudfront.tf` with your ACM certificate ARN.
* **Multiple Environments**: Copy the `terraform/` folder into separate environment folders (e.g., `dev/`, `prod/`) and override variable values. Keep scripts and keys in a shared location or adjust paths accordingly.