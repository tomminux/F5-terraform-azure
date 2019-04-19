# BIG-IP VE - 2 NICS in Existing Networking Stack - BYOL
This Terraform script will provision a 2 NIC BIG-IP in an existing VNET with at least three subnets in Microsoft Azure.

## Obejects created
- A BIG-IP VE connected to the 3 subnets. This BIG-IP will be reachable on the internet with a public dynamic IP address open to the world on port 22 and 443

## Usage

All confniguration parameters are in the terraform.tfvars file, please update the file before running the script

How to run it

```
terraform init
terraform plan
terraform apply
```


