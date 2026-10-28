# Replace the bucket with the output of bootstrap/aws.
bucket       = "REPLACE_WITH_STATE_BUCKET"
key          = "project1-txn-platform/aws/dev/10-network.tfstate"
region       = "us-east-1"
use_lockfile = true
encrypt      = true
