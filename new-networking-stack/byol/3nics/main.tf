###############################################################################
##                                                                           ##
## Variable Definition Section                                               ##
##                                                                           ##
###############################################################################

variable "enable_DO_Rest_Call" {
  description = "Use 0 to disable the final DO Rest API Call to provision BIG-IP; 1 to ebnable it"
}

variable "enable_jumphost_creation" {
  description = "Use 0 to disable Jumphost VM creation; 1 to ebnable it"
}

variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "owner_name" {
  description = "The name of the owner of objects in this Resource Group"
}

variable "vnet_address_space" {
  description = "The Address Space for the Azure Virtual Network"
}

variable "vnet_external_subnet_address_prefix" {
  description = "The Address Space for the External Subnet"
}

variable "vnet_internal_subnet_address_prefix" {
  description = "The Address Space for the Internal Subnet"
}

variable "vnet_mgmt_subnet_address_prefix" {
  description = "The Address Space for the Management Subnet"
}

variable "jumphost_mgmt_ip" {
  description = "The Management IP Address for the Linux Jumphost"
}

variable "bigip01_mgmt_ip" {
  description = "The Management IP Address for bigip01 Mgmt IP"
}

variable "bigip01_internal_selfip" {
  description = "The bigip01 SelfIP on internal network"
}

variable "bigip01_external_selfip" {
  description = "The bigip01 SelfIP on external network"
}

variable "ssh_id_rsa_pub_key" {
  description = "The id_rsa file containing the public key"
}

variable "bigip_instance_type" {
  description = "The type of VM used to run BIG-IP VE  "
}

variable bigip_image_name {
  description = ""
}

variable bigip_product {
  description = ""
}

variable bigip_version {
  description = ""
}

variable "do_rpm_file" {
  description = "Name of the last RPM for Declarative Onboarding (See: github.com/f5networks)"
}

variable "as3_rpm_file" {
  description = "Name of the last RPM for Application Service 3 (See: github.com/f5networks)"
}

variable "f5_username" {
  description = "Admin username on bigip"
}

variable "f5_password" {
  description = "passowrd for admin username on bigip"
}

variable "f5_new_password" {
  description = "passowrd for admin username on bigip"
}

variable "bigip01_do_file" {
  description = "Filename for the file containing DO declaration for bigip01 onboarding"
}

## ..:: Loading files ::..
data "local_file" "ssh_key" {
  filename = "${var.ssh_id_rsa_pub_key}"
}

###############################################################################
##                                                                           ##
## Resource Group Creation                                                   ##
##                                                                           ##
###############################################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"

  tags {
    owner = "${var.owner_name}"
  }
}

###############################################################################
##
## Create Virtual Networks with Subnets
##
###############################################################################

resource "azurerm_virtual_network" "vnet" {
  
  name                = "${var.prefix}-vnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["${var.vnet_address_space}"]

  tags {
    owner = "${var.owner_name}"
  }
}

resource "azurerm_subnet" "external" {

  name                 = "${var.prefix}-external-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.vnet_external_subnet_address_prefix}"
}

resource "azurerm_subnet" "internal" {

  name                 = "${var.prefix}-internal-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.vnet_internal_subnet_address_prefix}"
}

resource "azurerm_subnet" "mgmt" {

  name                 = "${var.prefix}-mgmt-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.vnet_mgmt_subnet_address_prefix}"
}

###############################################################################
##
## Create Jumphost Virtual Machine
##
###############################################################################

## Create a Public IP
resource "azurerm_public_ip" "jumphost-pubic-ip" {

  count = "${var.enable_jumphost_creation}"

  name                = "${var.prefix}-jumphost-publicip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"

  tags {
    owner = "${var.owner_name}"
  }
}

