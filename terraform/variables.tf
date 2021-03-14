terraform {
  required_version = ">= 0.13"
}

variable "org_id" {
  type        = string
  description = "Google Cloud organization ID."
  default = ""
}

variable "billing_account" {
  type        = string
  description = "Google Cloud billing account ID."
  default = ""
}

variable "project" {
  type        = string
  description = "Project ID where Terraform is authenticated to run to create additional projects. If provided, Terraform will great the GKE and cluster inside this project. If not given, Terraform will generate a new project."
  default     = ""
}

variable "region" {
  type        = string
  description = "Region in which to create the cluster, or region where the cluster exists."
  default     = "us-central1"
}

variable "node_locations" {
  type        = list
  description = "Zones in which to create the nodes."
  default     = [ "us-central1-b", "us-central1-f" ]
}


variable "kubernetes_namespace" {
  type = string
  description = "Kubernetes namespace to deploy the resource into."
  default = "ipfs"
}

variable "kubernetes_name_prefix" {
  type = string
  description = "Kubernetes name prefix to prepend to all resources (should be short, like xtz)."
  default = "xtz"
}

variable "kubernetes_endpoint" {
  type = string
  description = "Name of the Kubernetes endpoint."
  default = ""
}

variable "cluster_ca_certificate" {
  type = string
  description = "Kubernetes cluster certificate."
  default = ""
}

variable "cluster_name" {
  type = string
  description = "Name of the Kubernetes cluster."
  default = ""
}

variable "kubernetes_access_token" {
  type = string
  description = "Access token for the kubernetes endpoint"
  default = ""
}

variable "terraform_service_account_credentials" {
  type = string
  description = "Path to terraform service account file, created following the instructions in https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform"
  default = "~/.config/gcloud/application_default_credentials.json"
}

variable "kubernetes_pool_name" {
  type = string
  description = "When Kubernetes cluster has several node pools, specify which ones to deploy the baking setup into. Only effective when deploying on an external cluster with terraform_no_cluster_create"
  default = "blockchain-pool"
}

variable "rpc_public_hostname" {
  type = string
  description = "If set, expose the RPC of the public node through a load balancer and create a certificate for the given hostname."
  default = ""
}

variable "rpc_subnet_whitelist" {
  type = list
  description = "IP address whitelisting for the public RPC. Open to everyone by default."
  default = [ "0.0.0.0/0" ]
}

variable "bootstrap_peer_id" {
  description = "the identity of the cluster's bootstrap peer"
}

variable "cluster_secret" {
  description = "the shared secret for the ipfs cluster to converge"
}

variable "bootstrap_peer_b64_encoded_priv_key" {
  description = "The base64 encoded bootstrap peer private key for the ipfs cluster"
}
variable "monitoring_slack_url" {
  type = string
  description = "Slack API URL to send prometheus alerts to."
  default = ""
}


