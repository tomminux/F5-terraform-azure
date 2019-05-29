# ..::General Variables ::..
prefix                  = "pa-tf-test"
location                = "westeurope"
owner_name              = "paoloa"
ssh_id_rsa_pub_key     = "/home/ubuntu/.ssh/id_rsa.pub"

# ..:: Azure Provider Variables ::..
#subscription_id = "PUT HERE YOUR SUBSCRIPTION ID"
#client_id       = "PUT HERE YOUR CLIENT ID"
#client_secret   = "PUT HERE YOUR CLIENT SECRET"
#tenant_id       = "PUT HERE YOUR TENANT ID"

# ..:: Azure VNET Variables ::..
subnet1_name    = "mgmt"
subnet2_name    = "data"

# ..:: BIG-IP 01 Variables ::..
bigip_hostname              = "bigip-ns"
bigip_mgmt_ip               = "10.70.1.10"
bigip_data_selfip           = "10.70.10.10"
bigip_instance_type         = "Standard_DS4_v2"
bigip_image_name            = "f5-big-all-2slot-byol"
bigip_product               = "f5-big-ip-byol"
bigip_version               = "latest"
do_rpm_file                 = "f5-declarative-onboarding-1.4.1-1.noarch.rpm"
as3_rpm_file                = "f5-appsvcs-3.11.0-3.noarch.rpm"
f5_username                 = "f5admin"
f5_password                 = "Default1234!"
f5_new_password             = "abcdefghilnm"

