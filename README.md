# Multi-Cloud Kubernetes Infrastructure

This repository contains Terraform code to deploy Kubernetes clusters across AWS (EKS), Google Cloud (GKE), and Oracle Cloud (OKE) using a unified codebase.

## 🏗️ Architecture Overview

The infrastructure is designed with a modular approach that allows you to deploy to any of the three major cloud providers by simply changing variable values:

```
.
├── main.tf                    # Root module orchestrating all resources
├── variables.tf               # All variable definitions
├── outputs.tf                 # Output values
├── providers.tf               # Provider configurations
├── backend.tf                 # Backend configuration
├── environments/              # Environment-specific configurations
│   ├── aws-dev.tfvars
│   ├── gcp-dev.tfvars
│   └── oci-dev.tfvars
└── modules/
    ├── network/               # Multi-cloud network module
    ├── kubernetes/            # Multi-cloud Kubernetes module
    └── load-balancer/         # Multi-cloud load balancer module
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform**: Version 1.0 or higher
2. **Cloud CLI Tools**:
   - AWS: `aws` CLI configured with appropriate credentials
   - GCP: `gcloud` CLI authenticated
   - OCI: `oci` CLI configured
3. **kubectl**: For interacting with Kubernetes clusters
4. **Helm**: Version 3.x for deploying Kubernetes applications

### Deployment Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd multicloud-k8s-infrastructure
   ```

2. **Choose your cloud provider** and copy the appropriate tfvars file:
   ```bash
   # For AWS
   cp environments/aws-dev.tfvars terraform.tfvars
   
   # For GCP
   cp environments/gcp-dev.tfvars terraform.tfvars
   
   # For OCI
   cp environments/oci-dev.tfvars terraform.tfvars
   ```

3. **Update the variables** in `terraform.tfvars` with your specific values

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan the deployment**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## 📋 Configuration Guide

### Common Variables (All Clouds)

| Variable | Description | Example |
|----------|-------------|---------|
| `cloud_provider` | Cloud provider to use | `aws`, `gcp`, `oci` |
| `environment` | Environment name | `dev`, `staging`, `prod` |
| `project_name` | Project name prefix | `multicloud` |
| `region` | Cloud region | `us-east-2`, `us-central1`, `us-ashburn-1` |
| `cluster_name` | Kubernetes cluster name | `multicloud-dev-eks` |
| `kubernetes_version` | Kubernetes version | `1.30` |

### AWS-Specific Configuration

```hcl
# AWS Profile
aws_profile = "default"

# IAM Roles for cluster access
aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::123456789012:role/AdminRole"
    username = "admin"
    groups   = ["system:masters"]
  }
]
```

### GCP-Specific Configuration

```hcl
# GCP Project
gcp_project_id = "my-project-id"
gcp_zone       = "us-central1-a"
```

### OCI-Specific Configuration

```hcl
# OCI Authentication
oci_tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
oci_user_ocid        = "ocid1.user.oc1..aaaa..."
oci_fingerprint      = "aa:bb:cc:dd:ee:ff:..."
oci_private_key_path = "~/.oci/oci_api_key.pem"
oci_compartment_id   = "ocid1.compartment.oc1..aaaa..."
```

## 🔧 Module Details

### Network Module

Creates cloud-specific networking resources:
- **AWS**: VPC with public/private subnets, NAT Gateways, Internet Gateway
- **GCP**: VPC with subnets, Cloud NAT, Cloud Router
- **OCI**: VCN with subnets, NAT Gateway, Internet Gateway, Service Gateway

### Kubernetes Module

Deploys managed Kubernetes clusters:
- **AWS**: EKS with managed node groups
- **GCP**: GKE with node pools
- **OCI**: OKE with node pools

### Load Balancer Module

Configures cloud-specific load balancing:
- **AWS**: AWS Load Balancer Controller
- **GCP**: Native GKE Ingress
- **OCI**: OCI Load Balancer integration

## 📊 Node Group Configuration

Configure node groups in your tfvars file:

```hcl
node_groups = {
  general = {
    instance_types = ["t3.medium"]  # AWS
    # instance_types = ["e2-standard-2"]  # GCP
    # instance_types = ["VM.Standard.E4.Flex"]  # OCI
    min_size       = 1
    max_size       = 5
    desired_size   = 3
    disk_size      = 100
    labels = {
      role = "general"
      environment = "dev"
    }
    taints = []
  }
}
```

## 🔐 Backend Configuration

Configure remote state storage for each cloud:

### AWS S3 Backend
```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "aws/dev/terraform.tfstate"
    region = "us-east-2"
  }
}
```

### GCP GCS Backend
```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "gcp/dev"
  }
}
```

### OCI Object Storage Backend
```hcl
terraform {
  backend "s3" {
    bucket   = "terraform-state-bucket"
    key      = "oci/dev/terraform.tfstate"
    region   = "us-ashburn-1"
    endpoint = "https://namespace.compat.objectstorage.us-ashburn-1.oraclecloud.com"
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

## 🔗 Connecting to Your Cluster

After deployment, connect to your cluster:

### AWS EKS
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### GCP GKE
```bash
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

### OCI OKE
```bash
oci ce cluster create-kubeconfig --cluster-id <cluster-id> --file $HOME/.kube/config --region <region>
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

## 🔍 Troubleshooting

### Common Issues

1. **Provider Authentication**: Ensure your cloud CLI tools are properly configured
2. **Quota Limits**: Check your cloud provider quotas for the resources
3. **Network Conflicts**: Ensure VPC CIDR ranges don't conflict with existing networks

### Debug Commands

```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [GCP GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [OCI OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)