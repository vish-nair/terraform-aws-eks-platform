resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  wait             = true
  timeout          = 300

  values = [
    yamlencode({
      global = {
        domain = var.argocd_hostname
      }
      configs = {
        params = {
          "server.insecure" = true
        }
        cm = {
          "application.resourceTrackingMethod" = "annotation"
          "resource.customizations.health.argoproj.io_Application" = <<-YAML
            hs = {}
            hs.status = "Progressing"
            hs.message = ""
            if obj.status ~= nil then
              if obj.status.health ~= nil then
                hs.status = obj.status.health.status
                if obj.status.health.message ~= nil then
                  hs.message = obj.status.health.message
                end
              end
            end
            return hs
          YAML
        }
      }
      server = {
        replicas = 2
        autoscaling = {
          enabled     = true
          minReplicas = 2
        }
      }
      repoServer = {
        replicas = 2
        autoscaling = {
          enabled     = true
          minReplicas = 2
        }
      }
      applicationSet = {
        replicas = 2
      }
      redis-ha = {
        enabled = var.enable_ha
      }
      redis = {
        enabled = !var.enable_ha
      }
    })
  ]
}
