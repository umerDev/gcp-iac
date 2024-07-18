remote_state {
  backend = "gcs"
   generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project  = "mindful-vial-429816-v0"
    location = "eu"
    bucket   = "terraform-state-dev-321"
    prefix   = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
    provider "google" {
        project     = "mindful-vial-429816-v0"
        region      = "europe-west2-b"
    }
    EOF
}