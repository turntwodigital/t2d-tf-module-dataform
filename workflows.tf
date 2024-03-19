# Create a Workflow that will execute Dataform
resource "google_workflows_workflow" "execute_dataform_ga4" {
    count   = var.dataform_ga_create_trigger ? 1 : 0
    
    name            = "${var.resource_prefix}-workflow-execute_dataform_ga4"
    service_account = google_service_account.dataform_workflows[0].email
    source_contents = templatefile("${path.module}/src/workflow_trigger_dataform.yml", {
        project_id = var.project_id, 
        region = google_dataform_repository.datahub.region , 
        dataform_repository_name = google_dataform_repository.datahub.name, 
        dataform_workspace_name = var.dataform_git_repo_main_branch,
        dataform_execute_dependencies = var.dataform_ga_exec_deps
    })
    depends_on = [ 
        google_project_service.apis,
        google_service_account.dataform_workflows,
        google_dataform_repository.datahub
    ]
}

# Create an Event Arc Pub/sub trigger for the Dataform workflow
resource "google_eventarc_trigger" "ga4_export" {
    count       = var.dataform_ga_create_trigger ? 1 : 0

    name        = "${var.resource_prefix}-eventarc-ga4_export"
    location    = google_dataform_repository.datahub.region
    matching_criteria {
        attribute = "type"
        value = "google.cloud.pubsub.topic.v1.messagePublished"
    }
    transport {
        pubsub {
            topic = "projects/${var.project_id}/topics/ga_exports"
        }
    }
    destination {
        workflow = "projects/${var.project_id}/locations/${var.region}/workflows/execute_dataform_ga4"
    }
    service_account = google_service_account.dataform_workflows.email
    depends_on = [ 
        google_project_service.apis, 
        google_workflows_workflow.execute_dataform_ga4, 
        google_pubsub_topic.ga_exports,
        google_dataform_repository.datahub 
    ]
}