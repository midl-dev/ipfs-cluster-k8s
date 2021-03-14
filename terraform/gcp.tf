provider "kubernetes" {
  host             = var.kubernetes_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token = var.kubernetes_access_token
}
