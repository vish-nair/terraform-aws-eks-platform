output "irsa_role_arn" {
  description = "IAM role ARN for Karpenter controller (IRSA)"
  value       = aws_iam_role.karpenter_controller.arn
}

output "node_role_arn" {
  description = "IAM role ARN for Karpenter-provisioned nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "interruption_queue_url" {
  description = "SQS queue URL for Spot interruption handling"
  value       = aws_sqs_queue.karpenter_interruption.url
}
