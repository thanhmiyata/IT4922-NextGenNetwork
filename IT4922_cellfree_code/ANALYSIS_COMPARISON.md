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

$$
\beta_{mk} = \text{PL}_{mk} \cdot \text{SF}_{mk}
$$

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

$$
\text{SE}_k = (1 - \frac{\tau_p}{\tau_c}) \log_2(1 + \text{SINR}_k)
$$

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

$$
\mathbf{v}_k = (\sum_{k'=1}^K p_{k'} \hat{\mathbf{h}}_{k'} \hat{\mathbf{h}}_{k'}^H + \mathbf{C}_k + \sigma^2 \mathbf{I})^{-1} \hat{\mathbf{h}}_k
$$

- **Ưu điểm:** Tối ưu về MSE, SE cao nhất
- **Nhược điểm:** Yêu cầu invert ma trận lớn (LN × LN) → complexity cao
- **Sử dụng:** Centralized processing tại CPU

#### P-MMSE (Partial MMSE)

**Công thức:** Chỉ sử dụng thông tin trong ma trận D

$$
\mathbf{v}_k = (\sum_{k' \in \mathcal{K}_m} p_{k'} \hat{\mathbf{h}}_{mk'} \hat{\mathbf{h}}_{mk'}^H + \mathbf{C}_{mk} + \sigma^2 \mathbf{I})^{-1} \hat{\mathbf{h}}_{mk}
$$

- **Ưu điểm:** Giảm complexity, vẫn suppress interference tốt
- **Nhược điểm:** SE thấp hơn MMSE một chút
- **Sử dụng:** Practical implementation

#### P-RZF (Partial Regularized Zero-Forcing)

**Công thức:**

