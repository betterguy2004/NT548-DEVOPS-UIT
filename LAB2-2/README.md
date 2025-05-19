# NT548 DevOps - LAB2-2: AWS CloudFormation CI/CD Pipelines

## Tổng quan
LAB2-2 là bài thực hành về triển khai tự động cơ sở hạ tầng AWS bằng CloudFormation thông qua CI/CD Pipeline. Dự án sử dụng AWS CodePipeline để tự động hóa quy trình kiểm tra, xác thực và triển khai các template CloudFormation.

## Nội dung dự án
Dự án triển khai một môi trường đầy đủ trên AWS gồm:
- VPC với subnet công khai và riêng tư
- Internet Gateway và NAT Gateway
- EC2 instance
- Security groups

## Cấu trúc thư mục

```
LAB2-2/
│   buildspec.yaml          # Cấu hình cho AWS CodeBuild
│   Lab1cloudformation.pem  # Key pair để kết nối đến EC2 (không được đẩy lên Git)
│   taskcat.yaml            # Cấu hình cho công cụ kiểm thử TaskCat
│   tokengit                # Token GitHub (không được đẩy lên Git)
│   .gitignore              # Cấu hình các file không theo dõi bởi Git
│
└───templates/
    │   ec2.yaml            # Template tạo EC2 instance
    │   main.yaml           # Template chính, gọi các template con
    │   security_groups.yaml # Template tạo Security groups
    │   vpc.yaml            # Template tạo VPC và các thành phần mạng
```

## Chi tiết các template CloudFormation

### 1. vpc.yaml
Template này định nghĩa hạ tầng mạng cơ bản:

- **VPC**: Tạo một Virtual Private Cloud với CIDR block tùy chỉnh (mặc định: 10.0.0.0/16)
- **Subnets**: Tạo hai subnet:
  - Public Subnet (10.0.1.0/24): Kết nối trực tiếp đến Internet thông qua Internet Gateway
  - Private Subnet (10.0.2.0/24): Kết nối đến Internet thông qua NAT Gateway
- **Internet Gateway**: Cho phép truy cập từ Internet đến VPC
- **NAT Gateway**: Cho phép EC2 trong subnet riêng tư kết nối đến Internet
- **Route Tables**: Định tuyến lưu lượng mạng giữa các subnet và Internet

### 2. security_groups.yaml
Template này định nghĩa các security group cho việc kiểm soát truy cập:

- **Security Groups**: Quy tắc firewall để kiểm soát lưu lượng đến và đi từ các EC2 instance
- **Inbound/Outbound Rules**: Quy tắc cho phép kết nối SSH, HTTP, HTTPS và các cổng khác

### 3. ec2.yaml
Template này tạo các EC2 instance:

- **EC2 Instances**: Máy chủ Amazon EC2 với AMI và instance type được chỉ định
- **User Data**: Script chạy khi instance khởi động lần đầu
- **EBS Volumes**: Cấu hình lưu trữ cho instance

### 4. main.yaml
Template chính, kết hợp các template con:

- **Nested Stacks**: Gọi và tham chiếu các template con
- **Parameters**: Quản lý các tham số đầu vào cho toàn bộ stack
- **Outputs**: Xuất các giá trị quan trọng từ stack

## Pipeline CI/CD

Dự án sử dụng AWS CodePipeline để tự động hóa quy trình phát triển và triển khai:

1. **Source Stage**: Lấy mã nguồn từ repository Git
2. **Validation Stage**: 
   - **cfn-lint**: Kiểm tra cú pháp và tuân thủ quy tắc của CloudFormation templates
   - **TaskCat**: Kiểm thử tự động việc triển khai các template trên nhiều region AWS
3. **Deployment Stage**: Triển khai stack CloudFormation lên môi trường

## Cách sử dụng

### Yêu cầu
- AWS CLI đã được cài đặt và cấu hình
- Quyền IAM đủ để triển khai các dịch vụ AWS được sử dụng

### Triển khai thủ công
```bash
aws cloudformation deploy --template-file templates/main.yaml --stack-name nt548-main-stack --capabilities CAPABILITY_IAM
```

### Kiểm tra bằng TaskCat
```bash
taskcat test run
```

## Xử lý sự cố
- **Lỗi IAM Permission**: Kiểm tra IAM role có đủ quyền để tạo các tài nguyên
- **VPC Limits**: Đảm bảo bạn chưa đạt đến giới hạn VPC trong tài khoản
- **Phụ thuộc tài nguyên**: Xác nhận các tài nguyên phụ thuộc được tạo theo đúng thứ tự

## Bảo mật
- Không đẩy file `.pem` và `tokengit` lên repository
- Sử dụng IAM roles với quyền tối thiểu cần thiết

## Tác giả
- Sinh viên NT548 - Đại học Công nghệ Thông tin (UIT)
