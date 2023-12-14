# module "gke_cluster" {
#   source         = "git@github.com:geranton93/tf-google-gke-cluster.git"
#   GOOGLE_REGION  = var.GOOGLE_REGION
#   GOOGLE_PROJECT = var.GOOGLE_PROJECT
#   GKE_NUM_NODES  = var.GKE_NUM_NODES
# }

module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"

  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
}

module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.kind_cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}

# terraform {
#   backend "gcs" {
#     bucket = "terraform-status-bucket-00d23e84-28ef-47b8-8eac-5dc1151360d5"
#     prefix = "terraform/state"
#   }
# }
