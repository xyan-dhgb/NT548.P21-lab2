# Quản lý và triển khai hạ tầng AWS và ứng dụng microservices với Terraform, CloudFormation, GitHub Actions, AWS CodePipeline và Jenkins

## Mô tả

Triển khai hạ tầng AWS và ứng dụng microservices sử dụng các công cụ và dịch vụ hiện đại trong DevOps:

- **Terraform** + **GitHub Actions** để triển khai hạ tầng AWS và tự động hóa.
- **CloudFormation** + **AWS CodePipeline** cho quá trình CI/CD.
- **Jenkins** cho quản lý pipeline CI/CD của ứng dụng microservices.

## Nội dung thực hiện

### Terraform + GitHub Actions

- Dùng Terraform để triển khai các dịch vụ AWS bao gồm: VPC, Route Tables, NAT Gateway, EC2, Security Groups được miêu tả như sau:
   - **VPC**: Tạo một VPC chứa các thành phần sau:
      - Subnets: Bao gồm cả Public Subnet (kết nối với Internet Gateway) và Private Subnet (sử dụng NAT Gateway để kết nối ra ngoài).
      - Default Security Group: Tạo Security Group mặc định cho VPC
      - Internet Gateway: Kết nối với Public Subnet để cho phép các tài nguyên bên trong có thể truy cập Internet:
   - **Route Tables**: Tạo Route Tables cho Public và Private Subnet
     - Public Route Table: Định tuyến lưu lượng Internet thông qua Internet Gateway.
     - Private Route Table: Định tuyến lưu lượng Internet thông qua NAT Gateway.
   - **NAT Gateway**: Cho phép các tài nguyên trong Private Subnet có thể kết nối Internet
mà vẫn bảo đảm tính bảo mật (1 điểm).
   - **EC2**: Tạo các instance trong Public và Private Subnet, đảm bảo Public instance có thể truy cập từ Internet, còn Private instance chỉ có thể truy cập từ Public instance thông qua SSH hoặc các phương thức bảo mật khác
   - **Security Groups**: Tạo các Security Groups để kiểm soát lưu lượng vào/ra của EC2 instances 
      - Public EC2 Security Group: Chỉ cho phép kết nối SSH (port 22) từ một IP cụ thể (hoặc IP của người dùng).
      - Private EC2 Security Group: Cho phép kết nối từ Public EC2 instance thông qua port cần thiết (SSH hoặc các port khác nếu có nhu cầu).

- Tự động hóa quá trình triển khai với **GitHub Actions**

- Tích hợp **Checkov** để kiểm tra tính tuân thủ và bảo mật của mã nguồn Terraform

### CloudFormation + AWS CodePipeline

- Sử dụng **CloudFormation** để triển khai các tài nguyên tương tự như trên.
- Dùng **AWS CodeBuild** và tích hợp:
  - `cfn-lint`: Kiểm tra cú pháp CloudFormation.
  - `taskcat`: Kiểm thử triển khai.
- Dùng **AWS CodePipeline** để tự động hóa CI/CD từ **CodeCommit**.

### Jenkins + Microservices (4 điểm)

- Sử dụng **Jenkins** để quản lý pipeline CI/CD:
  - Build, test, deploy ứng dụng microservices lên **Docker/Kubernetes**.
- Tích hợp **SonarQube** để kiểm tra chất lượng mã nguồn.
- Tuỳ chọn: tích hợp thêm **Snyk** hoặc **Trivy** để kiểm tra bảo mật.

##  Cấu trúc repo

```bash
.
├── aws-infr/                 # Mã nguồn hạ tầng dùng Terraform
├── cloudformation/           # Mẫu hạ tầng dùng CloudFormation
├── microservices-app/        # Source code ứng dụng
├── jenkins/                  # Pipeline Jenkinsfile và cấu hình liên quan
├── .github/workflows/        # GitHub Actions
├── README.md                 # Tài liệu hướng dẫn (file này)
└── report.docx               # Báo cáo Word theo yêu cầu