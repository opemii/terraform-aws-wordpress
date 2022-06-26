# terraform-aws-wordpress
## this project provisions highly available infrastructure for WordPress using terraform


Prequisites

1. AWS account
2. IAM User with Admin priviledges
3. AWS CLI and Terraform installed

AWS Resoureces created

1. Relational Database Service RDS
2. Elastic File System EFS
3. Elastic Load Balancing ElB
4. Cloud Watch
6. Autoscaling group
7. Launch COnfiguration
8. VPC, Security Groups, Internet Gateway and Route Table



How to
1. clone this repository
2. switch to project directory
3. run the following commands
terraform init
terraform apply --auto-approve

to destroy infrastructure : run - terraform destroy 
