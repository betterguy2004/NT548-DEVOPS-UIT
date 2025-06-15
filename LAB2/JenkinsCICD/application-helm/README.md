# Hướng dẫn cài đặt và cấu hình Helm Chart

Dưới đây là các bước hướng dẫn để thêm Helm repository, tìm kiếm chart, tải cấu hình mặc định và cài đặt tài nguyên sử dụng Helm.

## Bước 1: Thêm Repository Helm
Để thêm một repository chứa chart vào Helm, bạn sử dụng Personal Access Token (PAT) để truy cập vào GitHub repository private.

```bash
helm repo add <repo-name> https://<PAT>@raw.githubusercontent.com/MeetingTeam/k8s-repo/main
```

## Bước 2: Tìm kiếm tất cả các Charts/Tài nguyên của Repository

Để tìm kiếm tất cả các charts có trong repository đã thêm, bạn sử dụng lệnh sau:

```bash
helm search repo <repo-name>
```

Ví dụ: helm search repo devops

## Bước 3: Tải Cấu Hình Mặc Định Của Charts/Tài nguyên
Để lấy cấu hình mặc định của một chart và lưu vào một file cấu hình tùy chỉnh (values.custom.yaml), bạn sử dụng lệnh sau:

```bash
helm show values <repo-name>/<tài nguyên cần cài> > values.custom.yaml
```

Ví dụ: helm show values devops/jenkins > values.custom.yaml

## Bước 4: Cài Đặt Tài Nguyên
```bash
helm install <release-name> <repo-name>/<tài nguyên cần cài> -f values.custom.yaml
```
Ví dụ: helm install jenkins devops/jenkins -f values.custom.yaml


