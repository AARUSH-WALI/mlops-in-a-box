# Test network module planning

variables {
  project_id  = "test-mlops-project-12345"
  region      = "us-central1"
  name_prefix = "test-mlops"
  subnet_cidr = "10.10.0.0/24"
}

run "plan_network" {
  command = plan

  module {
    source = "./modules/network"
  }

  assert {
    condition     = output.network_name == "test-mlops-vpc"
    error_message = "VPC name must match prefix naming convention"
  }

  assert {
    condition     = output.subnet_name == "test-mlops-subnet"
    error_message = "Subnet name must match prefix naming convention"
  }

  assert {
    condition     = output.router_name == "test-mlops-router"
    error_message = "Cloud router name must match prefix naming convention"
  }
}
