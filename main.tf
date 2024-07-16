terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "rblab-rg" {
  name     = "rblab-resources"
  location = "East US"

  tags = {
    environment = "dev"
  }
}


resource "azurerm_virtual_network" "rblab-vn" {
  name                = "rblab-network"
  resource_group_name = azurerm_resource_group.rblab-rg.name
  location            = azurerm_resource_group.rblab-rg.location

  address_space = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "rblab-subnet" {
  name                 = "rblab-subnet"
  resource_group_name  = azurerm_resource_group.rblab-rg.name
  virtual_network_name = azurerm_virtual_network.rblab-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "rblab-sg" {
  name                = "mtc-sg"
  location            = azurerm_resource_group.rblab-rg.location
  resource_group_name = azurerm_resource_group.rblab-rg.name


  tags = {
    environment = "dev"
  }


}

resource "azurerm_network_security_rule" "rblab-dev-rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rblab-rg.name
  network_security_group_name = azurerm_network_security_group.rblab-sg.name
}
resource "azurerm_subnet_network_security_group_association" "rblab-sga" {
  subnet_id                 = azurerm_subnet.rblab-subnet.id
  network_security_group_id = azurerm_network_security_group.rblab-sg.id
}
resource "azurerm_public_ip" "rblab-ip" {
  name                = "rblab-ip"
  resource_group_name = azurerm_resource_group.rblab-rg.name
  location            = azurerm_resource_group.rblab-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }


}

resource "azurerm_network_interface" "rblab-nic" {
  name                = "rblab-nic"
  location            = azurerm_resource_group.rblab-rg.location
  resource_group_name = azurerm_resource_group.rblab-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rblab-subnet.id
    public_ip_address_id          = azurerm_public_ip.rblab-ip.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }
}

