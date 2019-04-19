###############################################################################
##                                                                           ##
## ..:: Variable Definition Section ::..                                     ##
##                                                                           ##
###############################################################################

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

###############################################################################
##                                                                           ##
## ..:: Configure the Microsoft Azure Provider ::..                          ##
##                                                                           ##
###############################################################################

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}