## Create a Security Group
resource "azurerm_network_security_group" "jumphost-sg" {

  count = "${var.enable_jumphost_creation}"

  name                = "${var.prefix}-jumphost-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "permit-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

resource "azurerm_network_interface" "jumphost-mgmt-vnic" {

  count = "${var.enable_jumphost_creation}"

  name                      = "${var.prefix}-jumphost-mgmt-vnic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.jumphost-sg.id}"

  ip_configuration {
    name                          = "${var.prefix}-jumphost-mgmt-ip"
    subnet_id                     = "${azurerm_subnet.mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.jumphost_mgmt_ip}"
    public_ip_address_id          = "${azurerm_public_ip.jumphost-pubic-ip.id}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

resource "azurerm_virtual_machine" "jumphost-vm" {

  count = "${var.enable_jumphost_creation}"

  name                  = "${var.prefix}-jumphost-vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jumphost-mgmt-vnic.id}"]
  vm_size               = "Standard_DS2_v2"

  storage_os_disk {
    name              = "${var.prefix}-jumphost-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "jumphost"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${data.local_file.ssh_key.content}"
    }
  }

  tags {
    owner = "${var.owner_name}"
  }
}

###############################################################################
##                                                                           ##
## BIG-IP Virtual Machine Creation                                           ##
##                                                                           ##
###############################################################################

## ..:: Setup Onboarding scripts ::..
data "template_file" "install_DO_AS3" {
  template = "${file("${path.module}/install_DO_AS3.tpl")}"

  vars {
    f5_username  = "${var.f5_username}"
    f5_password  = "${var.f5_password}"
    do_rpm_file  = "${var.do_rpm_file}"
    as3_rpm_file = "${var.as3_rpm_file}"
  }
}

## ..:: Create a Public IP for BIG-IP Mgmt NIC ::..
resource "azurerm_public_ip" "bigip01_mgmt_public_ip" {
  name                = "${var.prefix}-bigip01-mgmt-publicip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create a Security Group ::..
resource "azurerm_network_security_group" "bigip01-mgmt-sg" {
  name                = "${var.prefix}-bigip01-mgmt-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "permit-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "permit-https"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create the mgmt Network Interface ::..
resource "azurerm_network_interface" "bigip01-mgmt-vnic" {
  name                      = "${var.prefix}-bigip01-mgmt-vnic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.bigip01-mgmt-sg.id}"

  ip_configuration {
    name                          = "${var.prefix}-bigip01-mgmt-ip"
    subnet_id                     = "${azurerm_subnet.mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.bigip01_mgmt_ip}"
    public_ip_address_id          = "${azurerm_public_ip.bigip01_mgmt_public_ip.id}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create the Internal Network Interface ::..
resource "azurerm_network_interface" "bigip01-internal-vnic" {
  name                = "${var.prefix}-bigip01-internal-vnic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.prefix}-bigip01-internal-ip"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.bigip01_internal_selfip}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create the External Network Interface ::..
resource "azurerm_network_interface" "bigip01-external-vnic" {
  name                = "${var.prefix}-bigip01-external-vnic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.prefix}-bigip01-external-ip"
    subnet_id                     = "${azurerm_subnet.external.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.bigip01_external_selfip}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## =============================
## ..:: Create F5 BIGIP VMs ::..
## =============================
resource "azurerm_virtual_machine" "f5vm01" {
  name                         = "${var.prefix}-bigip01-vm"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  primary_network_interface_id = "${azurerm_network_interface.bigip01-mgmt-vnic.id}"
  network_interface_ids        = ["${azurerm_network_interface.bigip01-mgmt-vnic.id}", "${azurerm_network_interface.bigip01-internal-vnic.id}", "${azurerm_network_interface.bigip01-external-vnic.id}"]
  vm_size                      = "${var.bigip_instance_type}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = "${var.bigip_product}"
    sku       = "${var.bigip_image_name}"
    version   = "${var.bigip_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}-bigip01-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "bigip01"
    admin_username = "${var.f5_username}"
    admin_password = "${var.f5_password}"
    custom_data    = "${data.template_file.install_DO_AS3.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    #    ssh_keys {
    #      path     = "/home/f5admin/.ssh/authorized_keys"
    #      key_data = "${data.local_file.ssh_key.content}"
    #    }
  }

  plan {
    name      = "${var.bigip_image_name}"
    publisher = "f5-networks"
    product   = "${var.bigip_product}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Run Startup Script ::..
resource "azurerm_virtual_machine_extension" "f5vm01-run-startup-cmd" {
  name                 = "${var.prefix}-f5vm01-run-startup-cmd"
  depends_on           = ["azurerm_virtual_machine.f5vm01"]
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.f5vm01.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  # publisher            = "Microsoft.Azure.Extensions"
  # type                 = "CustomScript"
  # type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData"
    }
  SETTINGS
  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Getting BIG-IP VM Mgmt Public IP ::..
data "azurerm_public_ip" "bigip01_assigned_mgmt_public_ip" {
  depends_on          = ["azurerm_virtual_machine.f5vm01"]
  name                = "${azurerm_public_ip.bigip01_mgmt_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

## ..:: Getting Jumphost VM Mgmt Public IP ::..
data "azurerm_public_ip" "jumphost_assigned_mgmt_public_ip" {

  count = "${var.enable_jumphost_creation}"

  depends_on          = ["azurerm_virtual_machine.jumphost-vm"]
  name                = "${azurerm_public_ip.jumphost-pubic-ip.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

## ..:: Running DO REST API on bigip01 ::..
resource "null_resource" "f5vm01-run-DO" {
  
  count = "${var.enable_DO_Rest_Call}"
  
  depends_on = ["azurerm_virtual_machine_extension.f5vm01-run-startup-cmd"]

  provisioner "local-exec" {
    command = <<-EOF
      #!/bin/bash
      curl -k -X GET https://${data.azurerm_public_ip.bigip01_assigned_mgmt_public_ip.ip_address}/mgmt/shared/declarative-onboarding \
              -u ${var.f5_username}:${var.f5_password}

      curl -k -X POST https://${data.azurerm_public_ip.bigip01_assigned_mgmt_public_ip.ip_address}/mgmt/shared/declarative-onboarding \
              -u ${var.f5_username}:${var.f5_password} \
              -d @${var.bigip01_do_file}
      sleep 60
      curl -k -X POST https://${data.azurerm_public_ip.bigip01_assigned_mgmt_public_ip.ip_address}/mgmt/shared/declarative-onboarding \
              -u ${var.f5_username}:${var.f5_new_password} \
              -d @${var.bigip01_do_file}
    EOF
  }
}

output "bigip01_mgmt_public_ip_address" {
  value = "${data.azurerm_public_ip.bigip01_assigned_mgmt_public_ip.ip_address}"
}

output "jumphost_mgmt_public_ip_address" {
  value = "${element(concat(data.azurerm_public_ip.jumphost_assigned_mgmt_public_ip.*.ip_address, list("")), 0)}"
}