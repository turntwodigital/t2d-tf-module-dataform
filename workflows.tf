# Create a Workflow that will execute Dataform
resource "google_workflows_workflow" "execute_dataform_ga" {
    count   = var.dataform_ga_create_trigger ? 1 : 0
    
    name            = "${var.resource_prefix}-workflow-execute-dataform-ga"
    service_account = google_service_account.dataform_workflows[0].email
    source_contents = templatefile("${path.module}/src/workflow_trigger_dataform/workflow_trigger_dataform.yml", {
        project_id = var.project_id, 
        region = var.region, 
        dataform_repository = google_dataform_repository.datahub.name, 
        dataform_workspace = var.dataform_git_repo_main_branch,
        dataform_execute_dependencies = var.dataform_ga_exec_deps,
        dataform_ga_tag = var.dataform_ga_tag
        dataform_suffix_prod = var.dataform_suffix_prod
    })
    
    depends_on = [ 
        google_project_service.apis,
        google_service_account.dataform_workflows,
        google_dataform_repository.datahub
    ]
}

# Create an Event Arc Pub/sub trigger for the Dataform workflow
resource "google_eventarc_trigger" "ga_export" {
    count       = var.dataform_ga_create_trigger ? 1 : 0

    name        = "${var.resource_prefix}-eventarc-ga-export"
    location    = var.region
    matching_criteria {
        attribute = "type"
        value = "google.cloud.pubsub.topic.v1.messagePublished"
    }
    transport {
        pubsub {
            topic = "projects/${var.project_id}/topics/${google_pubsub_topic.ga_exports[0].name}"
        }
    }
    destination {
        workflow = "projects/${var.project_id}/locations/${var.region}/workflows/${google_workflows_workflow.execute_dataform_ga[0].name}"
    }
    service_account = google_service_account.dataform_workflows[0].email
    
    depends_on = [ 
        google_project_service.apis, 
        google_workflows_workflow.execute_dataform_ga, 
        google_pubsub_topic.ga_exports,
        google_dataform_repository.datahub 
    ]
}
