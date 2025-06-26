# AWS CodePipeline

## 1. Khái niệm

**AWS CodePipeline** là dịch vụ CI/CD (Continuous Integration/Continuous Delivery) của AWS, giúp tự động hóa quy trình build, test và deploy ứng dụng hoặc hạ tầng lên AWS một cách nhanh chóng, lặp lại và đáng tin cậy.

---

## 2. Thành phần chính

- **Pipeline:** Chuỗi các bước (stage) thực hiện tự động hóa CI/CD.
- **Stage:** Mỗi giai đoạn trong pipeline (ví dụ: Source, Build, Test, Deploy).
- **Action:** Một hành động cụ thể trong stage (ví dụ: lấy code từ GitHub, build bằng CodeBuild, deploy bằng CloudFormation).
- **Artifact:** Đầu ra của một action, có thể là file, image, hoặc template dùng cho các bước tiếp theo.

---

## 3. Luồng hoạt động logic

1. **Source Stage:**  
   Lấy mã nguồn từ repository (GitHub, CodeCommit, S3...).

2. **Build Stage:**  
   Biên dịch, kiểm thử, đóng gói ứng dụng (thường dùng AWS CodeBuild).

3. **Test Stage (tuỳ chọn):**  
   Chạy kiểm thử tự động, kiểm tra chất lượng code, bảo mật...

4. **Deploy Stage:**  
   Triển khai ứng dụng lên môi trường (EC2, ECS, Lambda, CloudFormation...).

5. **Approval Stage (tuỳ chọn):**  
   Chờ phê duyệt thủ công trước khi deploy lên production.

---

## 4. Lưu ý và best practices

- **Quyền truy cập:**  
  Các service (CodeBuild, CloudFormation, Lambda...) cần IAM Role phù hợp để pipeline hoạt động trơn tru.
- **Artifact S3 Bucket:**  
  Pipeline sử dụng S3 để lưu trữ artifact giữa các stage.
- **Tự động hóa:**  
  Giúp giảm lỗi thủ công, tăng tốc độ release, đảm bảo tính nhất quán.
- **Bảo mật:**  
  Sử dụng AWS Secrets Manager hoặc Parameter Store để quản lý thông tin nhạy cảm.
- **Giám sát:**  
  Kết hợp với CloudWatch để theo dõi trạng thái pipeline và gửi cảnh báo khi có lỗi.

---

## 5. Những điểm cần ghi nhớ

- CodePipeline là dịch vụ CI/CD native trên AWS, tích hợp tốt với các dịch vụ AWS khác.
- Pipeline có thể trigger tự động khi có thay đổi mã nguồn hoặc thủ công.
- Có thể mở rộng với custom action (Lambda, webhook...).
- Hỗ trợ rollback khi deploy thất bại.
- Dễ dàng tích hợp với các công cụ kiểm thử, phân tích bảo mật, kiểm soát chất lượng.

---

## 6. Tài liệu tham khảo

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- [AWS CodePipeline Best Practices](https://docs.aws.amazon.com/codepipeline/latest/userguide/best-practices.html)