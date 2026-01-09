
# GKE Terraform Setup

This folder provisions a **Google Kubernetes Engine (GKE)** cluster using Terraform for multiple environments (dev, staging, prod).

---

## 📂 Structure

```
gke_multi_env/
├── main.tf              # GKE cluster and node pool configuration
├── provider.tf          # Google Cloud provider configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── README.md            # This file
└── env/
	├── dev.tfvars       # Development environment variables
	├── staging.tfvars   # Staging environment variables
	└── prod.tfvars      # Production environment variables
```

---

## 🚀 Usage (Local CLI)

1. Initialize Terraform

```bash
terraform init
```

2. Create/select workspaces and apply per-environment vars

```bash
# dev
terraform workspace new dev || terraform workspace select dev
terraform apply -var-file=env/dev.tfvars

# staging
terraform workspace new staging || terraform workspace select staging
terraform apply -var-file=env/staging.tfvars

# prod
terraform workspace new prod || terraform workspace select prod
terraform apply -var-file=env/prod.tfvars
```

3. Configure kubectl

```bash
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
kubectl get nodes
kubectl get pods --all-namespaces
```

---

## ☁️ Terraform Cloud

Terraform Cloud doesn't auto-load arbitrary `.tfvars` files — create separate workspaces (dev/staging/prod) and copy variables from the files into each workspace's Variables tab, or use `*.auto.tfvars`.

Set GCP credentials in the workspace as `GOOGLE_CREDENTIALS` (service account JSON) before queuing runs.

---

## 📋 Prerequisites

- Google Cloud project with billing enabled
- Terraform >= 1.0
- `gcloud` configured with credentials
- `kubectl` installed

---

## 📝 Variables

Each `env/*.tfvars` should set values for:

- `project_id`
- `region`
- `environment` (dev/staging/prod)
- `cluster_name`
- `cluster_secondary_range`
- `services_secondary_range`
- `node_pool_size`
- `machine_type`

---

## 📤 Outputs

After apply, view with `terraform output` for:

- `cluster_name`
- `endpoint`
- `node_pool_name`

---

## 🧹 Cleanup

```bash
terraform workspace select <environment>
terraform destroy -var-file=env/<environment>.tfvars
```

---

## 🔗 Useful Commands

```bash
gcloud container clusters describe <cluster-name> --region <region> --project <project-id>
terraform plan -var-file=env/<environment>.tfvars
terraform state list
```

---

## 📖 References

- https://cloud.google.com/kubernetes-engine/docs
- https://registry.terraform.io/providers/hashicorp/google/latest/docs

