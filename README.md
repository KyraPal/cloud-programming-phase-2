# Cloud Programming – Phase 2

This project hosts a simple “Hello world!” page on AWS. A Lambda function returns the HTML page, and CloudFront delivers and caches it. Terraform creates the AWS resources.

## Project files
- main.tf defines the AWS resources.
- lambda/handler.py returns the HTML page.
- lambda/index.html contains the page content.

## Deploy the website
The Lambda function runs in Europe (Stockholm), `eu-north-1`. This region is set in `main.tf`.
You need Terraform installed and AWS credentials configured. Run these commands from the project folder:

```sh
terraform init
terraform validate
terraform plan
terraform apply
terraform output -raw website_url
```

## Clean up

When you no longer need the website, run this command from the same project folder using the Terraform state from the deployment.

```sh
terraform destroy
```

Review the resources Terraform plans to remove, then type `yes` to confirm.
