# -----------------------------------------------------------------------------
# VPC Network
# -----------------------------------------------------------------------------
# Custom-mode VPC so we have full control over subnet topology.
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  # Keep the default route to the internet gateway; Cloud NAT needs it.
  delete_default_routes_on_create = false
}

# -----------------------------------------------------------------------------
# Regional Subnet
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "subnet" {
  project                  = var.project_id
  name                     = "${var.name_prefix}-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true # Allow VMs without public IPs to reach Google APIs

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1 # Low sampling rate to keep costs down while still useful for debugging
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------

# Baseline deny-all-ingress rule at the lowest custom priority.
# Explicit rules above this priority selectively allow required traffic.
resource "google_compute_firewall" "deny_all_ingress" {
  project  = var.project_id
  name     = "${var.name_prefix}-deny-all-ingress"
  network  = google_compute_network.vpc.name
  priority = 65534

  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  # Apply to every instance in the network
  source_ranges = ["0.0.0.0/0"]
}

# Allow internal communication within the subnet CIDR.
resource "google_compute_firewall" "allow_internal" {
  project  = var.project_id
  name     = "${var.name_prefix}-allow-internal"
  network  = google_compute_network.vpc.name
  priority = 1000

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

# Allow GCP health-check probes so managed instance groups / load balancers work.
resource "google_compute_firewall" "allow_health_checks" {
  project  = var.project_id
  name     = "${var.name_prefix}-allow-health-checks"
  network  = google_compute_network.vpc.name
  priority = 1000

  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  # Official Google health-check source ranges
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}

# -----------------------------------------------------------------------------
# Cloud Router & NAT
# -----------------------------------------------------------------------------
# Router is required by Cloud NAT to advertise routes.
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT allows private VMs to reach the internet (e.g. pull container images)
# without needing external IP addresses.
resource "google_compute_router_nat" "nat" {
  project = var.project_id
  name    = "${var.name_prefix}-nat"
  router  = google_compute_router.router.name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
