# ..::General Variables ::..
prefix                  = "pa-tf-test"
location                = "westeurope"
owner_name              = "paoloa"
#ssh_id_rsa_pub_key     = "/home/ubuntu/.ssh/id_rsa.pub"
ssh_id_rsa_pub_key     = "/Users/arcagni/.ssh/id_rsa.pub"

# ..:: Azure Provider Variables ::..
#subscription_id = "PUT HERE YOUR SUBSCRIPTION ID"
#client_id       = "PUT HERE YOUR CLIENT ID"
#client_secret   = "PUT HERE YOUR CLIENT SECRET"
#tenant_id       = "PUT HERE YOUR TENANT ID"

# ..:: Azure Provider Variables ::..
subscription_id = "1005fe30-e19e-4091-8480-8b61ecb8106e"
client_id       = "f68d6c87-f191-4eaf-8ac2-e6019dfc4d5c"
client_secret   = "f093019c-5a04-4d10-bd16-99f62a61e9e1"
tenant_id       = "e569f29e-b098-4cea-b6f0-48fa8532d64a"

# ..:: Azure VNET Variables ::..
subnet1_name    = "mgmt"
subnet2_name    = "external"
subnet3_name    = "internal"

# ..:: BIG-IP 01 Variables ::..
bigip_hostname              = "bigip-ns"
bigip_mgmt_ip               = "10.70.1.10"
bigip_internal_selfip       = "10.70.20.10"
bigip_external_selfip       = "10.70.10.10"
bigip_instance_type         = "Standard_DS4_v2"
bigip_image_name            = "f5-big-all-2slot-byol"
bigip_product               = "f5-big-ip-byol"
bigip_version               = "latest"
do_rpm_file                 = "f5-declarative-onboarding-1.3.0-4.noarch.rpm"
as3_rpm_file                = "f5-appsvcs-3.10.0-5.noarch.rpm"
f5_username                 = "f5admin"
f5_password                 = "Default1234!"
f5_new_password             = "v6MkmqddvaRU5"

