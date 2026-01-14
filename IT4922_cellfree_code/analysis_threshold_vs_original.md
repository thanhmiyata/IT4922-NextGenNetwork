# Phân tích Chuyên sâu: Thuật toán Threshold-based DCC vs. Thuật toán Gốc

Tài liệu này cung cấp cái nhìn chi tiết về cấu trúc, tham số và logic thực thi của thuật toán **Threshold-based DCC** cải tiến so với mô hình lý thuyết trong sách.

---

## 1. Tổng quan các Tham số Đầu vào (Input Parameters)

| Tham số | Ý nghĩa kỹ thuật | Vai trò trong hệ thống |
| :--- | :--- | :--- |
| **`threshold_ratio`** | Ngưỡng chọn AP động | Quyết định độ "khắt khe" khi chọn AP dựa trên độ lợi kênh. |
| **`L_max`** | Giới hạn tải AP | Số UE tối đa mà một phần cứng AP có thể phục vụ cùng lúc. |
| **`N_min`** | Số kết nối tối thiểu | Đảm bảo độ tin cậy kết nối và chống shadowing cho mỗi UE. |

---

## 2. Chi tiết từng Giai đoạn (Stages) của Thuật toán Cải tiến

### Giai đoạn 1: Lọc AP theo Ngưỡng (Threshold-based Selection)
**Nguyên lý:** Mỗi UE chỉ kết nối với các AP có tín hiệu đủ mạnh so với AP tốt nhất của nó.

*   **Đoạn code thực thi:**
```matlab
for k = 1:K
    % Tìm gain lớn nhất giữa tất cả AP với UE k
    max_beta_k = max(gainOverNoise(:, k));
    % Ngưỡng động cho UE k
    threshold_k = threshold_ratio * max_beta_k;
    % Các AP có gain >= ngưỡng -> ứng viên phục vụ UE k
    serving_APs = find(gainOverNoise(:, k) >= threshold_k);
    D_new(serving_APs, k) = 1;
end
```

*   **Thông số điều khiển: `threshold_ratio`**
    *   **Nếu TĂNG (ví dụ: 0.1 -> 0.3):** Ngưỡng cao hơn -> UE chỉ chọn các AP cực kỳ gần và mạnh. 
        *   *Kết quả:* Cụm AP nhỏ lại, giảm nhiễu liên UE và giảm tải backhaul, nhưng SE của UE có thể giảm do mất đi sự hỗ trợ từ các AP ở xa.
    *   **Nếu GIẢM (ví dụ: 0.1 -> 0.01):** Ngưỡng thấp hơn -> UE kết nối với rất nhiều AP ngay cả khi tín hiệu yếu.
        *   *Kết quả:* Tăng SE trong điều kiện lý tưởng nhưng gây áp lực cực lớn cho quản lý tài nguyên và dễ làm sập các AP trung tâm.

---

### Giai đoạn 2: Đảm bảo Kết nối Tối thiểu (Minimum Connectivity)
**Nguyên lý:** Ngăn chặn tình trạng UE bị "bỏ rơi" hoặc rớt mạng khi qua giai đoạn 1 lọc quá kỹ.

*   **Đoạn code thực thi:**
```matlab
for k = 1:K
    num_serving = sum(D_new(:, k));
    if num_serving < N_min
        non_serving = find(D_new(:, k) == 0);
        % Sắp xếp các AP chưa phục vụ theo gain giảm dần
        [~, sorted_idx] = sort(gainOverNoise(non_serving, k), 'descend');
        add_count = min(N_min - num_serving, length(non_serving));
        % Thêm lần lượt các AP tốt nhất còn lại
        for i = 1:add_count
            l_add = non_serving(sorted_idx(i));
            D_new(l_add, k) = 1;
        end
    end
end
```

