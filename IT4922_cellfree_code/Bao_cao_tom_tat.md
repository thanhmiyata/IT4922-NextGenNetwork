# BÁO CÁO TÓM TẮT DỰ ÁN NGHIÊN CỨU CELL-FREE MASSIVE MIMO

## 1. Phát biểu bài toán (Problem Statement)
Trong kiến trúc **Cell-Free Massive MIMO**, hiệu năng hệ thống (Spectral Efficiency - SE) tỷ lệ thuận với số lượng Access Points (APs) phục vụ mỗi người dùng (UE). Tuy nhiên, việc để quá nhiều AP phục vụ một UE (như trong thuật toán DCC gốc của sách - trung bình ~50 AP/UE) gây ra các hệ lụy:
- **Quá tải Fronthaul:** Lưu lượng dữ liệu truyền giữa AP và CPU trung tâm cực lớn.
- **Độ phức tạp tính toán:** CPU phải xử lý đồng thời quá nhiều luồng tín hiệu dẫn đến độ trễ và tiêu tốn năng lượng.
- **Lãng phí tài nguyên:** Nhiều liên kết (links) có chất lượng kênh rất yếu nhưng vẫn được duy trì, không đóng góp đáng kể vào tốc độ truyền.

**Mục tiêu:** Phát triển các thuật toán chọn AP (AP Selection) thông minh nhằm giảm số lượng đường truyền Fronthaul mà vẫn đảm bảo hiệu năng mạng tối ưu.

## 2. Phương pháp tiếp cận (Proposed Approach)
Dự án đề xuất giải pháp **User-Centric DCC (Dynamic Cooperation Clustering)** dựa trên bản đồ suy hao kênh truyền (Large-scale Gain Map) với các ràng buộc thực tế:
- **N_min:** Đảm bảo số lượng AP tối thiểu phục vụ để duy trì kết nối ổn định (Fairness).
- **L_max:** Giới hạn tải tối đa cho mỗi AP để tránh nghẽn mạng (Load Balancing).

## 3. Hai phương án xử lý đề xuất

### Phương án 1: Threshold-based AP Selection & Load Balancing
Thuật toán này tập trung vào việc tối ưu hóa cho từng cá nhân người dùng thông qua 3 bước:
- **Bước 1 (Chọn lọc theo ngưỡng):** Mỗi UE tự động bỏ qua các AP có tín hiệu yếu hơn một tỉ lệ xác định (`threshold_ratio`) so với AP tốt nhất của nó.
- **Bước 2 (Bảo hiểm kết nối):** Kiểm tra nếu UE có ít hơn `N_min` AP, hệ thống sẽ bắt buộc bổ sung các AP tốt nhất còn lại cho UE đó.
- **Bước 3 (Điều tiết tải):** Nếu một AP bị quá tải (phục vụ > `L_max` UE), hệ thống sẽ ngắt kết nối với các UE có kênh yếu nhất và thử chuyển vùng họ sang các AP lân cận đang rảnh.

### Phương án 2: Clustering-based DCC (Affinity Clustering)
Thuật toán này tiếp cận theo hướng gom nhóm người dùng để quản lý tập trung:
- **Bước 1 (Gom cụm):** Sử dụng thuật toán **Hierarchical Clustering** với độ đo tương đồng Cosine để nhóm các UE có vị trí hoặc hướng tín hiệu giống nhau vào một cụm (Cluster).
- **Bước 2 (Gán chữ ký AP):** Tìm ra bộ khung AP tốt nhất cho "trung bình cả nhóm" và gán bộ AP này phục vụ chung cho toàn bộ thành viên trong cụm.
- **Bước 3 (Sửa lỗi & Cân bằng):** Thực hiện các bước bổ sung AP (nếu thiếu N_min) và giảm tải AP (nếu vượt quá L_max) tương tự như phương án 1 để đảm bảo các ràng buộc hệ thống.

## 4. Kết quả thực nghiệm (Experimental Results)
Dựa trên cấu hình mô phỏng: **100 APs, 20 UEs, 20 kịch bản Monte-Carlo (setups)**.

| Chỉ số hiệu năng | DCC Gốc (Sách) | Thuật toán Threshold | Thuật toán Clustering | Hiệu quả cải thiện |
| :--- | :---: | :---: | :---: | :---: |
| **Số AP/UE trung bình** | ~50 AP | **~15.4 AP** | **~15.0 AP** | **Giảm ~70%** |
| **Tổng số liên kết (Links)** | 1000 links | **~308 links** | **~300 links** | **Giảm ~70%** |
| **Độ ổn định (Load Balance)** | Thấp | **Cao** (≤ L_max) | **Rất cao** (Đồng bộ nhóm) | Cải thiện mạnh |
| **Tốc độ truyền (Avg SE)** | 100% (~7.0 bit/s/Hz) | **~86% (~6.0 bit/s/Hz)** | **~84% (~5.9 bit/s/Hz)** | Trade-off hợp lý |

**Kết luận:** Các phương án đề xuất giúp tiết kiệm được **70% tài nguyên đường truyền** và hạ tầng xử lý, trong khi chỉ phải đánh đổi một lượng nhỏ (~15%) hiệu suất truyền dẫn. Đây là một sự đánh đổi cực kỳ hiệu quả cho các bài toán triển khai mạng 5G/6G thực tế với ngân sách hạn chế.
