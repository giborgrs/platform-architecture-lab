output "state_bucket_name" {
  value = aws_s3_bucket.state.id
}

output "ci_role_arn" {
  description = "Store as the AWS_ROLE_ARN secret in the GitHub environments."
  value       = aws_iam_role.terraform_ci.arn
}
