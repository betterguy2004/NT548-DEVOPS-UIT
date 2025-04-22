# NT548 DevOps Lab 1 - AWS CLOUDFORMATION SET UP

This guide provides the basic steps to set up a CloudFormation stack (`nt548-stack`), create a VPC, Security Groups, and two EC2 instances (Public and Private), then SSH into the instances.

## **Directory Structure**

```
NT548-DEVOPS-UIT/LAB1/CLOUDFORMATION/
├── templates/
│   ├── main.yaml
│   ├── vpc.yaml
│   ├── security_groups.yaml
│   └── ec2.yaml
└── README.md
```

## **Setup Instructions**

### **Step 1: Create S3 Bucket**

```bash
aws s3 mb s3://nt548-templates-sg --region ap-southeast-1
```

- Upload templates to S3:
  ```bash
  aws s3 cp templates/ s3://nt548-templates-sg/templates/ --recursive --region ap-southeast-1
  ```

Enter your AWS access key, secret key, default region (`ap-southeast-1`), and output format when prompted.

### **Step 2: Set up SSH Key Pair**

1. Create a keypair directory in the CloudFormation folder:
   ```bash
   mkdir -p keypair
   ```

2. Generate SSH key pair:
   ```bash
   cd keypair
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```
   - Save the keys as `nt548-key` (private key) and `nt548-key.pub` (public key) when prompted for the file name.

3. Set appropriate permissions on the private key:
   ```bash
   chmod 400 nt548-key
   ```

4. Import the key pair to AWS:
   ```bash
   aws ec2 import-key-pair --key-name nt548-key-pair --public-key-material fileb://nt548-key.pub --region ap-southeast-1
   ```

5. Return to the main CloudFormation directory:
   ```bash
   cd ..
   ```

### **Step 3: Deploy the Infrastructure**

1. Deploy the CloudFormation stack:
   ```bash
   aws cloudformation create-stack \
     --stack-name nt548-stack \
     --template-body file://templates/main.yaml \
     --parameters \
       ParameterKey=MyIp,ParameterValue=<Your-IP> \
       ParameterKey=KeyName,ParameterValue=nt548-key