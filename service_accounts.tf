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
        google_dataform_repository.datahub
    ]
}

# Grant Pub/sub standard service account access to serviceAccountTokenCreator
resource "google_project_iam_binding" "project_binding_pubsub" {
    count   = var.dataform_ga_create_trigger ? 1 : 0

    provider = google-beta
    project  = var.project_id
    role     = "roles/iam.serviceAccountTokenCreator"
    members  = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"]
    depends_on = [ 
        google_project_service.apis 
    ]
}

# Create a service account for Eventarc / Workflows / Dataform trigger
resource "google_service_account" "dataform_workflows" {
    count        = var.dataform_ga_create_trigger ? 1 : 0
    
    provider     = google-beta
    account_id   = "${var.resource_prefix}-dataform-workflows"
    display_name = "Dataform - Workflows Service Account"
    depends_on = [ 
        google_project_service.apis 
    ]
}

# Set correct roles on the Eventarc / Workflows / Dataform trigger
resource "google_project_iam_member" "dataform_workflows" {
    for_each = var.dataform_ga_create_trigger ? toset([
        "roles/logging.logWriter",
        "roles/workflows.invoker",
        "roles/dataform.serviceAgent",
    ]) : toset([])
    provider = google-beta
    project  = var.project_id
    role     = each.value
    member   = "serviceAccount:${google_service_account.dataform_workflows[0].email}"
    depends_on = [
        google_service_account.dataform_workflows
    ]
}