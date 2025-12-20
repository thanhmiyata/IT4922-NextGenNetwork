## 📝 PROMPT CHO AI

```markdown
# ROLE
Bạn là một chuyên gia nghiên cứu về hệ thống truyền thông không dây, đặc biệt chuyên sâu về Cell-Free Massive MIMO và các kiến trúc mạng thế hệ mới (5G/6G).

# CONTEXT
Tôi đang thực hiện bài tập lớn môn "Mạng thế hệ sau" với đề tài:
**"Tìm hiểu các phương pháp thiết kế user-centric cho mạng Cell-Free Massive MIMO"**

Tài liệu tham khảo chính: Cuốn sách "Foundations of User-Centric Cell-Free Massive MIMO" của Emil Björnson và Luca Sanguinetti.

# TASK
Hãy thực hiện các nhiệm vụ sau theo thứ tự:

## PHẦN 1: KIẾN THỨC NỀN TẢNG
Cung cấp định nghĩa chi tiết, dễ hiểu cho các khái niệm sau (sắp xếp từ cơ bản đến nâng cao):

### 1.1 Khái niệm cơ bản về MIMO
- MIMO là gì? Tại sao cần MIMO?
- Massive MIMO là gì? Khác gì với MIMO truyền thống?
- Cellular Massive MIMO vs Cell-Free Massive MIMO

### 1.2 Kiến trúc Cell-Free Massive MIMO
- Access Point (AP) và vai trò của nó
- Central Processing Unit (CPU) và fronthaul
- Mô hình kênh truyền (channel model)
- Large-scale fading coefficient (β_mk)
- Small-scale fading

### 1.3 User-Centric Design
- Network-centric vs User-centric approach
- AP clustering/AP selection
- Scalability trong Cell-Free MIMO

### 1.4 Xử lý tín hiệu
- Channel estimation (ước lượng kênh)
- Pilot signal và pilot contamination
- Precoding/Beamforming: Conjugate Beamforming (CB), MMSE
- Combining techniques: MR (Maximum Ratio), MMSE

### 1.5 Các chỉ số hiệu suất
- Spectral Efficiency (SE) - Hiệu suất phổ
- SINR (Signal-to-Interference-plus-Noise Ratio)
- Uplink SE formula (Use-and-then-Forget bound)
- Downlink SE formula
- Fairness metrics (max-min fairness, proportional fairness)

### 1.6 Kỹ thuật tối ưu
- Power control (điều khiển công suất)
- AP selection algorithms
- Load balancing

## PHẦN 2: KẾ HOẠCH THỰC HIỆN ĐỀ TÀI
Lập kế hoạch chi tiết theo tuần để hoàn thành đề tài, bao gồm:
- Tuần 1-2: Nghiên cứu lý thuyết
- Tuần 3-4: Phân tích và mô phỏng
- Tuần 5: Viết báo cáo và chuẩn bị thuyết trình

## PHẦN 3: NỘI DUNG CHI TIẾT CHO TỪNG PHẦN CỦA ĐỀ TÀI

### 3.1 Trình bày về user-centric trong Cell-Free Massive MIMO
- Giải thích khái niệm
- So sánh với network-centric
- Ưu điểm và thách thức
- Sơ đồ minh họa kiến trúc

### 3.2 Tốc độ dữ liệu đường lên (Uplink)
- Mô hình hệ thống uplink
- Công thức SE uplink với các combining schemes
- Các yếu tố ảnh hưởng
- Ví dụ số hoặc đồ thị minh họa

### 3.3 Tốc độ dữ liệu đường xuống (Downlink)
- Mô hình hệ thống downlink
- Công thức SE downlink với các precoding schemes
- So sánh Conjugate Beamforming vs Local MMSE
- Ví dụ số hoặc đồ thị minh họa

### 3.4 Ảnh hưởng của AP selection
- Các phương pháp AP selection phổ biến
- Trade-off giữa số lượng AP và hiệu suất
- Phân tích ảnh hưởng đến SE uplink và downlink
- Bảng so sánh các phương pháp

### 3.5 Đề xuất cải tiến (sử dụng phương pháp Threshold-based AP Selection với Load Balancing)
- Mô tả phương pháp đề xuất
- Thuật toán chi tiết (pseudocode)
- Phân tích độ phức tạp
- Kết quả mô phỏng dự kiến

## PHẦN 4: CÂU HỎI TIỀM NĂNG TỪ GIÁO VIÊN
Liệt kê 10-15 câu hỏi mà giáo viên có thể hỏi khi bảo vệ, kèm gợi ý trả lời.

# OUTPUT FORMAT
- Sử dụng Markdown với heading rõ ràng
- Mỗi định nghĩa kèm công thức toán học nếu có (LaTeX)
- Có sơ đồ/bảng minh họa khi cần thiết
- Giải thích bằng tiếng Việt, thuật ngữ chuyên môn giữ nguyên tiếng Anh

# CONSTRAINTS
- Nội dung phải chính xác về mặt học thuật
- Phù hợp với trình độ học viên cao học
- Tập trung vào ứng dụng thực tế của Cell-Free MIMO
```

