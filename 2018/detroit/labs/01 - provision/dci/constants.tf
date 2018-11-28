# ---------------------------------------------------------------------------------------------------------------------
# PRE-DEFINED CONSTANTS
# ---------------------------------------------------------------------------------------------------------------------

variable "docker_version" {
  description = "The Docker version deployed"
  default     = "17.11.0-ce"
}

## Manager details
variable "linux_manager" {
  type = "map"

  default = {
    publisher = "Canonical"    # OS VHD publisher
    offer     = "UbuntuServer" # OS VHD offer
    sku       = "16.04-LTS"    # OS VHD SKU
    version   = "latest"       # OS VHD version
  }
}

## Linux worker details
variable "linux_worker" {
  type = "map"

  default = {
    publisher = "Canonical"    # OS VHD publisher
    offer     = "UbuntuServer" # OS VHD offer
    sku       = "16.04-LTS"    # OS VHD SKU
    version   = "latest"       # OS VHD version
  }
}

## Windows worker details
variable "windows_worker" {
  type = "map"

  default = {
    publisher = "MicrosoftWindowsServer" # OS VHD publisher
    offer     = "WindowsServer"          # OS VHD offer
    sku       = "2016-DataCenter"        # OS VHD SKU
    version   = "latest"                 # OS VHD version
  }
}
