variable "resource_prefix" {
    description = "Resource prefix (e.g. company short name), will be used in cloud resource names"
    type        = string
}

variable "project_id" {
    description = "GCP Project ID (non-numerical)"
    type        = string
}

variable "dataform_name" {
    description = "Name for Google Dataform (internal) repository"
    type        = string
    default     = "datahub"
}

variable "dataform_git_repo" {
    description = "Git HTTP link to external GitHub Repo"
    type        = string
    default     = ""
}

variable "dataform_git_repo_secret" {
    description = "External Git Repo Secret"
    type        = string
    default     = ""
}

variable "dataform_create_release" {
    description = "Create and schedule a release"
    type        = string
    default     = 1
}

variable "dataform_suffix_prod" {
    description = "Dataform dataset suffix for production"
    type        = string
    default     = "prod"
}