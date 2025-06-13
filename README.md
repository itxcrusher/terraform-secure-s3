# TerraformAWS
# Each subfolder must be imported into root module using the module syntax


# Issue
- Getting access denied 


# Note
1. Be sure to run terraform init
2. Run key-all.sh file in shell folder to generate keys needed by key-pair in cloudfront
3. Be sure to provider your path or crendential to provider file
4. I created a folder named Aws in this project that has a class with all the different method that I created and need to work with terraform configuration.


## How to run
- Navigate into the root terraform module and run these commands
1. Will setup the terraform providers. Whenever you add a new provider or change terraform backend you have to rerun this command
terraform init or 
terraform init -migrate-state (If you made changes and select yes to keep old state)
2. See what resources will be created after you run terrafrom apply
terraform plan
or 
terraform plan -var-file="dev.tfvars"
3. The resources that will be created and saved in state.tf file
terraform apply
4. Print all outputs
terraforn output
5. Delete all the resources that is management in tf state. Warning!!
terraform destory
6. Format terraform files for better readability
terraform fmt or terraform fmt -recursive
7. Cmd to validate if there's any invalid values
terraform validate