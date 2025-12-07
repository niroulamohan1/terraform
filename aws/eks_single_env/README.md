# EKS Terraform Setup (Single Environment)

This repository provisions a single **Amazon Elastic Kubernetes Service (EKS)** cluster using Terraform.  
For a setup that supports multiple environments (`dev`, `staging`, `prod`), see the `eks_multi_env` folder.

---

## 📂 Structure

```
eks_single_env/
├── main.tf              # VPC, subnets, security groups, EKS cluster, node groups
├── provider.tf          # AWS provider configuration
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

### 2. **Plan and Apply**
```bash
# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Optional: Override default variables
```bash
terraform apply \
  -var="aws_region=us-west-2" \
  -var="cluster_name=my-eks-cluster" \
  -var="desired_capacity=4" \
  -var="instance_type=t3.large"
```

### 3. **Configure kubectl**
Once the cluster is created, fetch the cluster credentials:
```bash
aws eks update-kubeconfig \
  --name eks-cluster \
  --region us-east-1

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
   - `aws_region`
   - `cluster_name`
   - `desired_capacity`
   - `instance_type`
   - etc.

5. **Set AWS credentials** as sensitive environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (optional)

6. **Queue a plan** to deploy

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

## 📝 Default Variables

All variables have defaults and can be overridden:

- `aws_region`: AWS region (default: `us-east-1`)
- `project_name`: Project name for resource naming (default: `myproject`)
- `cluster_name`: EKS cluster name (default: `eks-cluster`)
- `cluster_version`: Kubernetes version (default: `1.28`)
- `desired_capacity`: Desired number of worker nodes (default: `3`)
- `min_capacity`: Minimum number of worker nodes (default: `1`)
- `max_capacity`: Maximum number of worker nodes (default: `5`)
- `instance_type`: EC2 instance type for worker nodes (default: `t3.medium`)
- `vpc_cidr`: CIDR block for the VPC (default: `10.0.0.0/16`)
- `availability_zones`: List of AZs (default: `["us-east-1a", "us-east-1b"]`)

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

To destroy all resources:

```bash
terraform destroy
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
aws eks update-kubeconfig --name eks-cluster --region us-east-1

# Check cluster status
aws eks describe-cluster --name eks-cluster --region us-east-1

# Scale node group
aws eks update-nodegroup-config --cluster-name eks-cluster \
  --nodegroup-name eks-cluster-node-group \
  --scaling-config minSize=1,maxSize=5,desiredSize=4 \
  --region us-east-1

# View Terraform state
terraform state list
terraform state show aws_eks_cluster.main

# Plan without applying
terraform plan
```

---

## 🐛 Troubleshooting

### Cluster creation takes a long time
- EKS cluster creation typically takes 10-15 minutes. This is normal.

### Nodes are not reaching Ready state
- Check node group status: `aws eks describe-nodegroup --cluster-name eks-cluster --nodegroup-name eks-cluster-node-group --region us-east-1`
- Check node logs: `aws ec2 describe-instances --region us-east-1`

### kubectl connection issues
- Verify kubeconfig: `kubectl config view`
- Check AWS credentials: `aws sts get-caller-identity`
- Ensure IAM user/role has EKS permissions

---

## 📖 References

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
