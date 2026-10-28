# Replace with the outputs of ../../bootstrap
resource_group_name  = "rg-terraform-state"
storage_account_name = "REPLACE_WITH_STATE_STORAGE_ACCOUNT"
container_name       = "tfstate"
key                  = "myapp/prod.tfstate"
use_azuread_auth     = true
