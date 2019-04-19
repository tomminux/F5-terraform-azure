## ============================================================================
## ..:: Loading files ::..
## ============================================================================
data "local_file" "ssh_key" {
  filename = "${var.ssh_id_rsa_pub_key}"
}

## ============================================================================
## ..:: Loading Network and Su bnets ::..
## ============================================================================
data "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-${var.subnet1_name}-subnet"
  resource_group_name  = "${var.prefix}-rg"
  virtual_network_name = "${var.prefix}-vnet"
}

data "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-${var.subnet2_name}-subnet"
  resource_group_name  = "${var.prefix}-rg"
  virtual_network_name = "${var.prefix}-vnet"
}

data "azurerm_subnet" "subnet3" {
  name                 = "${var.prefix}-${var.subnet3_name}-subnet"
  resource_group_name  = "${var.prefix}-rg"
  virtual_network_name = "${var.prefix}-vnet"
}

## ============================================================================
## ..:: BIG-IP Virtual Machine Creation ::..
## ============================================================================

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
resource "azurerm_public_ip" "bigip_mgmt_public_ip" {
  name                = "${var.prefix}-${var.bigip_hostname}-mgmt-public-ip"
  location            = "${var.location}"
  resource_group_name = "${var.prefix}-rg"
  allocation_method   = "Dynamic"

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create a Security Group ::..
resource "azurerm_network_security_group" "bigip_mgmt_sg" {
  name                = "${var.prefix}-${var.bigip_hostname}-mgmt-sg"
  location            = "${var.location}"
  resource_group_name = "${var.prefix}-rg"

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
resource "azurerm_network_interface" "bigip_mgmt_vnic" {
  name                      = "${var.prefix}-${var.bigip_hostname}-mgmt-vnic"
  location                  = "${var.location}"
  resource_group_name       = "${var.prefix}-rg"
  network_security_group_id = "${azurerm_network_security_group.bigip_mgmt_sg.id}"

  ip_configuration {
    name                          = "${var.prefix}-${var.bigip_hostname}-mgmt-ip"
    subnet_id                     = "${data.azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.bigip_mgmt_ip}"
    public_ip_address_id          = "${azurerm_public_ip.bigip_mgmt_public_ip.id}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## ..:: Create the External Network Interface ::..
resource "azurerm_network_interface" "bigip_data_vnic" {
  name                = "${var.prefix}-${var.bigip_hostname}-data-vnic"
  location            = "${var.location}"
  resource_group_name = "${var.prefix}-rg"

  ip_configuration {
    name                          = "${var.prefix}-${var.bigip_hostname}-data-ip"
    subnet_id                     = "${data.azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.bigip_data_selfip}"
  }

  tags {
    owner = "${var.owner_name}"
  }
}

## =============================
## ..:: Create F5 BIGIP VMs ::..
## =============================
resource "azurerm_virtual_machine" "f5bigipvm" {
  name                         = "${var.prefix}-${var.bigip_hostname}-vm"
  location                     = "${var.location}"
  resource_group_name          = "${var.prefix}-rg"
  primary_network_interface_id = "${azurerm_network_interface.bigip_mgmt_vnic.id}"
  network_interface_ids        = ["${azurerm_network_interface.bigip_mgmt_vnic.id}", "${azurerm_network_interface.bigip_data_vnic.id}"]
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
    name              = "${var.prefix}-${var.bigip_hostname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.bigip_hostname}"
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
resource "azurerm_virtual_machine_extension" "f5bigipvm_run_startup_cmd" {
  name                 = "${var.prefix}-${var.bigip_hostname}-run-startup-cmd"
  depends_on           = ["azurerm_virtual_machine.f5bigipvm"]
  location             = "${var.location}"
  resource_group_name  = "${var.prefix}-rg"
  virtual_machine_name = "${azurerm_virtual_machine.f5bigipvm.name}"
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
data "azurerm_public_ip" "f5bigipvm_assigned_mgmt_public_ip" {
  depends_on          = ["azurerm_virtual_machine.f5bigipvm"]
  name                = "${azurerm_public_ip.bigip_mgmt_public_ip.name}"
  resource_group_name = "${var.prefix}-rg"
}

output "f5bigipvm_mgmt_public_ip_address" {
  value = "${data.azurerm_public_ip.f5bigipvm_assigned_mgmt_public_ip.ip_address}"
}
