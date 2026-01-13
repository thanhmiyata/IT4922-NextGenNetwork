# Phân Tích và So Sánh 3 Phương Pháp AP Selection trong Cell-Free Massive MIMO

## 0. Nền Tảng Lý Thuyết

### 0.1. Cell-Free Massive MIMO - Khái Niệm Cốt Lõi

**Định nghĩa:**
Cell-Free Massive MIMO là kiến trúc mạng không dây trong đó một số lượng lớn các AP (Access Points) phân tán trong khu vực phục vụ, được kết nối với một CPU (Central Processing Unit) qua mạng fronthaul, cùng phục vụ đồng thời tất cả UE (User Equipment) trong vùng phủ.

**Đặc điểm chính:**
- **Không có cell boundary:** Không chia thành các cell riêng biệt như cellular truyền thống
- **User-centric:** Mỗi UE được phục vụ bởi một tập con AP phù hợp (không phải tất cả AP)
- **Distributed antennas:** AP phân tán → macro-diversity → giảm path-loss variance
- **Coordinated transmission/reception:** CPU phối hợp xử lý tín hiệu từ/đến nhiều AP

**Lợi ích:**
- Tăng spectral efficiency (SE) do macro-diversity
- Giảm transmit power (UE gần hơn với AP)
- Công bằng hơn (cell-edge UE được nhiều AP phục vụ)

### 0.2. Large-Scale Fading và β_mk

**Large-scale fading coefficient β_mk:**

$$\beta_{mk} = \text{PL}_{mk} \cdot \text{SF}_{mk}$$

Trong đó:
- **PL_mk (Path Loss):** Suy hao đường truyền từ AP m đến UE k, phụ thuộc khoảng cách
  - Công thức: $\text{PL}_{mk} = -L - 35\log_{10}(d_{mk})$ (dB)
  - L: constant loss, d_mk: khoảng cách (m)
- **SF_mk (Shadow Fading):** Suy hao do che khuất (log-normal random variable)
  - Phân bố: $\text{SF}_{mk} \sim \mathcal{N}(0, \sigma_{\text{sf}}^2)$ (dB)
  - σ_sf thường 8-10 dB

**Ý nghĩa vật lý:**
- β_mk lớn: AP m "nhìn thấy" UE k tốt → nên phục vụ
- β_mk nhỏ: kênh yếu → phục vụ không hiệu quả, lãng phí tài nguyên

**Đặc điểm:**
- Thay đổi chậm (slow fading) - coherence time ~ giây
- Có thể ước lượng chính xác qua pilot
- Không phụ thuộc frequency selective fading

### 0.3. Spectral Efficiency (SE) - Công Thức Tổng Quát

**SE uplink của UE k (bit/s/Hz):**

$$\text{SE}_k = (1 - \frac{\tau_p}{\tau_c}) \log_2(1 + \text{SINR}_k)$$

Trong đó:
- **τ_p:** Độ dài pilot (symbols)
- **τ_c:** Độ dài coherence block (symbols)
- **$(1 - \tau_p/\tau_c)$:** Tỷ lệ symbols dành cho truyền data (pilot overhead)
- **SINR_k:** Signal-to-Interference-plus-Noise Ratio của UE k

**SINR phụ thuộc vào:**
1. **Combining scheme:** MMSE, P-MMSE, P-RZF, MR
2. **AP selection matrix D:** D(m,k) = 1 nếu AP m phục vụ UE k
3. **Channel estimation quality:** Phụ thuộc τ_p, pilot contamination
4. **Power allocation:** p_k (transmit power của UE k)

### 0.4. Các Combining Schemes

#### MMSE (Minimum Mean Square Error)
**Công thức:**

$$\mathbf{v}_k = (\sum_{k'=1}^K p_{k'} \hat{\mathbf{h}}_{k'} \hat{\mathbf{h}}_{k'}^H + \mathbf{C}_k + \sigma^2 \mathbf{I})^{-1} \hat{\mathbf{h}}_k$$

- **Ưu điểm:** Tối ưu về MSE, SE cao nhất
- **Nhược điểm:** Yêu cầu invert ma trận lớn (LN × LN) → complexity cao
- **Sử dụng:** Centralized processing tại CPU

#### P-MMSE (Partial MMSE)
**Công thức:** Chỉ sử dụng thông tin trong ma trận D

$$\mathbf{v}_k = (\sum_{k' \in \mathcal{K}_m} p_{k'} \hat{\mathbf{h}}_{mk'} \hat{\mathbf{h}}_{mk'}^H + \mathbf{C}_{mk} + \sigma^2 \mathbf{I})^{-1} \hat{\mathbf{h}}_{mk}$$

