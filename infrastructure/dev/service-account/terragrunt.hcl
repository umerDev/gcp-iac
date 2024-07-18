terraform {
  source = "../../modules/service-account"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env-vars.hcl")
  expose         = true
  merge_strategy = "no_merge"
}


inputs = {

}