---

## 🎯 HƯỚNG CẢI TIẾN ĐƯỢC CHỌN

### **Threshold-based AP Selection với Load Balancing**

#### Lý do chọn phương pháp này:

| Tiêu chí | Đánh giá |
|----------|----------|
| **Độ khó triển khai** | ⭐⭐ (Thấp) - Không cần machine learning |
| **Yêu cầu toán học** | ⭐⭐⭐ (Trung bình) - Tối ưu hóa đơn giản |
| **Khả năng mô phỏng** | ⭐⭐⭐⭐⭐ (Cao) - Dễ code MATLAB/Python |
| **Tính mới** | ⭐⭐⭐ (Khá) - Kết hợp 2 yếu tố |
| **Thực tế** | ⭐⭐⭐⭐⭐ (Cao) - Áp dụng được ngay |

---

### Mô tả phương pháp đề xuất:

#### Ý tưởng chính:
Kết hợp **threshold-based selection** (chọn AP dựa trên ngưỡng large-scale fading) với **load balancing** (cân bằng tải giữa các AP) để:
1. Đảm bảo mỗi UE được phục vụ bởi các AP có chất lượng kênh tốt
2. Tránh tình trạng một số AP bị quá tải trong khi AP khác nhàn rỗi
3. Cải thiện fairness giữa các UE trong mạng

---

### Thuật toán chi tiết (Pseudocode):

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  THUẬT TOÁN: Adaptive Threshold AP Selection with Load Balancing             ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  INPUT:                                                                      ║
║    - β_mk: Large-scale fading coefficient giữa AP m và UE k                  ║
║    - M: Tổng số Access Points                                                ║
║    - K: Tổng số User Equipments                                              ║
║    - L_max: Tải tối đa cho phép của mỗi AP                                   ║
║    - η: Threshold coefficient (0 < η < 1, thường η = 0.1 đến 0.3)            ║
║    - N_min: Số AP tối thiểu phục vụ mỗi UE                                   ║
║                                                                              ║
║  OUTPUT:                                                                     ║
║    - D_mk ∈ {0,1}: Ma trận phục vụ (1 nếu AP m phục vụ UE k)                 ║
║                                                                              ║
║  ALGORITHM:                                                                  ║
║                                                                              ║
║  1. KHỞI TẠO:                                                                ║
║     - D_mk = 0 với mọi m, k                                                  ║
║     - L_m = 0 với mọi m (tải hiện tại của mỗi AP)                            ║
║                                                                              ║
║  2. VỚI MỖI UE k = 1, 2, ..., K:                                             ║
║                                                                              ║
║     a. Tính ngưỡng động cho UE k:                                            ║
║        τ_k = η × max_m(β_mk)                                                 ║
║                                                                              ║
║     b. Xác định tập ứng viên:                                                ║
║        C_k = {m : β_mk ≥ τ_k}                                                ║
║                                                                              ║
║     c. Sắp xếp C_k theo β_mk giảm dần                                        ║
║                                                                              ║
║     d. VỚI MỖI AP m trong C_k (theo thứ tự β_mk giảm dần):                   ║
║        NẾU L_m < L_max:                                                      ║
║           - D_mk = 1 (AP m phục vụ UE k)                                     ║
║           - L_m = L_m + 1 (cập nhật tải)                                     ║
║        NGƯỢC LẠI:                                                            ║
║           - Bỏ qua AP m (đã quá tải)                                         ║
║                                                                              ║
║     e. KIỂM TRA SỐ AP TỐI THIỂU:                                             ║
║        NẾU sum_m(D_mk) < N_min:                                              ║
║           - Tìm các AP chưa quá tải và chưa phục vụ UE k                     ║
║           - Thêm AP có β_mk cao nhất cho đến khi đạt N_min                   ║
║                                                                              ║
║  3. RETURN D_mk                                                              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

