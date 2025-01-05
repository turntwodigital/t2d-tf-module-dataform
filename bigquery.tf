resource "google_bigquery_connection" "connection_bigquery_udf" {
  connection_id = "${var.resource_prefix}-connection-bigquery-udf"
  project       = var.project_id
  location      = "EU"
  cloud_resource {}

  depends_on = [
    google_project_service.apis
  ]
}       