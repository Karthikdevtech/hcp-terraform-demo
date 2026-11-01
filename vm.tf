# 1. Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 2. Create a Subnet inside the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-dev"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 3. Create a Network Interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "nic-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 4. Create the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "linux-vm-dev"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_F1als_v7" # Economical size for testing
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false # Allows password login instead of SSH keys only

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}