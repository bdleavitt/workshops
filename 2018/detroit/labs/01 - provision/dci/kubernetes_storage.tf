# Generate random text for a unique storage account name
resource "random_id" "kubeAzureStorageRandomID" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 8
}

# Create storage account for kubernetes
resource "azurerm_storage_account" "kube_storage" {
  name                     = "kube${random_id.kubeAzureStorageRandomID.hex}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    Name        = "${azurerm_resource_group.rg.name}-KubeStorage"
    Environment = "${azurerm_resource_group.rg.name}"
  }

  count = "${var.enable_kubernetes_azure_disk || var.enable_kubernetes_azure_file ? 1 : 0}"
}
