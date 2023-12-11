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
        "roles/bigquery.jobUser",
        "roles/dataform.admin",
        "roles/secretmanager.secretAccessor",
        "roles/iam.serviceAccountUser"
    ])
    project = var.project_id
    role    = each.value
    member  = "serviceAccount:${google_service_account.dataform.email}"
    depends_on = [
        google_service_account.dataform
    ]
}

# Set correct roles on default Dataform Service Account
resource "google_project_iam_member" "dataform" {
    for_each = toset([
        "roles/bigquery.dataEditor", 
        "roles/bigquery.jobUser",
        "roles/dataform.admin",
        "roles/iam.serviceAccountUser"
    ])
    project = var.project_id
    role    = each.value
    member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
    depends_on = [
        google_service_account.dataform
    ]
}