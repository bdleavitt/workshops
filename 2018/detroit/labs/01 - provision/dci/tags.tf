resource "random_string" "dci_id" {
  length  = 8
  special = false
  upper   = false
}

variable "dci_commit" {
  description = "Represents the commit from which this stack originated"
  default     = "ffffffffffffffffffffffffffffffff"
}

locals {
  dci_id = "dci-${random_string.dci_id.result}"

  dci_tags = "${map(
    "DCI_COMMIT", "sha1:${var.dci_commit}",
    "DCI_CREATED", "${timestamp()}",
    "DCI_DEPLOYMENT", "${var.deployment}",
    "DCI_ID", "${local.dci_id}"
  )}"
}
