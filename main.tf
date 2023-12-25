module "gke_cluster" {
  source         = "git@github.com:geranton93/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
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
  config_path       = module.gke_cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_k8s_sa = true
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
  annotate_k8s_sa     = true
  location            = var.GOOGLE_REGION
}

module "kms" {
  source = "github.com/den-vasyliev/terraform-google-kms"

  project_id      = var.GOOGLE_PROJECT
  location        = "global"
  keyring         = "sops-flux"
  keys            = ["sops-keys-flux"]
  prevent_destroy = false
}

terraform {
  backend "gcs" {
    bucket = "terraform-status-bucket-00d23e84-28ef-47b8-8eac-5dc1151360d5"
    prefix = "terraform/state"
  }
}
