# resource "google_storage_bucket" "example" {
#   name     = "example"
#   location = "EU"
#   project  = "mindful-vial-429816-v0"
# }

data "google_storage_bucket" "my-bucket" {
  name = "terraform-state-dev-321"
}