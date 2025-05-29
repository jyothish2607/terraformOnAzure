resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_virtual_network" "app_network" {
  name                = var.app_environment["production"].virtual_network_name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = [var.app_environment["production"].virtual_network_cidr_block]
}

resource "azurerm_subnet" "app_network_subnets" {
  for_each = var.app_environment["production"].subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = [each.value.cidr_block]
}

resource "azurerm_network_interface" "webinterfaces" {
  for_each = var.app_environment["production"].subnets["websubnet01"].machines
  name                = each.value.network_interface_name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["websubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webip[each.key].id
  }
}

resource "azurerm_network_interface" "appinterfaces" {
  for_each = var.app_environment["production"].subnets["appsubnet01"].machines
  name                = each.value.network_interface_name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["appsubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appip[each.key].id
  }
}

resource "azurerm_public_ip" "webip" {
  for_each = var.app_environment["production"].subnets["websubnet01"].machines
  name                = each.value.public_ip_address_name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  allocation_method   = "Static"
  
}

resource "azurerm_public_ip" "appip" {
  for_each = var.app_environment["production"].subnets["appsubnet01"].machines
  name                = each.value.public_ip_address_name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  allocation_method   = "Static"
  
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  dynamic security_rule {
    for_each = local.network_security_group_rules
    content {
    name                       = "Allow-${security_rule.value.destination_port_range}"
    priority                   = security_rule.value.priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = security_rule.value.destination_port_range
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  }

}

resource "azurerm_subnet_network_security_group_association" "subnet_app_nsg" {
  for_each                  = azurerm_subnet.app_network_subnets
  subnet_id                 = azurerm_subnet.app_network_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_windows_virtual_machine" "webvm" {
  for_each = var.app_environment["production"].subnets["websubnet01"].machines
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = var.app_environment["production"].virtual_machine_size
  admin_username      = "appadmin"
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.webinterfaces[each.key].id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_key_vault" "appvault20203874646" {
  name                = "appvault20203874646"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  sku_name            = "standard"
  tenant_id           = var.app_environment["production"].tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

}

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "mysecret"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.appvault20203874646.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform_sp_secret_permissions
  ]
}
  
  resource "azurerm_key_vault_access_policy" "terraform_sp_secret_permissions" {
  key_vault_id = azurerm_key_vault.appvault20203874646.id

  tenant_id = "bf6319b5-74f6-4a8a-9fd3-5dc84223e990"
  object_id = "02b0ce5f-7f73-405e-8891-fe90b898f383" # Service principal object ID

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Purge",
    "Recover",
  ]
}

data "local_file" "cloudinit" {
  filename = "cloudinit"
}

resource "azurerm_linux_virtual_machine" "appvm" {
  for_each = var.app_environment["production"].subnets["appsubnet01"].machines
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  disable_password_authentication = false
  custom_data = data.local_file.cloudinit.content_base64
  network_interface_ids = [
    azurerm_network_interface.appinterfaces[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}