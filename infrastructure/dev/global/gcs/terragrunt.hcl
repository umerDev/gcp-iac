# locals --> initialize the local variables to be used with the terragrunt.hcl file 
locals {
  # Automatically load environment-level variables
  project_id = read_terragrunt_config(find_in_parent_folders("env-vars.hcl")).locals.project_id
  git_repo   = read_terragrunt_config(find_in_parent_folders("env-vars.hcl")).locals.git_repo
  branch     = read_terragrunt_config(find_in_parent_folders("env-vars.hcl")).locals.branch
}

# Define the location for the root tf-module 
terraform {
//   source = "${local.git_repo}//gcs?ref=${local.branch}"
     source = "../../terragrunt.hcl"
}


# for the backend state prefix 
# generated-prefix-path in the gcs bucket: /env/prod/global/gcs/default.tfstate 
include {
  path = find_in_parent_folders()
}

# Inputs to our root module(terraform.tfvar content) with interpolation if needed.
# Pass the variables values to the root modules
inputs = {
  project_id = local.project_id
  prefix     = "${local.project_id}"
  names       = ["tf-state-example-umer"] #interpolation example 
  location   = "eu-west2"
}