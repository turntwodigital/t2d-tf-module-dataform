variable "resource_prefix" {
  description = "Resource prefix (e.g. company short name), will be used in cloud resource names"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID (non-numerical)"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "dataform_disable_region" {
  description = "Disable Dataform region declaration, because otherwise it will try to remove and recreate the Dataform project in GCP"
  type        = bool
  default     = false
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

variable "dataform_git_repo_main_branch" {
  description = "Dataform repo main branch"
  type        = string
  default     = "main"
}

variable "dataform_create_release" {
  description = "Create and schedule a release"
  type        = bool
  default     = true
}

variable "dataform_suffix_dev" {
  description = "Dataform dataset suffix for production"
  type        = string
  default     = "dev"
}

variable "dataform_suffix_prod" {
  description = "Dataform dataset suffix for production"
  type        = string
  default     = "prod"
}

variable "dataform_create_webhook" {
  description = "Create a Webhook notification channel and attach it to Dataform related Google Cloud Logs"
  type        = bool
  default     = false
}

variable "dataform_webhook_url" {
  description = "Dataform dataset suffix for production"
  type        = string
  default     = "prod"
}

variable "dataform_ga_create_trigger" {
  description = "Create a Dataform Workflow trigger when Google Analytics data is exported (based on cloud logs)"
  type        = bool
  default     = false
}

variable "dataform_ga_regex_datasets" {
  description = "The RegEx to filter the GA4 raw data exports for specific dataset(s)"
  type        = string
}

variable "dataform_ga_regex_tables" {
  description = "The RegEx to filter the GA4 raw data exports for specific dataset(s)"
  type        = string
}

variable "dataform_ga_tag" {
  description = "The Dataform models with this tag specified will be run on new exports"
  type        = string
  default     = "ga4"
}

variable "dataform_ga_exec_deps" {
  description = "Execute Dataform dependencies of the GA4 models"
  type        = string
  default     = true
}