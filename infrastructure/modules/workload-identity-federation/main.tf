locals {
  google_project_id = "mindful-vial-429816-v0"
  organization_name = "example-org"
}
 
# create a workload identity pool for HCP Terraform
resource "google_iam_workload_identity_pool" "hcp_tf" {
  project                   = local.google_project_id
  workload_identity_pool_id = "hcp-tf-pool"
  display_name              = "HCP Terraform Pool"
  description               = "Used to authenticate to Google Cloud"
}
 
# create a workload identity pool provider for HCP Terraform
resource "google_iam_workload_identity_pool_provider" "hcp_tf" {
  project                            = local.google_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.hcp_tf.workload_identity_pool_id
  workload_identity_pool_provider_id = "hcp-tf-provider"
  display_name                       = "HCP Terraform Provider"
  description                        = "Used to authenticate to Google Cloud"
#   attribute_condition                = "assertion.terraform_organization_name==\"${local.organization_name}\""
  attribute_mapping = {
    "google.subject"                     = "assertion.sub"
    "attribute.terraform_workspace_id"   = "assertion.terraform_workspace_id"
    "attribute.terraform_full_workspace" = "assertion.terraform_full_workspace"
  }
  oidc {
    issuer_uri = "https://app.terraform.io"
  }
}

resource "google_service_account" "example" {
  account_id   = "example"
  display_name = "Service Account for HCP Terraform"
  project      = local.google_project_id
}
 
# IAM verifies the HCP Terraform Workspace ID before authorizing access to impersonate the 'example' service account
resource "google_service_account_iam_member" "example_workload_identity_user" {
  service_account_id = google_service_account.example.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.hcp_tf.name}/attribute.terraform_workspace_id/ws-ZZZZZZZZZZZZZZZ"
}
 
# grant 'example' service account permissions to create a bucket
resource "google_project_iam_member" "example_storage_admin" {
  member  = "serviceAccount:${google_service_account.example.email}"
  role    = "roles/storage.admin"
  project = local.google_project_id
}

# create a variable set to store the workload identity federation config for the 'example' service account
resource "tfe_variable_set" "example" {
  name         = google_service_account.example.account_id
  description  = "Workload identity federation configuration for ${google_service_account.example.name}"
  organization = local.organization_name
}
 
# share the variable set with another HCP Terraform Workspace
resource "tfe_workspace_variable_set" "example" {
  variable_set_id = tfe_variable_set.example.id
  workspace_id    = "ws-XXXXXXXXXXXXXXX"
}

resource "tfe_variable" "example_provider_auth" {
  key             = "TFC_GCP_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = tfe_variable_set.example.id
}
 
resource "tfe_variable" "example_service_account_email" {
  sensitive       = true
  key             = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value           = google_service_account.example.email
  category        = "env"
  variable_set_id = tfe_variable_set.example.id
}
 
resource "tfe_variable" "example_provider_name" {
  sensitive       = true
  key             = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value           = google_iam_workload_identity_pool_provider.hcp_tf.name
  category        = "env"
  variable_set_id = tfe_variable_set.example.id
}