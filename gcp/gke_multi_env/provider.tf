provider "google" {
	project = var.project_id
	region  = var.region
}

resource "google_project_service" "container" {
	project = var.project_id
	service = "container.googleapis.com"
}

