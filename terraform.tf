terraform {
  required_providers {
      azurerm =  {
          source = "hashicorp/azurerm"
          version = ">=2.26"
      }
  } 
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
resource "azurerm_resource_group" "ramrg1" {
  name = "ramtf"
  location = "eastus"
}
resource "azurerm_storage_account" "stg1" {
  name                = "ramstgtf"
  resource_group_name  = azurerm_resource_group.ramrg1.name
  location             = azurerm_resource_group.ramrg1.location
  account_tier         =  "Standard"
  account_replication_type="GRS"
tags={
  environment = "development"
}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ramtfvn"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "ramtf"
}


resource "azurerm_subnet" "subnet" {
  name                          = "ramsvn"
  resource_group_name           = "ramtf"
  virtual_network_name          = azurerm_virtual_network.vnet.name
  address_prefixes              = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.ramrg1.location
  resource_group_name = azurerm_resource_group.ramrg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "ram01"
  resource_group_name = azurerm_resource_group.ramrg1.name
  location            = azurerm_resource_group.ramrg1.location
  size                = "Standard_DS1_v2"
  admin_username      = "[Ram@123]"
  admin_password      = "[Ram@123456789]"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
