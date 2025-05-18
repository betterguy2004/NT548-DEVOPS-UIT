# NT548 Terraform AWS Infrastructure Deployment

This repository contains Terraform code to deploy a complete AWS infrastructure consisting of a VPC with public and private subnets, NAT Gateway, Internet Gateway, EC2 instances, and appropriate security groups.

## Infrastructure Overview

The deployed infrastructure includes:

- **VPC** with CIDR block `10.0.0.0/16`
- **2 Public Subnets** in different Availability Zones
- **2 Private Subnets** in different Availability Zones
- **Internet Gateway** for public internet access
- **NAT Gateway** for private subnet outbound internet access
- **Route Tables** for public and private subnets
- **Security Groups** for both public and private instances
- **EC2 Instances** (`t2.micro`) in both public and private subnets
- **SSH Key Pair** for secure instance access

## Prerequisites

- AWS CLI installed and configured
- Terraform v1.0.0+ installed
- An AWS account with appropriate permissions

## Setup Instructions

### Step 1: Configure AWS CLI

```bash
aws configure
```

Enter your AWS access key, secret key, default region (`ap-southeast-1`), and output format when prompted.

### Step 2: Set up SSH Key Pair

1. Create a keypair directory in the Terraform folder:
   ```bash
   mkdir -p keypair
   ```
2. Generate SSH key pair:
   ```bash
   cd keypair
   type nul > nt548-key 
   type nul > nt548-key.pub
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   save as nt548-key
   ```
   - Save the keys as `nt548-key` (private key) and `nt548-key.pub` (public key) when prompted for the file name.
3. Set appropriate permissions on the private key:
   ```bash
   chmod 400 nt548-key
   ```
4. Return to the main Terraform directory:
   ```bash
   cd ..
   ```

### Step 3: Deploy the Infrastructure

1. Initialize Terraform and download required providers:
   ```bash
   terraform init
   ```
2. Preview the changes that will be made:
   ```bash
   terraform plan --var-file="terraform.tfvars"
   ```
3. Apply the changes to create the infrastructure:
   ```bash
   terraform apply --var-file="terraform.tfvars"
   ```
   - Confirm by typing `yes` when prompted.

## Connecting to Instances

### Step 4: SSH Connection

- **To connect to the public instance**:
  ```bash
  eval "$(ssh-agent -s)"
  ssh-add ./keypair/nt548-key
  ssh -A ec2-user@<public_instance_ip>
  ```
  - The public IP address will be displayed in the Terraform outputs after successful deployment.

- **To connect to the private instance from the public instance**:
  ```bash
  ssh ec2-user@<private_instance_ip>
  ```

## File Structure

```
TERRAFORM/
├── main.tf            # Main configuration file
├── variables.tf       # Variable definitions
├── outputs.tf         # Output definitions
├── terraform.tfvars   # Variable values
├── modules/           # Modular components
│   ├── compute/       # EC2 instance configurations
│   ├── networking/    # VPC, subnets, gateways, etc.
│   └── security/      # Security groups
└── keypair/           # SSH key pair files (generated)
```

## Cleanup

### Step 5: Destroy Resources

When you're done with the infrastructure, destroy all created resources to avoid unnecessary charges:
```bash
terraform destroy --var-file="terraform.tfvars"
```  

## Notes

- This infrastructure creates resources that may incur AWS charges.
- The security group for the public instance only allows SSH access from a specific IP (`a.b.c.d/32`). To change it go to main.tf in module security
- Private instances can only be accessed through the public instance.
- All created instances run Amazon Linux 2 AMI.
