# BÁO CÁO CHI TIẾT CẢI TIẾN THUẬT TOÁN ĐIỀU PHỐI (DCC) TRONG MẠNG CELL-FREE MASSIVE MIMO

## 1. CÁC KHÁI NIỆM CƠ BẢN (Dành cho người không chuyên)

Để hiểu rõ bài toán này, cần nắm vững các thuật ngữ cốt lõi sau dưới góc nhìn hệ thống:

*   **Cell-Free Massive MIMO:** Khác với mạng 4G/5G truyền thống chia vùng phủ sóng thành các "ô" (Cells), Cell-Free sử dụng một lượng lớn các điểm truy cập (**Access Points - AP**) rải rác. Mọi AP cùng phối hợp để phục vụ người dùng mà không có biên giới cell.
*   **User-Centric Design:** Thiết kế lấy người dùng làm trung tâm. Thay vì người dùng kết nối vào một trạm cố định, mạng sẽ chọn ra một nhóm AP xung quanh (**Cluster**) để phục vụ người dùng đó.
*   **Spectral Efficiency (SE - Hiệu suất phổ):** Đo lường tốc độ truyền dữ liệu trên mỗi đơn vị băng thông (bit/s/Hz). SE càng cao nghĩa là mạng truyền dữ liệu càng hiệu quả.
*   **CDF (Cumulative Distribution Function):** Đồ thị hàm phân bố tích lũy. Trong viễn thông, chúng ta nhìn vào độ dốc và điểm bắt đầu của đường cong này để đánh giá tốc độ trung bình và tính công bằng (Fairness).
*   **Pilot Contamination (Nhiễu Pilot):** Để trạm phát nhận diện người dùng, họ cần dùng các mã ID (Pilot). Do mã ID hữu hạn, nhiều người dùng phải dùng chung mã, dẫn đến nhiễu và sai lệch khi ước lượng kênh truyền.

---

## 2. VẤN ĐỀ TRONG THUẬT TOÁN GỐC (Baseline)

Dựa trên bài báo của **Emil Björnson (2021)**:
*   **Cơ chế DCC cũ:** Việc chọn AP phục vụ dựa trên việc AP nào nhận được tín hiệu Pilot mạnh nhất.
*   **Hạn chế:** 
    *   Dễ bị sai lệch do nhiễu Pilot (Pilot Contamination).
    *   Gây ra tình trạng mất cân bằng tải: Một số AP ở vị trí thuận lợi bị quá tải, trong khi các AP khác rảnh rỗi.
    *   Người dùng ở vùng sóng yếu thường không có đủ số lượng AP cần thiết để bù đắp sai số, dẫn đến tốc độ gần như bằng 0 (mất tính công bằng).

---

## 3. THUẬT TOÁN CẢI TIẾN (Proposed Improved DCC)

Thuật toán chúng ta đã cập nhật chuyển từ cơ chế dựa trên Pilot sang dựa trên chất lượng kênh thực tế (**Large-scale fading**) với 3 giai đoạn:

### Bước 1: Adaptive Threshold Selection (Ngưỡng thích nghi)
Hệ thống chỉ chọn những AP có chất lượng sóng tối thiểu đạt **10%** so với AP tốt nhất của người dùng đó.
> **Ý nghĩa:** Loại bỏ các AP có tín hiệu quá yếu, giúp CPU giảm tải tính toán không cần thiết và giảm nhiễu nội bộ.

### Bước 2: N-min Connectivity (Kết nối tối thiểu)
Đảm bảo mỗi người dùng luôn có ít nhất **3 AP** phục vụ, bất kể chất lượng sóng thế nào.
> **Ý nghĩa:** Tạo ra sự đa dạng (Diversity). Nếu 1 AP bị nhiễu hoặc che khuất, 2 AP còn lại vẫn duy trì được kết nối, đặc biệt quan trọng cho người dùng ở vùng biên.

### Bước 3: Load Balancing (Cân bằng tải)
Sử dụng vòng lặp để giới hạn số lượng người dùng tối đa trên mỗi AP (ví dụ 8 UE/AP). Nếu vượt quá, AP sẽ chuyển người dùng có kênh yếu nhất sang AP lân cận còn trống.
> **Ý nghĩa:** Tối ưu hóa toàn bộ tài nguyên mạng, không để AP nào bị treo do quá tải.

---

## 4. CÁC THAM SỐ CẤU HÌNH TRONG MÔ PHỎNG

| Tham số | Giá trị | Ý nghĩa thực tế |
| :--- | :--- | :--- |
| `threshold_ratio` | 0.1 | Ngưỡng 10%. Giúp cân bằng giữa chất lượng kênh và số lượng trạm phục vụ. |
| `N_min` | 3 | Đảm bảo tính sẵn sàng cao cho người dùng (Reliability). |
| `L_max` | 8 | Giới hạn mật độ người dùng trên mỗi trạm để tránh nhiễu đồng kênh. |
| `L` | 100-400 | Tổng số lượng trạm phát trong khu vực mô phỏng. |
| `K` | 20-40 | Số lượng người dùng đang truy cập đồng thời. |

---

## 5. KẾT QUẢ ĐẠT ĐƯỢC VÀ Ý NGHĨA

Dựa trên các hình ảnh mô phỏng thu được:

1.  **Cải thiện tính Công bằng (Fairness):** Tốc độ của nhóm người dùng sóng yếu nhất (95%-likely SE) tăng vọt từ **0.1** lên **1.2 bit/s/Hz** (tăng gấp 10-12 lần). Đây là chỉ số quan trọng nhất để chứng minh thuật toán thành công.
2.  **Tốc độ trung bình (Median SE):** Tăng khoảng **60%**, cho thấy toàn bộ người dùng trong mạng đều được hưởng lợi từ việc điều phối AP thông minh.
3.  **Tính ổn định:** Đồ thị CDF của phương pháp mới (Proposed) dựng đứng hơn, chứng tỏ tốc độ mạng cung cấp cho mọi người dùng là đồng đều, giảm thiểu sự chênh lệch giữa các vị trí.

---

## 6. CÁC ĐIỂM CẦN LƯU Ý KHI TRẢ LỜI PHẢN BIỆN

*   **Về tính thực tế:** Thuật toán này rất phù hợp cho **Mạng 6G**, đặc biệt là trong các nhà máy thông minh (Smart Factory) hoặc sân vận động đông người.
*   **Về chi phí:** Bằng cách giới hạn số lượng AP phục vụ (qua ngưỡng Threshold), chúng ta đã tiết kiệm năng lượng và giảm áp lực lên đường truyền trung tâm (Fronthaul) so với việc phục vụ tràn lan.
*   **Về Trade-off:** Chúng ta đánh đổi một chút độ phức tạp tính toán ở bước Cân bằng tải để đổi lấy sự ổn định và tốc độ vượt trội cho người dùng.

---
*Tóm tắt: "Sự cải tiến này biến mạng viễn thông từ một hệ thống cứng nhắc thành một mạng lưới linh hoạt, tự điều chỉnh để phục vụ người dùng một cách công bằng và hiệu quả nhất."*
