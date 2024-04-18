# t2d-tf-module-dataform

Terraform module to set up a Google Dataform repository within Google Cloud Platform (GCP), including additional features. 

By Krisjan Oldekamp / [Turntwo](https://turntwo.com)

## Features

- Creates a Google Dataform repository and release
- Connects an (external) Git repo
- Optionally, you can set up a trigger workflow that runs the Dataform models tagged with `ga4` when the raw Google Analytics 4 (GA4) export is ready (only possible for daily exports)
- Creates a Google Cloud Function that can be used in a BigQuery Remote UDF, to send notifications

## Prerequisities

- Github: Create a fine-grained (personal) access token in Github and link it to the desired repository. Make sure it has Read/Write access to the repository content (Contents)

## Example

```terraform
module "dataform" {
    count                      = contains(var.modules_list, "dataform") ? 1 : 0
    source                     = "git::https://github.com/turntwodigital/t2d-tf-module-dataform.git?ref=v0.2.0"
    project_id                 = var.project_id
    region                     = var.region
    resource_prefix            = var.resource_prefix
    dataform_git_repo          = var.dataform_git_repo
    dataform_git_repo_secret   = var.dataform_git_repo_secret
    dataform_create_release    = 1
    dataform_suffix_dev        = "dev"
    dataform_suffix_prod       = "prod"
    dataform_ga_create_trigger = 1
    dataform_ga_regex_datasets = "^analytics_12345"
    dataform_ga_regex_tables   = "^events_\\d+"
    dataform_ga_exec_deps      = "true"

    depends_on = [
        google_project_service.apis
    ]
}
```

## Authors

- Krisjan Oldekamp (Turntwo)

## Version History

* 0.3.1
    * Added support for Google Cloud Functions / BigQuery Remote UDFs
* 0.3
    * Added support for triggering Dataform when GA4 exports are ready
* 0.1
    * Initial Release

## License

- To-do

## Acknowledgments

Inspiration, code snippets, etc.

* [GTM Gear / Artem Korneev](https://gtm-gear.com/posts/ga4-terraform/)
* [Moritz Bauer](https://github.com/Liscor/terraform_dataform_ga4_pipeline)
* [Alex Feldman](https://medium.com/google-cloud/technical-and-business-data-alerts-using-dataform-6e0e7f504f0e)