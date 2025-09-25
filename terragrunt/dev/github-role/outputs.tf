output "github_actions_role_arn" {
  value       = aws_iam_role.this[0].arn
  description = "ARN of the IAM role for GitHub Actions - add this to your GitHub secrets"
}