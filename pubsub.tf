# Pub/sub topic for our log sink
resource "google_pubsub_topic" "ga_exports" {
    count   = var.dataform_ga_create_trigger ? 1 : 0
    
    name    = "${var.resource_prefix}-pubsub-ga_exports"
    project = var.project_id
    depends_on = [ 
        google_project_service.apis
    ]
}

# Log sink which listens for GA4 raw data imports by Google 
resource "google_logging_project_sink" "ga_exports" {
    count       = var.dataform_ga_create_trigger ? 1 : 0
    
    name        = "${var.resource_prefix}-logsink-ga_exports"
    destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.ga_exports[0].name}"
    filter      = "protoPayload.methodName=\"jobservice.jobcompleted\"\nAND protoPayload.authenticationInfo.principalEmail=\"firebase-measurement@system.gserviceaccount.com\"\nAND protoPayload.serviceData.jobCompletedEvent.job.jobConfiguration.load.destinationTable.datasetId=~\"${var.dataform_ga_regex_datasets}\"\nAND protoPayload.serviceData.jobCompletedEvent.job.jobConfiguration.load.destinationTable.tableId=~\"${var.dataform_ga_regex_tables}\""
    depends_on  = [ 
        google_pubsub_topic.ga_exports, 
        google_project_service.apis
    ]
}

# Add log sink service account to Pub/sub topic and provide Pub/sub publish roles
resource "google_pubsub_topic_iam_member" "pubsub_topic_add_sa" {
    count   = var.dataform_ga_create_trigger ? 1 : 0
    
    project = var.project_id
    topic   = google_pubsub_topic.ga_exports.name
    role    = "roles/pubsub.publisher"
    member  = "serviceAccount:cloud-logs@system.gserviceaccount.com"
    depends_on = [ 
        google_logging_project_sink.ga_exports
    ]
}