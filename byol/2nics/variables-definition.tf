## ============================================================================
## ..:: Azure Provider Subscription Variables ::..
## ============================================================================

variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "client_id" {
  description = "Azure Principal Name App ID"
}

variable "client_secret" {
  description = "Azure Principal Name Password"
}

variable "tenant_id" {
  description = "Azure Principal Name Tenant ID"
}

## ============================================================================
## ..:: General RG and VNET Environment's Variables ::..
## ============================================================================

variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "owner_name" {
  description = "The name of the owner of objects in this Resource Group"
}

variable "subnet1_name" {
  description = "The name (with no prefix) of the existing Subnet1 subnet"
}

variable "subnet2_name" {
  description = "The name (with no prefix) of the existing Subnet2 subnet"
}

## ============================================================================
## ..:: BIG-IP Variable ::..
## ============================================================================

variable "ssh_id_rsa_pub_key" {
  description = "The id_rsa file containing the public key"
}
variable "bigip_hostname" {
  description = "The hostname for this BIG-IP"
}
variable "bigip_mgmt_ip" {
  description = "Management IP Address for this BIG-IP"
}
variable "bigip_data_selfip" {
  description = ""
}
variable "bigip_instance_type" {
  description = ""
}
variable "bigip_image_name" {
  description = ""
}
variable "bigip_product" {
  description = ""
}
variable "bigip_version" {
  description = ""
}

variable "do_rpm_file" {
  description = ""
}

variable "as3_rpm_file" {
  description = ""
}

variable "f5_username" {
  description = ""
}

variable "f5_password" {
  description = ""
}

variable "f5_new_password" {
  description = ""
}
