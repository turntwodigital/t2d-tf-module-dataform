resource "google_project_service" "apis" {
  project  = var.project_id
  for_each = toset(
    [
      "iam.googleapis.com",
      "artifactregistry.googleapis.com",
      "bigqueryconnection.googleapis.com",
      "dataform.googleapis.com",
      "cloudscheduler.googleapis.com",
      "cloudfunctions.googleapis.com",
      "cloudbuild.googleapis.com",
      "eventarc.googleapis.com",
      "secretmanager.googleapis.com",
      "pubsub.googleapis.com",
      "workflows.googleapis.com",
      "workflowexecutions.googleapis.com",
    ]
  )
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}