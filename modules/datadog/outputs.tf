output "irsa_role_arn" {
  description = "IAM role ARN for the Datadog agent (IRSA)"
  value       = aws_iam_role.datadog.arn
}
