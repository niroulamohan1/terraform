resource "google_container_cluster" "primary" {
	name     = var.cluster_name
	location = var.region

	remove_default_node_pool = true
	initial_node_count       = 1

	network    = var.network
	subnetwork = var.subnetwork

	workload_identity_config {
		identity_namespace = "${var.project_id}.svc.id.goog"
	}

	private_cluster_config {
		enable_private_nodes    = true
		enable_private_endpoint = false
		master_ipv4_cidr_block  = "172.16.0.0/28"
	}

	ip_allocation_policy {
		cluster_secondary_range_name  = var.cluster_secondary_range
		services_secondary_range_name = var.services_secondary_range
	}
}

resource "google_container_node_pool" "primary_nodes" {
	name     = "${var.cluster_name}-pool"
	location = var.region
	cluster  = google_container_cluster.primary.name

	autoscaling {
		min_node_count = 1
		max_node_count = 5
	}

	node_config {
		machine_type = var.machine_type

		# Option 1: Use a GCP-provided image type (COS, Ubuntu, Windows)
		# image_type = "UBUNTU_CONTAINERD"

		# Option 2: Use a custom image from your project
		# image = "projects/${var.project_id}/global/images/custom-gke-node"

		oauth_scopes = [
			"https://www.googleapis.com/auth/cloud-platform",
		]

		labels = {
			env = var.environment != "" ? var.environment : "prod"
		}
		tags = ["gke-node"]
	}

	initial_node_count = var.node_pool_size
}

