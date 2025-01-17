data "google_project" "project" {
  project_id = var.project_id
}

# Create repository
resource "google_dataform_repository" "datahub" {
  provider = google-beta
  name     = "${var.resource_prefix}-dataform-${var.dataform_name}"
  region   = var.dataform_disable_region ? null : var.region
  git_remote_settings {
    url                                 = var.dataform_git_repo
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.secret_version.id
  }

  workspace_compilation_overrides {
    schema_suffix = var.dataform_suffix_dev
  }

  depends_on = [
    google_secret_manager_secret_version.secret_version
  ]
}

# Create and schedule release
resource "google_dataform_repository_release_config" "datahub" {
  count = var.dataform_create_release ? 1 : 0

  provider = google-beta

  project    = google_dataform_repository.datahub.project
  region     = google_dataform_repository.datahub.region
  repository = google_dataform_repository.datahub.name

  name          = "${var.resource_prefix}_dataform_release_full_model"
  git_commitish = var.dataform_git_repo_main_branch
  cron_schedule = "55 * * * *"
  time_zone     = "Europe/Amsterdam"

  code_compilation_config {
    schema_suffix = var.dataform_suffix_prod
  }
}