### Mô phỏng cần thực hiện:

#### Các baseline để so sánh:
1. **All-AP serving**: Tất cả M AP phục vụ tất cả K UE
2. **Fixed N-nearest**: Mỗi UE được phục vụ bởi N AP gần nhất (cố định)
3. **LLSF (Largest Large-Scale Fading)**: Chọn N AP có β_mk lớn nhất
4. **Proposed**: Threshold + Load Balancing

#### Các đồ thị cần vẽ:

| STT | Đồ thị | Trục X | Trục Y |
|-----|--------|--------|--------|
| 1 | CDF của SE | Spectral Efficiency (bit/s/Hz) | CDF |
| 2 | Average SE vs số AP | Số AP (M) | Average SE |
| 3 | 95%-likely SE (Fairness) | Phương pháp | SE tại percentile 5% |
| 4 | Fronthaul load | Phương pháp | Số kết nối AP-UE trung bình |
| 5 | SE vs Threshold η | Threshold coefficient η | Average SE |

---

### Tham số mô phỏng đề xuất:

| Tham số | Giá trị | Mô tả |
|---------|---------|-------|
| M | 100 | Số Access Points |
| K | 40 | Số User Equipments |
| N | 4 | Số antenna mỗi AP |
| τ_p | 10 | Số pilot sequences |
| Diện tích | 1 km × 1 km | Vùng phủ sóng |
| L_max | 15 | Tải tối đa mỗi AP |
| η | [0.05, 0.1, 0.2, 0.3] | Threshold coefficient |
| N_min | 3 | Số AP tối thiểu mỗi UE |

---

## 📚 TÀI LIỆU THAM KHẢO

1. **Sách chính**: 
   - Emil Björnson, Luca Sanguinetti, *"Foundations of User-Centric Cell-Free Massive MIMO"*, 2024
   - Link: https://github.com/emilbjornson/cell-free-book

2. **Các chương quan trọng trong sách**:
   - Chapter 2: System Model
   - Chapter 5: Scalable Cell-Free Massive MIMO (quan trọng nhất)
   - Chapter 6: Downlink Spectral Efficiency

3. **Code mô phỏng tham khảo**:
   - MATLAB code từ GitHub của tác giả
   - Figure 5.4, 5.8 (Uplink SE)
   - Figure 6.3, 6.5 (Downlink SE)

---

## ✅ CHECKLIST HOÀN THÀNH ĐỀ TÀI

- [ ] Đọc và hiểu Chapter 2, 5, 6 của sách
- [ ] Viết phần lý thuyết về user-centric
- [ ] Viết phần công thức SE uplink/downlink
- [ ] Implement thuật toán đề xuất bằng MATLAB/Python
- [ ] Chạy mô phỏng với các baseline
- [ ] Vẽ đồ thị so sánh
- [ ] Viết phần kết luận và đánh giá
- [ ] Chuẩn bị slide thuyết trình
- [ ] Dự đoán và chuẩn bị câu hỏi phản biện
