data "google_project" "project" {
    project_id =  var.project_id
}

# Set up service account for Dataform
resource "google_service_account" "dataform" {
    project      = var.project_id
    account_id   = "${var.resource_prefix}-gsa-dataform"
    display_name = "Service Account for Dataform (executing Dataform Workflows)"
}

# Set correct roles on Dataform Service Account
resource "google_project_iam_member" "dataform" {
    for_each = toset([
        "roles/bigquery.dataEditor", 
        "roles/bigquery.jobUser"
    ])
    project = var.project_id
    role    = each.value
    member  = "serviceAccount:${google_service_account.dataform.email}"
    depends_on = [
        google_service_account.dataform
    ]
}

# Create secret for (external) Git repository
resource "google_secret_manager_secret" "secret" {
    provider = google-beta
    secret_id = "${var.resource_prefix}-secret-dataform-${var.dataform_name}"

    replication {
        auto {}
    }
}

resource "google_secret_manager_secret_version" "secret_version" {
    provider = google-beta
    secret = google_secret_manager_secret.secret.id
    secret_data = var.dataform_git_repo_secret
}

# Should be granted to the default Dataform service account (currently doesn't work with custom SA)
resource "google_secret_manager_secret_iam_member" "secret_access" {
    provider = google-beta

    secret_id = google_secret_manager_secret.secret.id
    role      = "roles/secretmanager.secretAccessor"
    member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# Create repository
resource "google_dataform_repository" "datahub" {
    provider        = google-beta
    name            = "${var.resource_prefix}-dataform-${var.dataform_name}"
    service_account = google_service_account.dataform.email

    git_remote_settings {
        url = var.dataform_git_repo
        default_branch = "main"
        authentication_token_secret_version = google_secret_manager_secret_version.secret_version.id
    }

    workspace_compilation_overrides {
        schema_suffix = "_dev"
    }
}