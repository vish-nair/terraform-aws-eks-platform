data "aws_secretsmanager_secret_version" "datadog_api_key" {
  count     = var.datadog_api_key_secret_arn != "" ? 1 : 0
  secret_id = var.datadog_api_key_secret_arn
}

# ── IAM: Datadog Agent IRSA ──────────────────────────────────────────────────

data "aws_iam_policy_document" "datadog_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^(.+provider/)/", "")}:sub"
      values   = ["system:serviceaccount:datadog:datadog-agent"]
    }
  }
}

resource "aws_iam_role" "datadog" {
  name               = "${var.cluster_name}-datadog-agent"
  assume_role_policy = data.aws_iam_policy_document.datadog_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "datadog" {
  name = "${var.cluster_name}-datadog-agent-policy"
  role = aws_iam_role.datadog.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "tag:GetResources",
        ]
        Resource = "*"
      }
    ]
  })
}

# ── Helm: Datadog Agent ──────────────────────────────────────────────────────

resource "helm_release" "datadog" {
  name             = "datadog"
  namespace        = "datadog"
  create_namespace = true
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = var.datadog_agent_version
  wait             = true
  timeout          = 300

  values = [
    yamlencode({
      datadog = {
        apiKey = var.datadog_api_key_secret_arn != "" ? data.aws_secretsmanager_secret_version.datadog_api_key[0].secret_string : ""
        clusterName = var.cluster_name
        logs = {
          enabled               = true
          containerCollectAll   = true
        }
        apm = {
          portEnabled = true
        }
        processAgent = {
          enabled = true
        }
        kubeStateMetricsEnabled = true
        kubeStateMetricsCore = {
          enabled = true
        }
      }
      clusterAgent = {
        enabled  = true
        replicas = 2
        metricsProvider = {
          enabled = true
        }
      }
      agents = {
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.datadog.arn
          }
        }
      }
    })
  ]
}
