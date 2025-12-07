# GKE Terraform Setup (Single Environment)

This repository provisions a single **Google Kubernetes Engine (GKE)** cluster using Terraform.  
For a setup that supports multiple environments (`dev`, `staging`, `prod`), see the `gke_multi_env` folder.

---

## 📂 Structure

```
gke_single_env/
├── main.tf              # GKE cluster and node pool configuration
├── provider.tf          # Google Cloud provider configuration
├── variables.tf         # Input variables with defaults
├── outputs.tf           # Output values
└── README.md            # This file
```

---

## 🚀 Usage (Local CLI)

### 1. **Initialize Terraform**
```bash
terraform init
```

### 2. **Authenticate with Google Cloud**
```bash
gcloud auth application-default login
```

### 3. **Plan and Apply**
```bash
# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Optional: Override default variables
```bash
terraform apply \
  -var="project_id=my-gcp-project" \
  -var="region=us-central1" \
  -var="cluster_name=my-gke-cluster" \
  -var="node_pool_size=5"
```

### 4. **Configure kubectl**
Once the cluster is created, fetch the cluster credentials:
```bash
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id>

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

---

## ☁️ Usage (Terraform Cloud)

Terraform Cloud automatically loads default variable values from `variables.tf`:

1. **Push this repo to GitHub/GitLab/Bitbucket**
2. **Connect it to Terraform Cloud**
3. **Create a workspace** (e.g., `production`)
4. **Override variables** in the workspace Variables tab if needed:
   - `project_id`
   - `region`
   - `cluster_name`
   - `node_pool_size`
   - etc.

5. **Set GCP credentials** as a sensitive environment variable:
   - `GOOGLE_CREDENTIALS` (service account JSON key)

6. **Queue a plan** to deploy

---

## 📋 Prerequisites

- Google Cloud Project with billing enabled
- Terraform >= 1.0
- Google Cloud SDK (`gcloud`) configured with credentials
- kubectl installed (for cluster access)

---

## 🔑 GCP Permissions Required

The service account or user needs permissions to:
- Create GKE clusters (`container.admin` role or equivalent)
- Create compute resources
- Manage IAM bindings
- Enable APIs

Minimum required roles:
- `roles/container.admin`
- `roles/compute.admin`
- `roles/servicemanagement.admin`

---

## 📝 Default Variables

All variables have defaults and can be overridden:

- `project_id`: GCP project ID (required - no default)
- `region`: GCP region (default: `us-central1`)
- `cluster_name`: GKE cluster name (default: `my-gke-cluster`)
- `network`: VPC network name (default: `default`)
- `subnetwork`: Subnetwork name (default: `default`)
- `cluster_secondary_range`: Secondary IP range name for pods (required - no default)
- `services_secondary_range`: Secondary IP range name for services (required - no default)
- `node_pool_size`: Number of nodes in the pool (default: `3`)
- `machine_type`: Machine type for nodes (default: `e2-medium`)

---

## 📤 Outputs

After applying the configuration, the following outputs are available:

- `cluster_name`: Name of the created GKE cluster
- `endpoint`: GKE cluster endpoint (API server address)
- `node_pool_name`: Name of the node pool

View outputs with:
```bash
terraform output
```

---

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

---

## 📚 Resources Created

- **GKE Cluster** with managed Kubernetes control plane
- **Node Pool** with auto-scaling Compute Engine instances
- **VPC Network** integration (uses existing VPC)
- **Workload Identity** support for pod-to-GCP authentication

---

## 🔗 Useful Commands

```bash
# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> \
  --region <region> \
  --project <project-id>

# Describe cluster
gcloud container clusters describe <cluster-name> \
  --region <region> \
  --project <project-id>

# Scale node pool
gcloud container clusters update <cluster-name> \
  --num-nodes 5 \
  --node-pool <node-pool-name> \
  --region <region> \
  --project <project-id>

# View Terraform state
terraform state list
terraform state show google_container_cluster.primary

# Plan without applying
terraform plan
```

---

## 🐛 Troubleshooting

### API not enabled
- Terraform will automatically enable the Kubernetes Engine API
- If you encounter API errors, ensure the service account has `servicemanagement.admin` role

### Cluster creation takes a long time
- GKE cluster creation typically takes 10-15 minutes. This is normal.

### Nodes are not reaching Ready state
- Check node pool status: `gcloud container node-pools describe <node-pool-name> --cluster=<cluster-name> --region=<region>`
- Check node logs in Cloud Logging

### kubectl connection issues
- Verify kubeconfig: `kubectl config view`
- Check GCP credentials: `gcloud auth application-default print-access-token`
- Ensure IAM permissions are correct

### Secondary IP ranges not found
- Verify that the secondary IP ranges exist in your VPC
- List ranges: `gcloud compute networks subnets describe <subnetwork> --region=<region>`

---

## 🔐 Security Considerations

- **Workload Identity**: This setup enables Workload Identity for secure pod-to-GCP authentication
- **Private Cluster**: The cluster uses a private endpoint for better security
- **Network Isolation**: Consider using a dedicated VPC and subnets for production

---

## 📖 References

- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