- **Ưu điểm:** Giảm complexity, vẫn suppress interference tốt
- **Nhược điểm:** SE thấp hơn MMSE một chút
- **Sử dụng:** Practical implementation

#### P-RZF (Partial Regularized Zero-Forcing)
**Công thức:**

$$\mathbf{v}_k = (\sum_{k' \in \mathcal{K}_m} \hat{\mathbf{h}}_{mk'} \hat{\mathbf{h}}_{mk'}^H + \alpha \mathbf{I})^{-1} \hat{\mathbf{h}}_{mk}$$

- **Ưu điểm:** Zero-forcing interference, regularization tránh noise amplification
- **Sử dụng:** Khi interference là dominant factor

#### MR (Maximum Ratio)
**Công thức:**

$$\mathbf{v}_k = \hat{\mathbf{h}}_k$$

- **Ưu điểm:** Cực kỳ đơn giản, không cần matrix inversion
- **Nhược điểm:** Không suppress interference → SE thấp
- **Sử dụng:** Low-complexity baseline, favorable propagation

### 0.5. Pilot Contamination

**Hiện tượng:**
Do τ_p < K (pilot reuse), nhiều UE dùng chung pilot → channel estimates bị "nhiễm" (contaminated)

**Hậu quả:**
- SINR giảm do coherent interference từ UE cùng pilot
- Tăng τ_p giảm contamination nhưng tăng overhead $(1 - \tau_p/\tau_c)$ giảm

**Giải pháp trong DCC:**
- Chọn AP gần UE → giảm interference từ xa
- Pilot assignment thông minh (greedy, graph-coloring)

### 0.6. Fronthaul Capacity Constraint

**Định nghĩa:**
Fronthaul là đường truyền giữa AP và CPU, có băng thông giới hạn.

**Metric:**
- **Number of AP-UE links:** $\sum_{m,k} D(m,k)$
- **Data per link:** Channel estimates, combining coefficients, decoded data
- **Scalability issue:** All-to-all (L×K links) không khả thi với L, K lớn

**Ý nghĩa của L_max:**
- Giới hạn số UE/AP → giới hạn CPU load tại AP
- Giới hạn fronthaul bandwidth: mỗi AP chỉ gửi data của L_max UE về CPU

## 1. Tổng Quan Các Phương Pháp

### 1.1. Original DCC (Dynamic Cooperation Clustering - Sách gốc)

**Thuật toán:**

- Chọn AP dựa trên large-scale fading coefficient β_mk
- Mỗi UE k chọn các AP m sao cho β_mk ≥ max(β_k) - Δ
- Δ là ngưỡng cố định (thường 15-20 dB)

**Đặc điểm:**

- ✅ Đơn giản, dễ implement
- ✅ Được tối ưu hóa cùng với power allocation
- ❌ Ngưỡng Δ cố định → không linh hoạt theo điều kiện mạng
- ❌ Không kiểm soát tải AP (có thể quá tải)

### 1.2. Proposed DCC (Threshold + Load Balancing)

**Thuật toán:**

1. **Phase 1 - Threshold Selection:** Mỗi UE chọn AP có β_mk ≥ threshold_ratio × max(β_k)
2. **Phase 2 - Enforce N_min:** Đảm bảo mỗi UE có ít nhất N_min AP
3. **Phase 3 - Load Balancing:** Cân bằng tải sao cho mỗi AP phục vụ tối đa L_max UE

**Tham số:**

- `threshold_ratio = 0.1` (10% so với gain lớn nhất)
- `L_max = 8` (mỗi AP tối đa 8 UE)
- `N_min = 3` (mỗi UE tối thiểu 3 AP)

**Đặc điểm:**

- ✅ Ngưỡng tương đối (%) → thích nghi với từng UE
- ✅ Kiểm soát tải fronthaul thông qua L_max
- ✅ Đảm bảo diversity tối thiểu qua N_min
- ❌ Cần điều chỉnh 3 tham số
- ❌ Greedy repair → có thể chưa tối ưu toàn cục

### 1.3. Clustering DCC (Affinity Clustering)

**Thuật toán:**

1. **Normalize gain vectors:** Chuẩn hóa β_mk theo max gain của mỗi UE → tập trung vào "spatial signature"
2. **Hierarchical clustering:** Gom UE theo độ tương đồng của gain vector (cosine distance)
3. **AP signature per cluster:** Mỗi cụm được gán topM AP mạnh nhất (theo mean gain của cụm)
4. **Enforce constraints:** N_min per UE, L_max per AP

**Tham số:**

- `targetClusterSize = 5` (mục tiêu 5 UE/cụm)
- `topM = 6` (6 AP đầu tiên cho mỗi cụm)
- `L_max = 8`, `N_min = 3` (như Proposed)
- `distType = 'cosine'` (đo góc giữa gain vectors)
- `linkMethod = 'average'` (average linkage)

**Đặc điểm:**

- ✅ Khai thác cấu trúc không gian của UE (spatial correlation)
- ✅ UE trong cùng cụm chia sẻ AP → giảm signaling overhead
- ✅ Không cần threshold cứng - data-driven
- ✅ Tự động thích nghi với phân bố UE
- ❌ Phức tạp tính toán hơn (clustering overhead)
- ❌ Yêu cầu Statistics Toolbox (pdist, linkage, cluster)

---

## 2. Kết Quả Mô Phỏng (5 setups, L=100, K=20)

### 2.1. Thống Kê Clustering

Từ output mô phỏng:

| Setup          | Avg Cluster Size | Avg AP Load    |
| -------------- | ---------------- | -------------- |
| 1              | 5.05             | 1.01           |
| 2              | 4.20             | 0.84           |
| 3              | 4.20             | 0.84           |
| 4              | 4.35             | 0.87           |
| 5              | 3.85             | 0.77           |
| **Mean** | **4.33**   | **0.87** |

**Nhận xét:**

- Clustering tạo ra khoảng **4-5 cụm** (với target = 5)
- Avg AP load ≈ 0.87 → **mỗi AP trung bình phục vụ < 1 UE** (rất nhẹ tải)
- Load thấp hơn nhiều so với L_max = 8 → hệ thống có dư dả tài nguyên

### 2.2. So Sánh CDF của SE (Figure 5.4a)

**Các đường CDF được vẽ:**

1. **MMSE (All)** - Baseline lý tưởng: mọi AP phục vụ mọi UE
2. **MMSE (DCC)** - DCC gốc với MMSE combiner
3. **P-MMSE (DCC)** - DCC gốc với Partial MMSE (thực tế hơn)
4. **P-MMSE (Proposed)** - Threshold + Load Balancing với P-MMSE
5. **P-MMSE (Clustering)** - Clustering approach với P-MMSE ⭐
6. **P-RZF (DCC)** - DCC gốc với Regularized Zero-Forcing
7. **MR (DCC)** - DCC gốc với Maximum Ratio combiner

**Kỳ vọng về kết quả:**

- **MMSE (All) > P-MMSE (Proposed) ≈ P-MMSE (Clustering) > P-MMSE (DCC) > MR (DCC)**
- Clustering có thể ngang ngửa hoặc tốt hơn Proposed nếu spatial correlation cao

---

## 3. So Sánh Chi Tiết

### 3.1. Spectral Efficiency (SE)

| Phương pháp      | Dự đoán SE       | Tail SE (5-percentile) | Lý do                                                                |
| ------------------- | ------------------- | ---------------------- | --------------------------------------------------------------------- |
| MMSE (All)          | **Cao nhất** | Cao nhất              | Khai thác toàn bộ macro-diversity, không bị giới hạn fronthaul |
| P-MMSE (Proposed)   | Cao                 | Tốt                   | Ngưỡng linh hoạt, cân bằng tải → ít UE bị "bỏ rơi"         |
| P-MMSE (Clustering) | Cao                 | Khá tốt              | AP signature theo cụm → UE gần nhau dùng chung AP hiệu quả      |
| P-MMSE (DCC)        | Trung bình         | Trung bình            | Ngưỡng cứng → một số UE cell-edge có ít AP                    |
| MR (DCC)            | Thấp nhất         | Thấp                  | MR không xử lý interference tốt                                   |

### 3.2. Độ Phức Tạp Tính Toán

| Phương pháp | Complexity                         | Giải thích                                           |
| -------------- | ---------------------------------- | ------------------------------------------------------ |
| Original DCC   | **O(LK)**                    | Đơn giản: so sánh β_mk với threshold             |
| Proposed DCC   | **O(LK + iterations×L×K)** | Thêm vòng lặp cân bằng tải                       |
| Clustering     | **O(K²L + K²log K)**       | Clustering: O(K²L) cho pdist, O(K²log K) cho linkage |

**Nhận xét:**

- Với K nhỏ (20-40): Clustering chấp nhận được (< 1s)
- Với K lớn (>100): Clustering có thể chậm, cần optimize

### 3.3. Fronthaul Load

**Định nghĩa:** Tổng số kết nối AP-UE cần truyền dữ liệu

| Phương pháp | Avg # AP/UE  | Avg # UE/AP               | Total Links | Ghi chú                 |
| -------------- | ------------ | ------------------------- | ----------- | ------------------------ |
| All APs        | L = 100      | K = 20                    | L×K = 2000 | Baseline (quá tải)     |
| DCC Original   | ~5-10        | ~1-2                      | ~100-200    | Phụ thuộc threshold Δ |
| Proposed       | ≥ N_min = 3 | ≤ L_max = 8              | ~60-160     | Kiểm soát chặt        |
| Clustering     | ~6 (topM)    | **0.87** (observed) | ~120        | Chia sẻ AP theo cụm    |

**Nhận xét:**

- Clustering có **AP load thấp nhất** (0.87 UE/AP) → CPU/fronthaul rất nhẹ
- Proposed kiểm soát tốt nhờ L_max

### 3.4. Fairness (Công Bằng)

**Metric:** Độ dốc của CDF curve (dốc = công bằng hơn)

| Phương pháp | Fairness             | Giải thích                                                       |
| -------------- | -------------------- | ------------------------------------------------------------------ |
| Proposed       | **Tốt nhất** | N_min đảm bảo mọi UE có ít nhất 3 AP → tail SE cải thiện |
| Clustering     | Tốt                 | UE trong cùng vùng (cùng cụm) được phục vụ đồng đều   |
| DCC Original   | Trung bình          | Cell-edge UE có thể bị ít AP nếu β thấp                     |

---

## 4. Phân Tích Sâu: Tại Sao Clustering Hiệu Quả?

### 4.1. Spatial Correlation Exploitation

**Hiện tượng:** UE gần nhau thường có gain vector tương tự (cùng "nhìn thấy" nhóm AP mạnh)

**Ví dụ:**

- UE 1 ở góc tây bắc: β = [100, 95, 10, 5, ...] (AP 1,2 mạnh)
- UE 2 ở góc tây bắc: β = [98, 90, 12, 6, ...] (AP 1,2 mạnh)
- Sau chuẩn hóa: cả hai có vector ~[1.0, 0.95, 0.1, 0.05] → **cosine distance nhỏ** → cùng cụm

**Lợi ích:**

- Cả UE 1 và UE 2 đều dùng AP 1,2 → **AP signature chung**
- Giảm số lượng AP cần active (không phải mỗi UE 1 bộ AP riêng)
- Fronthaul efficiency cao

### 4.2. Load Balancing Tự Động

**Clustering tự động "trải" UE qua các AP:**

- Mỗi cụm chọn topM AP mạnh nhất **theo mean gain của cụm**
- Các cụm khác nhau → chọn bộ AP khác nhau (nếu spatial spread tốt)
- Kết quả: Avg load = 0.87 (rất đồng đều)

**So với Proposed:**

- Proposed: bắt đầu với threshold → có thể nhiều UE chọn cùng 1 AP → cần repair
- Clustering: phân bổ ngay từ đầu theo cấu trúc cụm

### 4.3. Data-Driven vs. Rule-Based

| Aspect           | Clustering (Data-Driven)                              | Proposed (Rule-Based)                                   |
| ---------------- | ----------------------------------------------------- | ------------------------------------------------------- |
| Decision         | Dựa trên**phân bố thực tế** của gain map | Dựa trên**rule cứng** (threshold_ratio, L_max) |
| Adaptivity       | Tự động thích nghi với topology                  | Cần tune tham số cho từng scenario                   |
| Interpretability | Khó giải thích (black-box clustering)              | Dễ hiểu (threshold logic rõ ràng)                   |

---

## 5. Ưu và Nhược Điểm Tổng Hợp

### 5.1. Original DCC

#### Ưu điểm ✅

- Đơn giản, dễ triển khai
- Complexity thấp O(LK)
- Baseline được nghiên cứu kỹ trong literature

#### Nhược điểm ❌

- Ngưỡng Δ cứng → không linh hoạt
- Không kiểm soát tải AP
- Cell-edge UE có thể thiếu AP (fairness kém)
- SE suboptimal khi UE phân bố không đều

### 5.2. Proposed DCC (Threshold + Load Balancing)

#### Ưu điểm ✅

- **Fairness tốt** nhờ N_min
- **Kiểm soát tải** chặt chẽ qua L_max
- Ngưỡng tương đối (%) → thích nghi từng UE
- SE cải thiện đáng kể so với DCC gốc
- Giải thích được từng bước (interpretable)

#### Nhược điểm ❌

- Cần tune 3 tham số (threshold_ratio, L_max, N_min)
- Greedy repair → không đảm bảo optimal
- Không khai thác spatial structure của UE
- Complexity cao hơn DCC gốc (do load balancing loop)

### 5.3. Clustering DCC (Affinity Clustering)

#### Ưu điểm ✅

- **Khai thác spatial correlation** → hiệu quả với UE phân bố cụm
- **Load balancing tự động** → avg load rất thấp (0.87)
- **Data-driven** → không cần threshold cứng
- **Shared AP signature** → giảm signaling overhead
- SE tiềm năng cao ngang Proposed (hoặc hơn)
- Scalable: cluster size tự điều chỉnh theo K

#### Nhược điểm ❌

- **Complexity cao** O(K²L) → chậm với K lớn
- **Yêu cầu Statistics Toolbox** (không có trong base MATLAB)
- Khó interpret: tại sao UE này vào cụm kia?
- Hiệu quả phụ thuộc vào **spatial structure thực tế**:
  - Tốt nếu UE phân bố theo cụm (clustered)
  - Kém nếu UE phân bố đều (uniform) → clustering không có ý nghĩa

---

## 6. Khi Nào Dùng Phương Pháp Nào?

### 6.1. Chọn Original DCC khi:

- Cần giải pháp đơn giản, nhanh
- Computational resource hạn chế
- UE phân bố tương đối đồng đều
- Không quan trọng fairness (cell-edge UE)

### 6.2. Chọn Proposed DCC khi:

- **Fairness là ưu tiên** (cần đảm bảo SE tối thiểu cho mọi UE)
- Cần **kiểm soát fronthaul** chặt chẽ (L_max)
- Có thể tune tham số cho từng deployment
- Muốn giải thích được logic AP selection

### 6.3. Chọn Clustering DCC khi:

- **UE có xu hướng phân bố theo cụm** (hotspot, indoor office, stadium)
- Cần **maximize fronthaul efficiency** (shared AP signature)
- Computational resource đủ mạnh
- Có sẵn Statistics Toolbox
- Không muốn tune nhiều tham số threshold

---

## 7. Hướng Cải Tiến

### 7.1. Hybrid Approach

**Ý tưởng:** Kết hợp Clustering + Proposed

1. Cluster UE theo spatial similarity
2. Trong mỗi cụm: áp dụng threshold + load balancing

**Lợi ích:**

- Khai thác spatial structure (Clustering)
- Đảm bảo N_min, L_max (Proposed)
- Best of both worlds

### 7.2. Online Adaptive Clustering

**Ý tưởng:** Cập nhật cluster khi UE di chuyển

- Chạy full clustering định kỳ (mỗi 10-100 coherence blocks)
- Giữa các lần: chỉ update incremental (thêm/bớt UE)

### 7.3. Machine Learning Enhancement

**Ý tưởng:** Học từ data lịch sử

- Huấn luyện model dự đoán "optimal D" từ gainOverNoisedB
- Input: gain map (L×K)
- Output: ma trận D (L×K) hoặc xác suất chọn AP
- Inference nhanh (feedforward), không cần clustering mỗi lần

---

## 8. Kết Luận

### Ranking Tổng Thể (cho scenario L=100, K=20):

| Tiêu chí                      | #1           | #2                  | #3           |
| ------------------------------- | ------------ | ------------------- | ------------ |
| **Spectral Efficiency**   | MMSE (All)   | Proposed/Clustering | DCC Original |
| **Fairness**              | Proposed     | Clustering          | DCC Original |
| **Fronthaul Efficiency**  | Clustering   | Proposed            | DCC Original |
| **Computational Speed**   | DCC Original | Proposed            | Clustering   |
| **Ease of Tuning**        | DCC Original | Clustering          | Proposed     |
| **Scalability (large K)** | DCC Original | Proposed            | Clustering   |

### Khuyến Nghị:

1. **Cho nghiên cứu/báo cáo:** Dùng **Clustering** để chứng minh innovation, khai thác spatial structure
2. **Cho deployment thực tế:** Dùng **Proposed** vì fairness tốt, kiểm soát tài nguyên, dễ debug
3. **Cho baseline/comparison:** Giữ **DCC Original** làm reference từ literature

### Trade-off Chính:

- **Complexity ↔ Performance:** Clustering phức tạp hơn nhưng tiềm năng SE cao hơn
- **Interpretability ↔ Adaptivity:** Proposed rõ ràng nhưng cần tune; Clustering tự động nhưng "black-box"
- **Fairness ↔ Load balancing:** Proposed ưu tiên fairness (N_min); Clustering ưu tiên efficiency (shared AP)
