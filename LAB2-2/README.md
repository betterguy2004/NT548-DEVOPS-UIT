# NT548 DevOps - LAB2-2: AWS CloudFormation CI/CD với TaskCat và cfn-lint

## Tổng quan
LAB2-2 là bài thực hành về kiểm thử và xác thực tự động CloudFormation templates bằng TaskCat và cfn-lint thông qua AWS CodePipeline. Dự án này tập trung vào quy trình CI/CD cho Infrastructure as Code (IaC) trên AWS.

## Chi tiết cấu hình và công cụ kiểm thử

### 1. buildspec.yaml

`buildspec.yaml` là file cấu hình cho AWS CodeBuild, định nghĩa các bước trong quá trình build tự động:

**Giải thích chi tiết:**

1. **Phase install**: 
   - Cài đặt các công cụ cfn-lint và taskcat bằng pip

2. **Phase pre_build**:
   - Thực thi cfn-lint để kiểm tra tất cả các template trong thư mục templates
   - Lỗi từ cfn-lint sẽ làm dừng quá trình build

3. **Phase build**:
   - Chạy TaskCat để kiểm thử việc triển khai thực tế các template

4. **Artifacts**:
   - Lưu trữ các tệp đầu ra để phân tích sau này

### 2. taskcat.yaml

`taskcat.yaml` là file cấu hình cho TaskCat, định nghĩa cách công cụ kiểm thử các CloudFormation template:

```yaml
project:
  name: nt548-devops
  regions:
    - ap-southeast-1  # Singapore
  parameters:
    # Các tham số chung cho tất cả templates
    EnvironmentName: test-env
  
tests:
  vpc-test:
    template: ./templates/vpc.yaml
    parameters:
      VpcCidr: 10.0.0.0/16
      PublicSubnetCidr: 10.0.1.0/24
      PrivateSubnetCidr: 10.0.2.0/24
  
  sg-test:
    template: ./templates/security_groups.yaml
    parameters:
      VpcId: !Ref VpcId   # Tham chiếu đến output từ vpc-test
  
  ec2-test:
    template: ./templates/ec2.yaml
    parameters:
      KeyName: lab-key
      InstanceType: t2.micro
      SubnetId: !Ref PublicSubnetId   # Tham chiếu đến output từ vpc-test
      SecurityGroupId: !Ref WebSecurityGroupId   # Tham chiếu đến output từ sg-test
  
  main-test:
    template: ./templates/main.yaml
    parameters:
      EnvironmentName: test-env
      VpcCidr: 10.0.0.0/16
      KeyName: lab-key
```

**Giải thích chi tiết:**

1. **Project Configuration**:
   - Tên dự án: nt548-devops
   - Region kiểm thử: ap-southeast-1 (Singapore)
   - Các tham số chung cho tất cả các template

2. **Test Cases**:
   - **vpc-test**: Kiểm thử template VPC với các tham số CIDR cụ thể
   - **sg-test**: Kiểm thử template Security Groups, sử dụng tham chiếu từ vpc-test
   - **ec2-test**: Kiểm thử template EC2 với tham số từ các test trước
   - **main-test**: Kiểm thử template chính với tất cả các tham số

## Công cụ kiểm thử và xác thực

### 1. cfn-lint (CloudFormation Linter)

**cfn-lint** là công cụ kiểm tra cú pháp và xác thực CloudFormation templates:

1. **Chức năng chính**:
   - **Kiểm tra cú pháp**: Phát hiện lỗi cú pháp trong JSON/YAML
   - **Kiểm tra quy tắc**: Xác minh tuân thủ các quy tắc AWS CloudFormation
   - **Kiểm tra tính nhất quán**: Đảm bảo các tham chiếu, tham số và resources được định nghĩa đúng

2. **Quy trình kiểm tra**:
   - Phân tích template trước khi triển khai
   - Báo cáo lỗi với vị trí chính xác trong template
   - Gợi ý cách sửa lỗi

3. **Lợi ích**:
   - Phát hiện lỗi sớm trong quá trình phát triển
   - Tiết kiệm thời gian bằng cách tránh triển khai templates không hợp lệ
   - Đảm bảo tuân thủ các thực hành tốt nhất của AWS

4. **Ví dụ lỗi phát hiện được**:
   - Thiếu thuộc tính bắt buộc trong resource
   - Tham chiếu đến resource không tồn tại
   - Sử dụng không đúng hàm nội tại (Intrinsic Functions)
   - Giá trị tham số không hợp lệ

### 2. TaskCat

**TaskCat** là công cụ kiểm thử tự động cho AWS CloudFormation templates:

1. **Chức năng chính**:
   - **Triển khai thử nghiệm**: Tạo các CloudFormation stack thực tế để kiểm thử
   - **Kiểm thử đa vùng**: Cho phép kiểm thử template ở nhiều region AWS
   - **Kiểm thử tham số**: Kiểm tra với nhiều bộ tham số khác nhau

2. **Quy trình kiểm thử**:
   - Đọc cấu hình từ file taskcat.yaml
   - Triển khai thực tế các CloudFormation stack
   - Theo dõi quá trình tạo stack và các tài nguyên 
   - Tạo báo cáo kết quả chi tiết

3. **Lợi ích**:
   - Kiểm thử end-to-end thực tế
   - Phát hiện các vấn đề chỉ xảy ra khi triển khai
   - Đảm bảo templates hoạt động với các cấu hình khác nhau
   - Tự động hóa quy trình kiểm thử

4. **Các loại lỗi phát hiện được**:
   - Lỗi phụ thuộc tài nguyên
   - Lỗi quyền IAM
   - Giới hạn service quota
   - Tương thích giữa các dịch vụ AWS

## Tích hợp trong CI/CD Pipeline

TaskCat và cfn-lint được tích hợp trong pipeline theo quy trình:

1. **Source Stage**: Lấy mã nguồn CloudFormation templates từ repository
2. **Validation Stage**:
   - **cfn-lint** kiểm tra cú pháp và tuân thủ quy tắc (FAIL FAST)
   - Nếu cfn-lint vượt qua, **TaskCat** sẽ triển khai và kiểm thử templates
3. **Report Stage**: Tạo báo cáo kết quả kiểm thử
4. **Deploy Stage**: Nếu tất cả kiểm thử thành công, triển khai templates lên môi trường thực tế

## Xử lý lỗi thường gặp

1. **Lỗi cfn-lint**:
   - **E1001**: Tham chiếu tài nguyên không hợp lệ
   - **E1010**: Giá trị GetAtt không hợp lệ
   - **E2001**: Thiếu thuộc tính bắt buộc
   - **W2001**: Cảnh báo về các thực hành không tối ưu

2. **Lỗi TaskCat**:
   - **CREATE_FAILED**: Không thể tạo tài nguyên (kiểm tra IAM permissions)
   - **DELETE_FAILED**: Không thể xóa stack sau kiểm thử
   - **ROLLBACK_IN_PROGRESS**: Lỗi trong quá trình tạo tài nguyên
   - **Timeout errors**: Stack tạo quá lâu
