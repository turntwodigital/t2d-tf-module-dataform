resource "google_cloudfunctions2_function" "send_notification" {
    name        = "${var.resource_prefix}-function-send-notifications"
    project     = var.project_id
    location    = var.region
    description = "Cloud function used within BigQuery Remote UDFs to send notifications from BigQuery / Dataform"

    build_config {
        runtime     = "nodejs20"
        entry_point = "main"

        source {
            storage_source {
                bucket = google_storage_bucket.send_notification.id
                object = google_storage_bucket_object.send_notification.name
            }
        }
    }

    service_config {
        min_instance_count             = 1
        max_instance_count             = 1
        timeout_seconds                = 60
        #environment_variables          = {}
        ingress_settings               = "ALLOW_ALL"
        all_traffic_on_latest_revision = true
    }

    depends_on  = [ 
        google_project_service.apis
    ]
}

data "archive_file" "send_notification" {
    type        = "zip"
    output_path = "/tmp/function_send_notification.zip"
    source_dir  = "${path.module}/../src/function_send_notification"
    excludes    = [
        "node_modules",
        "README.md"
    ]
}

resource "google_storage_bucket_object" "send_notification" {
    name   = "send_notification.${data.archive_file.send_notification.output_sha}.zip"
    bucket = google_storage_bucket.send_notification.id
    source = data.archive_file.send_notification.output_path
    depends_on = [ 
        google_storage_bucket.send_notification
    ]
}