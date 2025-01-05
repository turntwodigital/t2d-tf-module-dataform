# Create secret for (external) Git repository
resource "google_secret_manager_secret" "secret" {
  provider  = google-beta
  secret_id = "${var.resource_prefix}-secret-dataform-${var.dataform_name}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  provider    = google-beta
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.dataform_git_repo_secret
}

# Should be granted to the default Dataform service account (currently doesn't work with custom SA)
resource "google_secret_manager_secret_iam_member" "secret_access" {
  provider = google-beta

  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}