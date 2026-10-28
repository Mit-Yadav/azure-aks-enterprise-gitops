resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-enterprise-prod"
  location            = var.azure_region
  resource_group_name = "rg-enterprise-spoke-aks-prod"
  dns_prefix          = "aks-enterprise-prod"
  kubernetes_version  = "1.30.0"

  default_node_pool {
    name                = "systempool"
    node_count          = 3
    vm_size             = "Standard_D4s_v5"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    vnet_subnet_id      = var.aks_subnet_id
    os_disk_size_gb     = 128
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}
