resource "google_monitoring_notification_channel" "webhook_dataform_failed_run" {
  count = var.dataform_create_webhook ? 1 : 0
  
  display_name = "${var.resource_prefix}-webhook-dataform-failed-run"
  type         = "webhook_tokenauth"
  
  labels = {
    url = var.dataform_webhook_url
  }

}

resource "google_monitoring_alert_policy" "dataform_failed_run" {
  count = var.dataform_create_webhook ? 1 : 0
  
  display_name = "${var.resource_prefix}-alert-dataform-failed-run"
  combiner     = "OR"

  conditions {
    display_name = "dataform_failed_runs"
    
    condition_matched_log {
      filter = "severity>=ERROR AND protoPayload.metadata.jobChange.job.jobName=~\"dataform\" AND protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_workflow_execution_action_id_schema=~\"_${var.dataform_suffix_prod}\""

      label_extractors = {
        "error_message" = "EXTRACT(protoPayload.status.message)",
        "job_name" = "EXTRACT(protoPayload.metadata.jobChange.job.jobName)",
        "dataform_repository_id" = "EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_repository_id)",
        "dataform_workflow_execution_action_id_database" = "EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_workflow_execution_action_id_database)",
        "dataform_workflow_execution_action_id_schema" = "EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_workflow_execution_action_id_schema)",
        "dataform_workflow_execution_action_id_name" = "EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_workflow_execution_action_id_name)",
        "dataform_workflow_execution_id" = "EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.labels.dataform_workflow_execution_id)",
        #"table_description" = "REGEXP_EXTRACT(protoPayload.metadata.jobChange.job.jobConfig.queryConfig.query, \"OPTIONS\\(description='''([^']*?)'''\")"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.webhook_dataform_failed_run[0].id
  ]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }

  documentation {
    content = "Failed action in workflow run for $${dataform_repository_id}. $${dataform_workflow_execution_action_id_name}: $${error_message}"
    mime_type = "text/markdown"
  }

  depends_on = [ 
    google_project_service.apis, 
    google_monitoring_notification_channel.webhook_dataform_failed_run
  ]
}