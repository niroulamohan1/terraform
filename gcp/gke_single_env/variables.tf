variable "project_id" {
	description = "The GCP project ID"
	type        = string
}

variable "region" {
	description = "Region for the GKE cluster"
	type        = string
	default     = "us-central1"
}

variable "cluster_name" {
	description = "Name of the GKE cluster"
	type        = string
	default     = "my-gke-cluster"
}

variable "network" {
	description = "VPC network name"
	type        = string
	default     = "default"
}

variable "subnetwork" {
	description = "Subnetwork name"
	type        = string
	default     = "default"
}

variable "cluster_secondary_range" {
	description = "Name of the secondary IP range for pods"
	type        = string
}

variable "services_secondary_range" {
	description = "Name of the secondary IP range for services"
	type        = string
}

variable "node_pool_size" {
	description = "Number of nodes in the node pool"
	type        = number
	default     = 3
}

variable "machine_type" {
	description = "Machine type for nodes"
	type        = string
	default     = "e2-medium"
}

