module "gke_cluster" {
  source         = "git@github.com:geranton93/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

terraform {
  backend "gcs" {
    bucket = "terraform-status-bucket-00d23e84-28ef-47b8-8eac-5dc1151360d5"
    prefix = "terraform/state"
  }
}
