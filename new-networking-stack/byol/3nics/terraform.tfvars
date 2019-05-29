# ..::General Variables ::..
prefix                  = "paoloa-terraform-test"
location                = "westeurope"
owner_name              = "paoloa"
ssh_id_rsa_pub_key     = "/home/ubuntu/.ssh/id_rsa.pub"

# ..:: Azure Provider Variables ::..
#subscription_id = "PUT HERE YOUR SUBSCRIPTION ID"
#client_id       = "PUT HERE YOUR CLIENT ID"
#client_secret   = "PUT HERE YOUR CLIENT SECRET"
#tenant_id       = "PUT HERE YOUR TENANT ID"

# ..:: Azure VNET Variables ::..
vnet_address_space                      = "10.6.0.0/16"
vnet_external_subnet_address_prefix     = "10.6.10.0/24"
vnet_internal_subnet_address_prefix     = "10.6.20.0/22"
vnet_mgmt_subnet_address_prefix         = "10.6.1.0/24"

# ..::  Linux Jumphost Variables ::..
jumphost_mgmt_ip    = "10.6.1.20"

# ..:: BIG-IP 01 Variables ::..
bigip01_mgmt_ip             = "10.6.1.10"
bigip01_internal_selfip     = "10.6.20.10"
bigip01_external_selfip     = "10.6.10.10"
bigip_instance_type         = "Standard_DS4_v2"
bigip_image_name            = "f5-big-all-2slot-byol"
bigip_product               = "f5-big-ip-byol"
bigip_version               = "latest"
do_rpm_file                 = "f5-declarative-onboarding-1.4.1-1.noarch.rpm"
as3_rpm_file                = "f5-appsvcs-3.11.0-3.noarch.rpm"
f5_username                 = "f5admin"
f5_password                 = "Default1234!"
f5_new_password             = "abcdefghilmn"
bigip01_do_file             = "bigip01_DO.json"

# ..:: Terraform Flow Control ::..
enable_DO_Rest_Call         = 0
enable_jumphost_creation    = 0
