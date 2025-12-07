# EKS Terraform Setup

This repository provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster using Terraform.  
It supports multiple environments (`dev`, `staging`, `prod`) via workspaces and variable files.

---

## 📂 Structure

```
aws/
├── main.tf              # VPC, subnets, security groups, EKS cluster, node groups
├── provider.tf          # AWS provider configuration
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

### 1. **Initialize Terraform**
```bash
terraform init
```

### 2. **Create and Select Workspaces**
```bash
# Development environment
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file=env/dev.tfvars

# Staging environment
terraform workspace new staging
terraform workspace select staging
terraform apply -var-file=env/staging.tfvars

# Production environment
terraform workspace new prod
terraform workspace select prod
terraform apply -var-file=env/prod.tfvars
```

### 3. **Configure kubectl**
Once the cluster is created, fetch the cluster credentials:
```bash
aws eks update-kubeconfig \
  --name eks-dev \
  --region us-east-1

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

---

## ☁️ Usage (Terraform Cloud)

Terraform Cloud does not automatically read arbitrary `.tfvars` files. Instead, you configure variables per workspace:

1. **Push this repo to GitHub/GitLab/Bitbucket**
2. **Connect it to Terraform Cloud**
3. **Create three workspaces**: `dev`, `staging`, `prod`
4. **Configure variables** in each workspace:
   - Copy values from `env/dev.tfvars`, `env/staging.tfvars`, `env/prod.tfvars`
   - Add them to the **Variables** tab of each workspace
   - Or rename them to `*.auto.tfvars` if you want Terraform Cloud to auto-load them

5. **Set AWS credentials** as sensitive environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (optional)

---

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured with credentials
- kubectl installed (for cluster access)

---

## 🔑 AWS Permissions Required

The IAM user/role needs permissions to create:
- VPCs, subnets, route tables, internet gateways, NAT gateways
- Security groups and security group rules
- EKS clusters and node groups
- IAM roles and policies
- EC2 instances

---

## 📝 Variables

Each environment file (`env/*.tfvars`) contains:

- `aws_region`: AWS region for deployment
- `environment`: Environment name (dev/staging/prod)
- `project_name`: Project name for resource naming
- `cluster_name`: EKS cluster name
- `cluster_version`: Kubernetes version
- `desired_capacity`: Desired number of worker nodes
- `min_capacity`: Minimum number of worker nodes
- `max_capacity`: Maximum number of worker nodes
- `instance_type`: EC2 instance type for worker nodes
- `vpc_cidr`: CIDR block for the VPC
- `availability_zones`: List of availability zones

---

## 📤 Outputs

After applying the configuration, the following outputs are available:

- `cluster_id`: EKS cluster ID
- `cluster_arn`: EKS cluster ARN
- `cluster_endpoint`: EKS cluster endpoint
- `cluster_version`: Kubernetes version
- `cluster_security_group_id`: Security group ID for the cluster
- `node_group_id`: EKS node group ID
- `vpc_id`: VPC ID
- `private_subnet_ids`: Private subnet IDs
- `public_subnet_ids`: Public subnet IDs

View outputs with:
```bash
terraform output
```

---

## 🧹 Cleanup

To destroy all resources in an environment:

```bash
terraform workspace select <environment>
terraform destroy -var-file=env/<environment>.tfvars
```

---

## 📚 Resources Created

- **VPC** with public and private subnets across multiple AZs
- **Internet Gateway** for public internet access
- **NAT Gateways** for private subnet internet access
- **EKS Cluster** with managed Kubernetes control plane
- **Node Group** with auto-scaling EC2 instances
- **Security Groups** for cluster and node communication
- **IAM Roles** for cluster and node permissions

---

## 🔗 Useful Commands

```bash
# Get cluster credentials
aws eks update-kubeconfig --name <cluster-name> --region <region>

# Check cluster status
aws eks describe-cluster --name <cluster-name> --region <region>

# Scale node group
aws eks update-nodegroup-config --cluster-name <cluster-name> \
  --nodegroup-name <nodegroup-name> --scaling-config minSize=1,maxSize=5,desiredSize=3 \
  --region <region>

# View Terraform state
terraform state list
terraform state show aws_eks_cluster.main

# Plan without applying
terraform plan -var-file=env/<environment>.tfvars
```

---

## 🐛 Troubleshooting

### Cluster creation takes a long time
- EKS cluster creation typically takes 10-15 minutes. This is normal.

### Nodes are not reaching Ready state
- Check node group status: `aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --region <region>`
- Check node logs: `aws ec2 describe-instances --region <region>`

### kubectl connection issues
- Verify kubeconfig: `kubectl config view`
- Check AWS credentials: `aws sts get-caller-identity`
- Ensure IAM user/role has EKS permissions

---

## 📖 References

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
