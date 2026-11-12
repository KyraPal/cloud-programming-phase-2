Cloud Programming – Phase 2

This project hosts a simple “Hello world!” page on AWS. A Lambda function returns the HTML page, and CloudFront delivers and caches it. Terraform creates the AWS resources.

Project files
- main.tf defines the AWS resources.
- lambda/handler.py returns the HTML page.
- lambda/index.html contains the page content.

Deploy the website
You need Terraform installed and AWS credentials configured. Run these commands from the project folder:

```sh
terraform init
terraform validate
terraform plan
terraform apply
terraform output -raw website_url
```
