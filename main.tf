variable "subscription_id" {
  type = string
  default = "8d89b202-01a8-4471-b64e-0c8dea2928a0"
  description = "terraform subscription id"
}

variable "client_id" {
  type = string
  default = "23728360-a0e4-40fc-a9ce-c4b6e68fa8fe"
  description = "App registration client id"
}

variable "tenant_id" {
  type = string
  default = "5a361c56-cc3e-40f9-92ef-ff13dd1fca8b"
  description = "App registration tenant id"
}

variable "client_secret" {
  type = string
  default = "xQ28Q~_SccaD1edoEnKOBTLLkjAis2LjMepTtblx"
  description = "IAM client"
}

terraform{
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.43.0"
        }
    }
}

provider "azurerm" {
  features {
    
  }
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "tf101" {
  name = "tfrg101"
  location = "East US"
  tags = {
    "name" = "tf-rg-101"
  }
}

resource "azurerm_virtual_network" "vnet101" {
  name = "tfvnet101"
  location = azurerm_resource_group.tf101.location
  resource_group_name = azurerm_resource_group.tf101.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tflabelwebsubnet101" {
    name = "tfwebsubnet101"
    resource_group_name = azurerm_resource_group.tf101.name
    virtual_network_name = azurerm_virtual_network.vnet101.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "tflabelappsubnet101" {
    name = "tfappsubnet101"
    resource_group_name = azurerm_resource_group.tf101.name
    virtual_network_name = azurerm_virtual_network.vnet101.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "tflabeldbsubnet101" {
    name = "tfdbsubnet101"
    resource_group_name = azurerm_resource_group.tf101.name
    virtual_network_name = azurerm_virtual_network.vnet101.name
    address_prefixes = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "webserverip" {
  name = "tfwebpublicip"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  allocation_method = "Static"
  tags = {
    "name" = "webserverip"
  }
}

resource "azurerm_network_interface" "tflablenic" {
  name = "tfwebnic"
  location = azurerm_resource_group.tf101.location
  resource_group_name = azurerm_resource_group.tf101.name

  ip_configuration {
    name = "external"
    subnet_id = azurerm_subnet.tflabelwebsubnet101.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webserverip.id
  }
}

resource "azurerm_linux_virtual_machine" "tfvm" {
  name = "tfvm101"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  size = "Standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tflablenic.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "appserverip" {
  name = "tfapppublicip"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  allocation_method = "Static"
  tags = {
    "name" = "appserverip"
  }
}

resource "azurerm_network_interface" "tflablenicapp" {
  name = "tfappnic"
  location = azurerm_resource_group.tf101.location
  resource_group_name = azurerm_resource_group.tf101.name

  ip_configuration {
    name = "external"
    subnet_id = azurerm_subnet.tflabelappsubnet101.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appserverip.id
  }
}

resource "azurerm_linux_virtual_machine" "tfvmapp" {
  name = "tfvm102"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  size = "Standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tflablenicapp.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "dbserverip" {
  name = "tfdbpublicip"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  allocation_method = "Static"
  tags = {
    "name" = "dbserverip"
  }
}

resource "azurerm_network_interface" "tflablenicdb" {
  name = "tfdbnic"
  location = azurerm_resource_group.tf101.location
  resource_group_name = azurerm_resource_group.tf101.name

  ip_configuration {
    name = "external"
    subnet_id = azurerm_subnet.tflabeldbsubnet101.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.dbserverip.id
  }
}

resource "azurerm_linux_virtual_machine" "tfvmdb" {
  name = "tfvm103"
  resource_group_name = azurerm_resource_group.tf101.name
  location = azurerm_resource_group.tf101.location
  size = "Standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tflablenicdb.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version   = "latest"
  }
}