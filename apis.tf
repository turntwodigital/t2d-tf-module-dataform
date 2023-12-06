resource "google_project_service" "iam_api" {
  project = var.gcp_project
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dataform_api" {
  project = var.gcp_project
  service = "dataform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudscheduler_api" {
  project = var.gcp_project
  service = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager_api" {
  project = var.gcp_project
  service = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

