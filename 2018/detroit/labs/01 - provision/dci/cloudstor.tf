# Generate random text for a unique storage account name
resource "random_id" "cloudstorId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 6
}

# Create storage account for Cloudstor
resource "azurerm_storage_account" "cloudstor_storage" {
  name                     = "cloudstor${random_id.cloudstorId.hex}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    Name        = "${azurerm_resource_group.rg.name}-Cloudstor"
    Environment = "${azurerm_resource_group.rg.name}"
  }
}
