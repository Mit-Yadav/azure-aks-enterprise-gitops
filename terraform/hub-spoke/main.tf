terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }
}

# Hub Network Resource Group
resource "azurerm_resource_group" "hub_rg" {
  name     = "rg-enterprise-hub-prod"
  location = var.azure_region
  tags     = var.tags
}

# Hub Virtual Network
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-hub-core"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Azure Firewall Subnet
resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Spoke Network Resource Group (AKS Workloads)
resource "azurerm_resource_group" "spoke_rg" {
  name     = "rg-enterprise-spoke-aks-prod"
  location = var.azure_region
  tags     = var.tags
}

# Spoke Virtual Network
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "vnet-spoke-aks"
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  address_space       = ["10.1.0.0/16"]
  tags                = var.tags
}

# AKS System Node Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.0.0/20"]
}

# Bidirectional VNet Peering: Hub <-> Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
