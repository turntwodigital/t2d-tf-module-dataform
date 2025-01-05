resource "google_storage_bucket" "send_notification" {
  name                        = "${var.resource_prefix}-gcs-function-send-notification"
  project                     = var.project_id
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  versioning {
    enabled = true
  }
}