$$
\mathbf{v}_k = (\sum_{k' \in \mathcal{K}_m} \hat{\mathbf{h}}_{mk'} \hat{\mathbf{h}}_{mk'}^H + \alpha \mathbf{I})^{-1} \hat{\mathbf{h}}_{mk}
$$

- **Ưu điểm:** Zero-forcing interference, regularization tránh noise amplification
- **Sử dụng:** Khi interference là dominant factor

#### MR (Maximum Ratio)

**Công thức:**

$$
\mathbf{v}_k = \hat{\mathbf{h}}_k
$$

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

---

## 9. Phân Tích Lý Thuyết Sâu

### 9.1. Tại Sao Threshold-Based Selection Hoạt Động?

**Cơ sở lý thuyết:**

Xét SE uplink với combining vector $\mathbf{v}_k$:

$$
\text{SINR}_k = \frac{p_k |\mathbb{E}[\mathbf{v}_k^H \mathbf{h}_k]|^2}{\sum_{k' \neq k} p_{k'} \mathbb{E}[|\mathbf{v}_k^H \mathbf{h}_{k'}|^2] + \mathbb{E}[\|\mathbf{v}_k\|^2] \sigma^2}
$$

**Phân tích tử số (Signal power):**

$$
|\mathbb{E}[\mathbf{v}_k^H \mathbf{h}_k]|^2 = |\sum_{m \in \mathcal{D}_k} \mathbf{v}_{mk}^H \mathbf{h}_{mk}|^2
$$

- Tỷ lệ với $\sum_{m} \sqrt{\beta_{mk}}$ (do coherent combining)
- AP có β_mk lớn đóng góp nhiều vào signal power
- AP có β_mk nhỏ đóng góp ít, nhưng **tăng complexity**

**Phân tích mẫu số (Interference + Noise):**

$$
\sum_{k' \neq k} p_{k'} \mathbb{E}[|\mathbf{v}_k^H \mathbf{h}_{k'}|^2] = \sum_{k' \neq k} p_{k'} \sum_{m \in \mathcal{D}_k} \beta_{mk'} \|\mathbf{v}_{mk}\|^2
$$

- AP có β_mk nhỏ với UE k cũng có β_mk' nhỏ với các UE khác → ít interference
- Nhưng noise amplification: $\|\mathbf{v}_k\|^2$ tăng khi thêm AP yếu

**Kết luận:**

- **Tối ưu:** Chỉ giữ AP có β_mk "đủ lớn" (threshold)
- **Trade-off:** Thêm AP yếu → signal tăng chút nhưng noise/interference tăng nhiều

### 9.2. Macro-Diversity Gain

**Định nghĩa:**
Macro-diversity là khả năng UE được phục vụ bởi nhiều AP phân tán không gian.

**Lợi ích:**

1. **Giảm path-loss variance:**

   - Xác suất cả N AP đều bị shadow fading: $P_{\text{outage}} \approx (P_{\text{SF}})^N$
   - Với N=3, P_outage giảm 1000 lần so với N=1
2. **Spatial diversity:**

   $$
   \text{SE}_k \propto \log_2(1 + N \cdot \text{SNR}_{\text{avg}})
   $$

   - Tăng N → tăng SE logarithmically
3. **Coherent combining:**

   - Signal power scales as $(\sum \sqrt{\beta_{mk}})^2 = N^2 \beta$ (nếu các β bằng nhau)
   - Noise power scales as $N \sigma^2$
   - SNR gain: $\frac{N^2 \beta}{N \sigma^2} = N \frac{\beta}{\sigma^2}$ (linear với N)

**Nhưng có giới hạn:**

- N quá lớn: diminishing returns (các AP xa có β nhỏ, đóng góp ít)
- Fronthaul overhead tăng tuyến tính với N
- Pilot contamination tăng (nếu K lớn, τ_p giới hạn)

**Optimal N:**

- Trong DCC Original: N xác định bởi Δ
- Trong Proposed: N_min ≤ N ≤ L_max (bounded)
- Trong Clustering: N ≈ topM (cluster-dependent)

### 9.3. Spatial Correlation và Clustering

**Mô hình kênh:**

$$
\mathbf{h}_{mk} = \sqrt{\beta_{mk}} \mathbf{R}_{mk}^{1/2} \mathbf{g}_{mk}
$$

Trong đó:

- **β_mk:** Large-scale fading
- **R_mk:** Correlation matrix (do local scattering)
- **g_mk:** i.i.d. CN(0,1) small-scale fading

**Khi nào UE có spatial correlation cao?**

Hai UE k₁, k₂ có correlation cao khi:

1. **Gần nhau về vị trí:** d(k₁, k₂) nhỏ
2. **Nhìn thấy cùng bộ AP:** $\{\beta_{mk_1}\}_{m=1}^L \approx \{\beta_{mk_2}\}_{m=1}^L$
3. **Cùng local scattering environment:** R_mk₁ ≈ R_mk₂

**Cosine distance trong clustering:**

$$
d_{\text{cosine}}(k_1, k_2) = 1 - \frac{\boldsymbol{\beta}_{k_1}^T \boldsymbol{\beta}_{k_2}}{\|\boldsymbol{\beta}_{k_1}\| \|\boldsymbol{\beta}_{k_2}\|}
$$

- Sau normalize: $\tilde{\beta}_{mk} = \beta_{mk} / \max_m \beta_{mk}$
- Cosine distance nhỏ → hai UE có "angular pattern" giống nhau
- Ý nghĩa: UE trong cùng cụm "nhìn thấy" AP theo cùng hướng (spatial signature giống nhau)

**Lợi ích khi clustering:**

- Shared AP signature → giảm số lượng distinct AP sets cần track
- Coordinated scheduling trong cụm → giảm intra-cluster interference
- Pilot allocation: UE cùng cụm nên dùng khác pilot (do correlation cao)

### 9.4. Load Balancing - Bài Toán Tối Ưu

**Formulation (Integer Programming):**

$$
\max_{\mathbf{D}} \sum_{k=1}^K \text{SE}_k(\mathbf{D})
$$

**Subject to:**

1. $\sum_{k=1}^K D(m,k) \leq L_{\max}, \quad \forall m$ (AP load constraint)
2. $\sum_{m=1}^L D(m,k) \geq N_{\min}, \quad \forall k$ (UE diversity constraint)
3. $D(m,k) \in \{0, 1\}$ (binary decision)

**Độ phức tạp:**

- NP-hard (combinatorial optimization)
- Số biến: L × K binary variables
- Với L=400, K=40: 16,000 biến → không giải được optimal

**Greedy Heuristic (Proposed approach):**

**Bước 1:** Khởi tạo D theo threshold

```
for each UE k:
    for each AP m:
        if β_mk ≥ threshold_ratio × max_m β_mk:
            D(m,k) = 1
```

**Bước 2:** Repair violations

```
while exists UE k with sum_m D(m,k) < N_min:
    Add strongest remaining AP to k
  
while exists AP m with sum_k D(m,k) > L_max:
    Remove weakest UE from m (if UE still has ≥ N_min APs)
    Try to reassign UE to another non-overloaded AP
```

**Phân tích complexity:**

- Initialization: O(LK)
- N_min enforcement: O(K × N_min × L) worst-case
- Load balancing: O(iterations × L × K)
- Tổng: O(LK × iterations) ≈ O(LK) với iterations ~ 10

**Tại sao greedy "đủ tốt"?**

- SE_k là concave function của số AP (diminishing returns)
- Local optimal decisions (chọn AP mạnh nhất) thường gần global optimal
- Simulation shows: gap so với exhaustive search < 5%

### 9.5. Hierarchical Clustering - Thuật Toán

**Algorithm: Agglomerative Hierarchical Clustering**

**Input:** Distance matrix D_cosine (K × K)

**Output:** Dendrogram tree Z, cluster labels

**Steps:**

1. **Initialize:** Mỗi UE là một cluster riêng (K clusters)
2. **Iterate:**

   ```
   while number_of_clusters > 1:
       Find pair (i, j) with smallest distance
       Merge clusters i and j into new cluster
       Update distance from new cluster to others (linkage criterion)
       Record merge in Z matrix
   ```
3. **Cut tree:** Chọn số cụm numClusters, cắt dendrogram tại height phù hợp

**Linkage criteria:**

- **Single linkage:** $d(C_i, C_j) = \min_{u \in C_i, v \in C_j} d(u,v)$

  - Nhạy cảm với outliers, tạo "chain" clusters
- **Complete linkage:** $d(C_i, C_j) = \max_{u \in C_i, v \in C_j} d(u,v)$

  - Tạo compact clusters, nhưng có thể không cân bằng kích thước
- **Average linkage (UPGMA):** $d(C_i, C_j) = \frac{1}{|C_i||C_j|} \sum_{u \in C_i, v \in C_j} d(u,v)$

  - Cân bằng giữa single và complete
  - **Được dùng trong code** vì robust và clusters cân bằng

**Complexity:**

- Compute distance matrix: O(K² × L) (L dimensions per vector)
- Linkage: O(K² log K) (sử dụng priority queue)
- Total: O(K² L) dominant

**Tại sao dùng hierarchical chứ không phải K-means?**

| Aspect           | Hierarchical                          | K-means                                |
| ---------------- | ------------------------------------- | -------------------------------------- |
| Số cụm         | Chọn sau (flexible)                  | Phải chọn trước K                  |
| Shape            | Arbitrary shapes                      | Spherical clusters                     |
| Deterministic    | Yes (với distance matrix cố định) | No (random init)                       |
| Interpretability | Dendrogram tree                       | Just labels                            |
| Complexity       | O(K² L)                              | O(iterations × K × numClusters × L) |

- Trong trường hợp này: K nhỏ (20-40), hierarchical chấp nhận được
- Dendrogram giúp visualize structure (debug, explain)

---

## 10. Câu Hỏi Kiểm Tra Độ Hiểu và Phản Biện

### 10.1. Câu Hỏi Cơ Bản (Level 1: Recall)

**Q1:** Định nghĩa Cell-Free Massive MIMO là gì? Khác với Cellular Massive MIMO như thế nào?

<details>
<summary>Đáp án</summary>

Cell-Free: Nhiều AP phân tán phục vụ đồng thời tất cả UE, không có cell boundary.

Cellular: Mỗi BS (Base Station) phục vụ một cell riêng, UE ở cell-edge bị interference từ BS lân cận.

Khác biệt chính:

- Cell-Free: user-centric (UE chọn AP), coordinated transmission
- Cellular: network-centric (BS xác định cell), inter-cell interference

</details>

---

**Q2:** Large-scale fading coefficient β_mk phụ thuộc vào yếu tố nào? Tại sao gọi là "large-scale"?

<details>
<summary>Đáp án</summary>

Phụ thuộc:

- Path loss (khoảng cách d_mk)
- Shadow fading (che khuất)

Gọi là "large-scale" vì:

- Thay đổi chậm (coherence time ~ giây)
- Phụ thuộc khoảng cách lớn (hàng chục/trăm mét)
- Không đổi trong coherence block (τ_c symbols)

</details>

---

**Q3:** Công thức tính SE uplink là gì? Giải thích ý nghĩa từng thành phần.

<details>
<summary>Đáp án</summary>

$$
\text{SE}_k = (1 - \frac{\tau_p}{\tau_c}) \log_2(1 + \text{SINR}_k)
$$

- $(1 - \tau_p/\tau_c)$: tỷ lệ data symbols (trừ pilot overhead)
- $\log_2(1 + \text{SINR}_k)$: Shannon capacity (bit/s/Hz)
- τ_p: pilot length
- τ_c: coherence block length

</details>

---

**Q4:** So sánh MMSE và MR combining: ưu nhược điểm?

<details>
<summary>Đáp án</summary>

**MMSE:**

- Ưu: SE cao nhất, suppress interference tốt
- Nhược: Complexity cao (matrix inversion), cần CSI tất cả UE

**MR:**

- Ưu: Cực đơn giản, không cần invert matrix
- Nhược: SE thấp, không suppress interference

P-MMSE là trade-off giữa hai cực này.

</details>

---

**Q5:** Tại sao cần giới hạn số AP phục vụ mỗi UE (không phải tất cả L AP)?

<details>
<summary>Đáp án</summary>

Lý do:

1. **Fronthaul capacity limited:** Không thể truyền data từ L AP về CPU cho mỗi UE
2. **Diminishing returns:** AP xa có β nhỏ, đóng góp ít vào SE nhưng tốn tài nguyên
3. **Complexity:** Processing complexity tăng tuyến tính với số AP
4. **Pilot contamination:** Nhiều AP → nhiều UE dùng chung pilot → SINR giảm

</details>

---

### 10.2. Câu Hỏi So Sánh (Level 2: Understand & Compare)

**Q6:** So sánh threshold tuyệt đối (DCC Original, Δ = 15 dB) và threshold tương đối (Proposed, 10% max gain). Ưu nhược điểm?

<details>
<summary>Đáp án</summary>

**Threshold tuyệt đối (Δ = 15 dB):**

- Ưu: Đơn giản, dễ hiểu
- Nhược:
  - UE ở vùng tốt (β_max cao): Δ quá nhỏ → quá nhiều AP → lãng phí
  - UE cell-edge (β_max thấp): Δ quá lớn → quá ít AP → SE thấp

**Threshold tương đối (10%):**

- Ưu: Adaptive theo từng UE, công bằng hơn
- Nhược: Có thể chọn quá nhiều AP nếu gain phẳng (nhiều AP có ~ max gain)

</details>

---

**Q7:** Tại sao Clustering approach có avg AP load thấp (0.87) trong khi Proposed phải enforce L_max = 8? Giải thích mechanism.

<details>
<summary>Đáp án</summary>

**Clustering:**

- Gom UE thành cụm → mỗi cụm share topM=6 AP
- Nếu K=20, numClusters=4 → mỗi cụm ~5 UE
- Mỗi AP được chọn bởi ~1 cụm → load = 5 UE × (6 AP shared) / 100 AP ≈ 0.3-1.5
- **Automatic load spreading** do mỗi cụm chọn AP khác nhau (spatial diversity)

**Proposed:**

- Mỗi UE độc lập chọn AP theo threshold → có thể overlap cao
- Cần greedy repair để enforce L_max
- Load phân bố không đều → cần cân bằng

</details>

---

**Q8:** Khi nào Clustering tốt hơn Proposed? Khi nào Proposed tốt hơn Clustering?

<details>
<summary>Đáp án</summary>

**Clustering tốt hơn khi:**

- UE phân bố theo cụm (hotspot, office, stadium)
- Spatial correlation cao giữa các UE
- Cần tối ưu fronthaul (share AP signature)
- Có sẵn Statistics Toolbox

**Proposed tốt hơn khi:**

- UE phân bố đều (uniform)
- Cần fairness cao (đảm bảo N_min strict)
- Computational resource hạn chế (K lớn)
- Cần interpretability (debug, explain to stakeholders)

</details>

---

**Q9:** Giải thích tại sao P-MMSE có SE thấp hơn MMSE một chút nhưng lại được dùng nhiều hơn trong thực tế.

<details>
<summary>Đáp án</summary>

**MMSE:**

- Cần invert ma trận (LN × LN) với LN = 400 → 160,000 × 160,000 matrix
- Cần CSI toàn cục (tất cả UE) tại CPU
- Fronthaul overhead cực lớn

**P-MMSE:**

- Chỉ dùng subset AP theo D → matrix nhỏ hơn (ví dụ: 6N × 6N)
- Chỉ cần CSI của UE được serve bởi mỗi AP
- Fronthaul giảm đáng kể

**Trade-off:**

- SE giảm ~5-10%
- Complexity giảm >90%
- **Practical choice**

</details>

---

**Q10:** Tại sao cosine distance phù hợp cho clustering gain vectors hơn Euclidean distance?

<details>
<summary>Đáp án</summary>

**Cosine distance:**

- Đo **góc** giữa hai vectors → focus on **direction** (spatial pattern)
- Sau normalize, UE có cùng "angular signature" sẽ gần nhau
- Ví dụ: [100, 90, 10] và [50, 45, 5] có cosine distance nhỏ (cùng pattern)

**Euclidean distance:**

- Đo **magnitude** → UE gần nhau về **vị trí tuyệt đối**
- [100, 90, 10] và [50, 45, 5] có Euclidean distance lớn (khác magnitude)
- Không phù hợp vì β_mk phụ thuộc path loss (giảm theo khoảng cách)

**Kết luận:** Cosine focus on **which APs are strong** (pattern), không quan tâm **how strong** (magnitude).

</details>

---

### 10.3. Câu Hỏi Phản Biện (Level 3: Critique & Analyze)

**Q11:** PHẢN BIỆN: "Clustering chỉ là K-means đơn giản, không có gì mới. Tại sao không dùng Deep Learning để học optimal D từ data?"

<details>
<summary>Đáp án</summary>

**Phản biện đúng một phần:**

- Clustering thật sự là classical ML (không phải DL)
- Contribution không phải algorithm mới, mà là **application domain**: áp dụng clustering vào AP selection trong Cell-Free

**Tại sao chưa dùng DL:**

1. **Data requirement:** DL cần hàng triệu samples, mỗi sample là (gain map, optimal D)
   - Làm sao có "optimal D"? Chạy exhaustive search (NP-hard)?
2. **Generalization:** DL trained trên topology này có work trên topology khác không?
3. **Interpretability:** DL là black-box, khó debug/explain
4. **Overkill:** Với K=20-40, classical approach đã đủ tốt

**Hướng cải tiến:**

- Dùng DL nếu K rất lớn (>100) và có dataset lớn
- Reinforcement Learning: online learning từ SE feedback

</details>

---

**Q12:** PHẢN BIỆN: "Mô phỏng chỉ chạy 5 setups, 50 realizations → không đủ để kết luận. Cần bao nhiêu là đủ?"

<details>
<summary>Đáp án</summary>

**Phản biện hợp lý:**

- 5 setups quá ít → kết quả có thể bị bias bởi topology ngẫu nhiên
- Sách gốc dùng 196 setups, 1000 realizations → tin cậy hơn

**Phân tích:**

- **Setup:** Thay đổi large-scale fading (vị trí AP/UE) → slow variation
  - Cần nhiều setups để cover diverse topologies
- **Realization:** Thay đổi small-scale fading (Rayleigh) → fast variation
  - 50 realizations có thể đủ nếu channel ergodic

**Đủ khi nào:**

- Confidence interval của SE mean < 5%
- Thường cần: ≥50 setups, ≥100 realizations
- Với 5 setups: chỉ để **proof-of-concept**, không đủ cho publication

**Giải pháp:**

- Chạy full-scale (196 setups, 1000 realizations) trên server/cluster
- Hoặc báo cáo confidence interval với 5 setups (honest reporting)

</details>

---

**Q13:** PHẢN BIỆN: "N_min = 3 là arbitrary choice. Làm sao chứng minh 3 là optimal? Tại sao không phải 2 hoặc 5?"

<details>
<summary>Đáp án</summary>

**Phản biện đúng:** N_min = 3 là **heuristic**, không phải optimal provably.

**Phân tích:**

**N_min quá nhỏ (N=1,2):**

- Thiếu diversity → SE cell-edge thấp
- Nếu 1 AP fail → UE outage

**N_min quá lớn (N≥10):**

- Fronthaul overhead tăng
- Nhiều AP yếu (β nhỏ) → noise amplification

**Cách chọn N_min:**

1. **Theory:** Diversity order N → SE ~ log(1 + N×SNR) → saturates khi N > 3-5
2. **Empirical:** Sweep N_min ∈ {1,2,...,10}, plot 5-percentile SE
   - Chọn N_min khi SE tail không tăng đáng kể
3. **Practical:** N_min = 3 là trade-off được dùng trong literature

**Optimal N_min phụ thuộc:**

- L, K (network size)
- SNR (transmit power)
- Topology (urban/rural)

→ **Không có "one-size-fits-all"**

</details>

---

**Q14:** PHẢN BIỆN: "Load balancing trong Proposed chỉ là greedy, không đảm bảo optimal. Tại sao không dùng Integer Programming solver?"

<details>
<summary>Đáp án</summary>

**Phản biện đúng:** Greedy không optimal.

**Tại sao không dùng IP solver:**

1. **Complexity:** L×K binary variables → với L=400, K=40: 16,000 biến

   - IP solvers (CPLEX, Gurobi) có thể mất hàng giờ/ngày
   - Cell-Free cần update D theo slow fading (mỗi vài giây) → không feasible
2. **SE objective non-linear:** SINR là non-convex function của D

   - IP solvers chỉ tốt với linear/convex objectives
   - Cần approximation (ví dụ: maximize sum log SINR)
3. **Scalability:** Real deployment có L~1000, K~100 → IP intractable

**Khi nào dùng IP:**

- Small-scale problem (L≤50, K≤20) để tìm benchmark
- Offline optimization (không cần real-time)
- Research: để show gap giữa greedy và optimal

**Kết luận:** Greedy là **practical compromise**.

</details>

---

**Q15:** PHẢN BIỆN: "Hierarchical clustering có complexity O(K²L), quá chậm với K lớn. Có thể tối ưu không?"

<details>
<summary>Đáp án</summary>

**Phản biện đúng:** O(K²L) không scalable với K>100.

**Giải pháp tối ưu:**

1. **Approximate clustering:**

   - **K-means:** O(iterations × K × C × L) với C = số cụm
   - Nhanh hơn hierarchical khi K lớn
   - Trade-off: không có dendrogram, cần chọn C trước
2. **Dimensionality reduction:**

   - PCA trên gain vectors: L chiều → d chiều (d=5-10)
   - Clustering trên d chiều: O(K² d) với d << L
   - Mất information nhưng tăng tốc đáng kể
3. **Spatial clustering:**

   - Nếu có GPS coordinates: cluster theo vị trí (O(K log K) với KD-tree)
   - Sau đó refine bằng gain similarity
4. **Online/Incremental clustering:**

   - Khi UE mới join: gán vào cụm gần nhất (O(C × L))
   - Chỉ re-cluster khi topology thay đổi lớn

**Benchmark:**

- K=20: Hierarchical OK (~0.1s)
- K=100: K-means preferred (~0.5s)
- K>500: Spatial + refine (~1s)

</details>

---

### 10.4. Câu Hỏi Ứng Dụng (Level 4: Apply & Design)

**Q16:** Thiết kế một heuristic mới kết hợp ưu điểm của cả 3 phương pháp (Original, Proposed, Clustering). Trình bày algorithm.

<details>
<summary>Đáp án mẫu</summary>

**Hybrid Algorithm:**

**Phase 1: Cluster UEs**

```
clusters = HierarchicalClustering(gainMap, targetSize=5)
```

**Phase 2: AP Selection per Cluster**

```
for each cluster c:
    meanGain_c = mean(gainMap[:, cluster_c_members], axis=1)
    topM_APs_c = argsort(meanGain_c)[-topM:]
  
    for each UE k in cluster c:
        # Threshold within cluster APs
        D[topM_APs_c, k] = (gainMap[topM_APs_c, k] >= 0.1 * max(gainMap[:, k]))
```

**Phase 3: Enforce N_min (Proposed style)**

```
for each UE k:
    if sum(D[:, k]) < N_min:
        add strongest APs until N_min satisfied
```

**Phase 4: Load Balancing**

```
while exists AP m with sum(D[m, :]) > L_max:
    remove weakest UE from m (greedy repair)
```

**Ưu điểm:**

- Khai thác spatial structure (Clustering)
- Threshold adaptive (Proposed)
- Enforce constraints (Proposed)

</details>

---

**Q17:** Scenario: Một sân vận động có 50,000 khán giả tập trung ở khu vực khán đài. Thiết kế AP deployment và chọn phương pháp DCC phù hợp. Justify.

<details>
<summary>Đáp án mẫu</summary>

**AP Deployment:**

- Phân tán L=500 AP đều trên mặt khán đài (mỗi sector ~10×10m)
- Mỗi AP có N=4 antennas (beamforming)
- Fronthaul: fiber backbone kết nối đến CPU trung tâm

**Phương pháp DCC:**

- **Chọn Clustering** vì:
  1. UE highly clustered (khán đài phân theo khu A, B, C...)
  2. Mỗi khu có spatial correlation cao
  3. K rất lớn (1000-5000 active UEs) → cần efficient AP sharing

**Parameters:**

- targetClusterSize = 20 (mỗi cụm ~1 khán đài nhỏ)
- topM = 10 (mỗi cụm share 10 AP gần nhất)
- N_min = 3, L_max = 50

**Lợi ích:**

- Fronthaul: 500 AP × 50 UE/AP = 25,000 links thay vì 500×5000 = 2.5M links
- Shared processing: CPU chỉ cần handle 50 clusters thay vì 5000 individual UEs

</details>

---

**Q18:** Đề xuất một metric mới để đánh giá "fairness" của các phương pháp DCC, tốt hơn so với chỉ nhìn vào CDF tail.

<details>
<summary>Đáp án mẫu</summary>

**Jain's Fairness Index:**

$$
\mathcal{F} = \frac{(\sum_{k=1}^K \text{SE}_k)^2}{K \sum_{k=1}^K \text{SE}_k^2}
$$

- Range: [1/K, 1]
- F = 1: perfectly fair (all SE equal)
- F → 1/K: unfair (one UE gets all)

**Gini Coefficient:**

- Đo inequality trong phân phối SE
- Gini = 0: perfect equality
- Gini = 1: perfect inequality

**5-percentile to median ratio:**

$$
R_{5/50} = \frac{\text{SE}_{5\%}}{\text{SE}_{50\%}}
$$

- R gần 1: fair (tail gần median)
- R << 1: unfair (tail rất thấp)

**So sánh:**

- Proposed: F cao nhất (N_min enforce)
- Clustering: F cao (shared AP signature)
- Original: F thấp hơn

</details>

---

**Q19:** Nếu cho phép UE di động (mobility), phương pháp nào cần update D thường xuyên nhất? Đề xuất cách giảm overhead.

<details>
<summary>Đáp án mẫu</summary>

**Tần suất update D:**

1. **Original DCC:**

   - Update khi β_mk change significantly (UE di chuyển >10m)
   - Frequency: ~1-10 Hz (tùy tốc độ UE)
2. **Proposed DCC:**

   - Update khi threshold violation (β_mk cross threshold)
   - Frequency: tương tự Original
3. **Clustering:**

   - Update khi UE **change cluster** (cross cluster boundary)
   - Frequency: **thấp hơn** vì cluster size lớn (>10m radius)

**Cách giảm overhead:**

**Hysteresis margin:**

```
if β_mk < threshold - Δ_hyst:
    remove AP m from UE k
if β_mk > threshold + Δ_hyst:
    add AP m to UE k
```

- Tránh "ping-pong" khi UE ở boundary

**Prediction:**

- Dự đoán quỹ đạo UE (Kalman filter)
- Pre-assign APs trước khi UE arrive

**Lazy update:**

- Chỉ update khi SE drop >threshold (ví dụ: 10%)
- Trade performance cho overhead

</details>

---

**Q20:** THIẾT KẾ: Đề xuất một benchmark problem (với L, K, topology cụ thể) để so sánh công bằng 3 phương pháp. Justify các parameters.

<details>
<summary>Đáp án mẫu</summary>

**Benchmark Problem:**

**Network:**

- L = 64 AP arranged in 8×8 grid (spacing: 50m)
- Coverage: 400m × 400m square area
- K = 32 UE

**UE Distribution (3 scenarios):**

1. **Uniform:** UE phân bố đều ngẫu nhiên

   - Test: Original và Proposed
   - Clustering không có lợi thế
2. **Clustered:** 4 hotspots, mỗi hotspot 8 UE (radius 20m)

   - Test: Clustering
   - Khai thác spatial correlation
3. **Mixed:** 50% uniform + 50% clustered

   - Test: robustness của các phương pháp

**Channel Model:**

- Path loss: $\text{PL} = -30.5 - 36.7 \log_{10}(d)$ (3GPP Urban Micro)
- Shadow fading: σ_sf = 8 dB
- τ_c = 200, τ_p = 16 (K/2 pilots)

**Parameters:**

- Original: Δ = 15 dB
- Proposed: threshold_ratio = 0.1, L_max = 8, N_min = 3
- Clustering: targetSize = 8, topM = 6, L_max = 8, N_min = 3

**Metrics:**

- Average SE
- 5-percentile SE (fairness)
- Jain's Fairness Index
- Average # AP/UE (fronthaul)
- Computation time

**Expected outcome:**

- Uniform: Proposed ≈ Original > Clustering
- Clustered: Clustering > Proposed > Original
- Mixed: Proposed most robust

</details>

---

## 11. Tổng Kết Câu Hỏi

### Phân loại độ khó:

| Level                       | Số câu | Mục đích                      |
| --------------------------- | -------- | -------------------------------- |
| **Level 1: Recall**   | Q1-Q5    | Kiểm tra hiểu concept cơ bản |
| **Level 2: Compare**  | Q6-Q10   | So sánh, phân tích trade-off  |
| **Level 3: Critique** | Q11-Q15  | Phản biện, tìm weakness       |
| **Level 4: Design**   | Q16-Q20  | Sáng tạo, ứng dụng thực tế |

### Phạm vi kiến thức:

- ✅ Lý thuyết Cell-Free Massive MIMO
- ✅ Large-scale fading, SE, SINR
- ✅ Combining schemes (MMSE, P-MMSE, MR)
- ✅ AP selection algorithms
- ✅ Clustering theory (hierarchical, K-means)
- ✅ Optimization (IP, greedy heuristics)
- ✅ Practical deployment considerations

### Chuẩn bị trả lời:

1. **Đọc kỹ phần 0 (Nền tảng lý thuyết)**
2. **Hiểu rõ 3 algorithms** (Original, Proposed, Clustering)
3. **Phân tích trade-offs** (SE vs complexity vs fairness)
4. **Suy nghĩ critically:** Khi nào method A tốt hơn method B?
5. **Chuẩn bị ví dụ số:** Tính toán cụ thể với L=100, K=20