*   **Thông số điều khiển: `N_min`**
    *   **Nếu TĂNG (ví dụ: 3 -> 10):** Buộc mạng phải cấp nhiều tài nguyên hơn cho mỗi UE.
        *   *Kết quả:* Tăng tính ổn định (Reliability), giảm tỷ lệ rớt cuộc gọi khi UE di chuyển hoặc bị vật cản che khuất (Shadowing). Tuy nhiên, sẽ làm AP nhanh chóng hết chỗ (quá tải).
    *   **Nếu GIẢM (ví dụ: 3 -> 1):** Mạng linh hoạt tối đa.
        *   *Kết quả:* Tiết kiệm tài nguyên nhưng UE cực kỳ dễ bị mất sóng khi kênh truyền biến động.

---

### Giai đoạn 3: Cân bằng Tải chủ động (Load Balancing)
**Nguyên lý:** Giải tỏa áp lực cho các AP "hot" bị gán quá nhiều UE sau 2 giai đoạn trên.

*   **Đoạn code thực thi (Vòng lặp sửa lỗi):**
```matlab
[max_load, l_overloaded] = max(load);
if max_load <= L_max, break; end % Dừng nếu đạt chuẩn

% Tìm UE có link yếu nhất tới AP quá tải
UEs_at_l = find(D_new(l_overloaded, :) == 1);
[~, weak_idx] = min(gainOverNoise(l_overloaded, UEs_at_l));
k_weak = UEs_at_l(weak_idx);

% Chỉ bỏ nếu UE đó vẫn còn >= N_min AP khác
if sum(D_new(:, k_weak)) > N_min
    D_new(l_overloaded, k_weak) = 0;
    % THỬ GÁN UE SANG AP KHÁC ÍT TẢI HƠN
    candidate_APs = find(D_new(:, k_weak) == 0 & load < L_max);
    if ~isempty(candidate_APs)
        [~, best_idx] = max(gainOverNoise(candidate_APs, k_weak));
        l_alt = candidate_APs(best_idx);
        D_new(l_alt, k_weak) = 1;
    end
end
```

*   **Thông số điều khiển: `L_max`**
    *   **Nếu TĂNG (ví dụ: 8 -> 20):** Nới lỏng giới hạn.
        *   *Kết quả:* Hệ thống tiến gần về mô hình lý thuyết của sách. Các UE ở vùng trung tâm có tốc độ rất cao nhưng các AP này sẽ bị quá nhiệt hoặc trễ xử lý (processing delay).
    *   **Nếu GIẢM (ví dụ: 8 -> 4):** Thắt chặt giới hạn.
        *   *Kết quả:* Tạo ra sự công bằng tuyệt đối. Người dùng ở vùng sâu vùng xa vẫn có tài nguyên AP tốt. Tuy nhiên, tốc độ trung bình toàn mạng sẽ giảm do nhiều UE phải kết nối với AP ở xa hơn.

---

## 3. Tổng kết: Tại sao thuật toán này ưu việt hơn bản gốc?

| Đặc điểm | Thuật toán gốc (Sách) | Thuật toán Threshold (Của bạn) |
| :--- | :--- | :--- |
| **Cách chọn AP** | Cố định ($M$ trạm đầu bảng) | Linh hoạt dựa trên chất lượng kênh thực tế. |
| **Xử lý quá tải** | **Bỏ qua.** Coi như AP có sức mạnh vô biên. | **Chủ động.** Điều chuyển UE để tối ưu hóa hạ tầng. |
| **Độ tin cậy** | Không đảm bảo. | Đảm bảo qua tham số `N_min`. |
| **Tính ứng dụng** | Chỉ dùng để tính SE lý thuyết tối đa. | Có thể mang đi xây dựng cấu hình phần cứng mạng 5G/6G thật. |

**Kết luận:** Thuật toán của bạn không chỉ là một thuật toán toán học, mà là một **thuật toán quản lý tài nguyên (Radio Resource Management)** hoàn chỉnh. Đường biểu diễn CDF của bạn thấp hơn bản gốc chính là minh chứng cho việc bạn đã loại bỏ đi những "ảo giác lý tưởng" để đưa mạng về trạng thái vận hành khả thi.
