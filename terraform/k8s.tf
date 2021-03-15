locals {
  kubernetes_variables = { "project" : var.project,
       "kubernetes_namespace": var.kubernetes_namespace,
       "kubernetes_pool_name": var.kubernetes_pool_name,
       "bootstrap_peer_id": var.bootstrap_peer_id,
       "rpc_public_hostname": var.rpc_public_hostname}
}

# Provision IP for signer forwarder endpoint if there is at least one occurence of "authorized_signers" data in the bakers map
resource "google_compute_address" "ipfs_p2p_target" {
  # it should not be more than one
  name    = "${var.kubernetes_namespace}-ipfs-p2p-ip"
  region  = var.region
  project = var.project
}

resource "kubernetes_namespace" "ipfs_namespace" {
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "kubernetes_secret" "ipfs_cluster_secret" {
  metadata {
    name = "secret-config"
    namespace = var.kubernetes_namespace
  }
  data = {
    "cluster-secret": var.cluster_secret
    "bootstrap-peer-priv-key": var.bootstrap_peer_b64_encoded_priv_key
  }

  depends_on = [ kubernetes_namespace.ipfs_namespace ]
}

resource "null_resource" "apply" {
  provisioner "local-exec" {

    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
set -e
set -x
gcloud container clusters get-credentials "${var.cluster_name}" --region="${var.region}" --project="${var.project}"

rm -rvf ${path.module}/k8s-${var.kubernetes_namespace}
mkdir -p ${path.module}/k8s-${var.kubernetes_namespace}
cp -rv ${path.module}/../k8s/*base* ${path.module}/k8s-${var.kubernetes_namespace}
cd ${abspath(path.module)}/k8s-${var.kubernetes_namespace}
cat <<EOK > kustomization.yaml
${templatefile("${path.module}/../k8s/kustomization.yaml.tmpl", local.kubernetes_variables)}
EOK

cat <<EOP > static-ip-patch.yaml
${templatefile("${path.module}/../k8s/static-ip-patch.yaml.tmpl", local.kubernetes_variables)}
EOP

cat <<EOP > nodepool.yaml
${templatefile("${path.module}/../k8s/nodepool.yaml.tmpl", local.kubernetes_variables)}
EOP

kubectl apply -k .
cd ${abspath(path.module)}
rm -rvf ${abspath(path.module)}/k8s-${var.kubernetes_namespace}
EOF

  }
  depends_on = [ kubernetes_namespace.ipfs_namespace ]
}

#############################
# Public RPC endpoint
#############################

# Provision IP for public rpc endpoint
resource "google_compute_global_address" "public_rpc_ip" {
  name    = "${var.kubernetes_namespace}-ipfs-rpc-ip"
  project = var.project
}

resource "google_compute_security_policy" "public_rpc_filter" {
  name = "${var.kubernetes_namespace}-ipfs-rpc-filter"
  project = var.project

  dynamic "rule" {
    for_each = [ for index, subnet in concat(var.rpc_subnet_whitelist,
      #Google ranges - for their inernal load balancer monitoring
      ["35.191.0.0/16", "130.211.0.0/22"]) : { "index": index, "subnet": subnet } ]

    content {
      action   = "allow"
      priority = 1000+rule.value.index
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [rule.value.subnet]
        }
      }
      description = "Allow access to whitelisted ips and google monitoring ranges"
    }
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule, deny"
  }

}
