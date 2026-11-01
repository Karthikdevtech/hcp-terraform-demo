terraform {
  cloud {
    organization = "karthikdevopstech" # Replace with your HCP organization name

    workspaces {
      name = "hcp-terraform-demo"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Or your preferred version >= 1.5.0
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example Azure Resource Group to test your deployment
resource "azurerm_resource_group" "rg" {
  name     = "rg-hcp-terraform-dev"
  location = "East US" # Change to your preferred Azure region
}

resource "random_pet" "server" {
  length = 2
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the VM administrator."
  type        = string
}

variable "admin_ssh_cidr" {
  description = "IPv4 CIDR range allowed to connect to the VM over SSH."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_ssh_cidr))
    error_message = "admin_ssh_cidr must be a valid IPv4 CIDR range."
  }
}

resource "azurerm_virtual_network" "vm" {
  name                = "vnet-hcp-terraform-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-${random_pet.server.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-${random_pet.server.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${random_pet.server.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F1als_v7"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the created Azure Resource Group"
}

output "vm_public_ip_address" {
  value       = azurerm_public_ip.vm.ip_address
  description = "Public IP address of the virtual machine"
}

output "vm_ssh_command" {
  value       = "ssh azureuser@${azurerm_public_ip.vm.ip_address}"
  description = "SSH command to connect to the virtual machine"
}