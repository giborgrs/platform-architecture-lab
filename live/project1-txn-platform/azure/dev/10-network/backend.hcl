# Replace with the outputs of bootstrap/azure.
resource_group_name  = "rg-terraform-state"
storage_account_name = "REPLACE_WITH_STATE_STORAGE_ACCOUNT"
container_name       = "tfstate"
key                  = "project1-txn-platform/azure/dev/10-network.tfstate"
use_azuread_auth     = true
