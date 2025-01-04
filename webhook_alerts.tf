resource "google_monitoring_notification_channel" "webhook_dataform" {
	count        = var.dataform_create_webhook ? 1 : 0
	
	display_name = "${var.resource_prefix}-webhook-dataform"
	type         = "webhook"
	
	labels = {
		url = "${var.dataform_webhook_url}"
	}
}

resource "google_monitoring_alert_policy" "dataform_failed_run" {
    count        = var.dataform_create_webhook ? 1 : 0
    
    display_name = "${var.resource_prefix}-alert-dataform-failed-run"
    combiner     = "OR"
  
    conditions {
        display_name = "dataform_failed_runs"
    
        condition_matched_log {
        filter =  filter = <<EOT
severity>=ERROR
protoPayload.metadata.jobChange.job.jobName=~"dataform"
protoPayload.metadata.jobChange.job.jobConfig.queryConfig.query=~"_prod`"
EOT
        }
    }

    extraction_query = <<EOT
fetch global::logging.googleapis.com/log_entry
| filter severity>=ERROR
  && protoPayload.metadata.jobChange.job.jobName=~"dataform"
  && protoPayload.metadata.jobChange.job.jobConfig.queryConfig.query=~"_prod`"
| select
    timestamp,
    severity,
    protoPayload.metadata.jobChange.job.jobName as job_name,
    protoPayload.status.message as error_message,
    regexp_extract(protoPayload.metadata.jobChange.job.jobConfig.queryConfig.query, r"OPTIONS\(description='''(.*?)'''") as table_description
EOT
    }
  }

    notification_channels = [
        google_monitoring_notification_channel.webhook_dataform.id
    ]

    alert_strategy {
        notification_rate_limit {
            period = "300s"
        }
    }

    documentation {
        content = "An action within a Dataform workflow run failed (${project}): ${error_message}"
        mime_type = "text/markdown"
    }

    depends_on = [ 
        google_project_service.apis, 
        google_monitoring_notification_channel.webhook_dataform
    ]
}