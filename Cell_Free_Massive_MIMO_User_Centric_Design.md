# Cell-Free Massive MIMO: User-Centric Design
## Bài tập lớn môn "Mạng thế hệ sau"

---

# PHẦN 1: KIẾN THỨC NỀN TẢNG

## 1.1 Khái niệm cơ bản về MIMO

### MIMO là gì? Tại sao cần MIMO?

**MIMO (Multiple-Input Multiple-Output)** là công nghệ truyền thông không dây sử dụng nhiều anten phát và nhiều anten thu để cải thiện hiệu suất hệ thống.

**Tại sao cần MIMO:**
- **Tăng dung lượng kênh (Capacity):** Theo lý thuyết Shannon, dung lượng tăng tuyến tính với số lượng anten
- **Cải thiện độ tin cậy (Diversity):** Giảm ảnh hưởng của fading
- **Định hướng tín hiệu (Beamforming):** Tập trung năng lượng về phía người dùng

**Công thức dung lượng kênh MIMO:**
$$C = \log_2 \det\left(\mathbf{I}_N + \frac{P}{N_0 M}\mathbf{H}\mathbf{H}^H\right) \text{ [bit/s/Hz]}$$

Trong đó:
- $\mathbf{H}$: Ma trận kênh kích thước $N \times M$
- $M$: Số anten phát
- $N$: Số anten thu
- $P$: Tổng công suất phát
- $N_0$: Công suất nhiễu

---

### Massive MIMO là gì?

**Massive MIMO** là hệ thống MIMO với số lượng anten rất lớn (thường ≥ 64 anten) tại trạm gốc (Base Station), phục vụ đồng thời nhiều người dùng.

| Đặc điểm | MIMO truyền thống | Massive MIMO |
|----------|-------------------|--------------|
| Số anten BS | 2-8 | 64-256+ |
| Số UE đồng thời | 1-4 | 10-100+ |
| Độ phức tạp | Thấp | Cao |
| Hiệu suất phổ | Trung bình | Rất cao |
| Channel hardening | Không | Có |

**Ưu điểm của Massive MIMO:**
1. **Channel Hardening:** Khi $M \to \infty$, kênh trở nên xác định (deterministic)
   $$\lim_{M \to \infty} \frac{\|\mathbf{h}_k\|^2}{M} = \beta_k$$

2. **Favorable Propagation:** Các kênh người dùng trở nên trực giao
   $$\frac{\mathbf{h}_k^H \mathbf{h}_l}{M} \to 0, \quad \forall k \neq l$$

---

### Cellular Massive MIMO vs Cell-Free Massive MIMO

| Đặc điểm | Cellular Massive MIMO | Cell-Free Massive MIMO |
|----------|----------------------|------------------------|
| Kiến trúc | Tập trung (centralized) | Phân tán (distributed) |
| Vị trí anten | Co-located tại BS | Phân tán nhiều AP |
| Cell boundary | Có | Không |
| Inter-cell interference | Cao | Thấp |
| Path loss đến user xa | Cao | Thấp (nhiều AP gần) |
| Triển khai | Đơn giản | Phức tạp hơn |
| Macro-diversity | Không | Có |

```
Cellular Massive MIMO:          Cell-Free Massive MIMO:
      [BS với M anten]           AP1  AP2  AP3  AP4
            ↓                     ↓    ↓    ↓    ↓
        /   |   \               ━━━━━━━━━━━━━━━━━━
       UE1  UE2  UE3          UE1  UE2  UE3  UE4  UE5
       (trong 1 cell)            (không có cell boundary)
                                       ↓
                                    [CPU]
```

---

## 1.2 Kiến trúc Cell-Free Massive MIMO

### Access Point (AP) và vai trò

**Access Point (AP)** là các điểm truy cập nhỏ, mỗi AP có $N$ anten (thường 1-8 anten), được phân bố khắp vùng phủ sóng.

**Vai trò của AP:**
- Phát/thu tín hiệu với người dùng
- Thực hiện xử lý tín hiệu cục bộ (local processing)
- Ước lượng kênh cục bộ

**Số lượng AP điển hình:** $L = 100 - 400$ APs, tổng số anten $M = L \times N$

---

### Central Processing Unit (CPU) và Fronthaul

**CPU (Central Processing Unit):** Bộ xử lý trung tâm điều phối toàn bộ hệ thống.

**Fronthaul:** Liên kết giữa các AP và CPU

**Các loại fronthaul:**
- **Capacity-unlimited fronthaul:** Lý tưởng, không giới hạn băng thông
- **Capacity-limited fronthaul:** Thực tế, có giới hạn băng thông

```
                    ┌─────────────────────┐
                    │         CPU         │
                    │  (Central Processing│
                    │       Unit)         │
                    └────────┬────────────┘
                             │ Fronthaul
            ┌────────┬───────┼───────┬────────┐
            ↓        ↓       ↓       ↓        ↓
          [AP1]    [AP2]   [AP3]   [AP4]    [APL]
            ↓        ↓       ↓       ↓        ↓
          UE1,UE3  UE2,UE4  UE1,UE2  UE3    UE2,UEK
```

---

### Mô hình kênh truyền (Channel Model)

Kênh từ AP $l$ (với $N$ anten) đến UE $k$:

$$\mathbf{g}_{lk} = \sqrt{\beta_{lk}} \mathbf{h}_{lk}$$

Trong đó:
- $\mathbf{g}_{lk} \in \mathbb{C}^N$: Kênh tổng hợp
- $\beta_{lk}$: Large-scale fading coefficient (hệ số suy hao quy mô lớn)
- $\mathbf{h}_{lk} \sim \mathcal{CN}(\mathbf{0}, \mathbf{I}_N)$: Small-scale fading

---

### Large-scale Fading Coefficient ($\beta_{lk}$)

$$\beta_{lk} = \text{PL}_{lk} \cdot 10^{\frac{\sigma_{sh} z_{lk}}{10}}$$

Trong đó:
- $\text{PL}_{lk}$: Path loss (suy hao đường truyền)
- $\sigma_{sh}$: Shadow fading standard deviation (thường 4-8 dB)
- $z_{lk} \sim \mathcal{N}(0,1)$: Shadow fading random variable

**Mô hình Path Loss (3GPP Urban Microcell):**
$$\text{PL}_{lk} [dB] = -30.5 - 36.7 \log_{10}\left(\frac{d_{lk}}{1m}\right)$$

**Đặc điểm:**
- Thay đổi chậm theo thời gian
- Phụ thuộc vào khoảng cách và môi trường
- Giống nhau cho các anten trong cùng AP

---

### Small-scale Fading

**Small-scale fading** ($\mathbf{h}_{lk}$) mô tả sự thay đổi nhanh của kênh do đa đường (multipath).

**Phân bố Rayleigh:** $\mathbf{h}_{lk} \sim \mathcal{CN}(\mathbf{0}, \mathbf{I}_N)$

**Coherence Block:** Khối tài nguyên trong đó kênh coi như không đổi
$$\tau_c = B_c \times T_c$$

Trong đó:
- $B_c$: Coherence bandwidth
- $T_c$: Coherence time

---

## 1.3 User-Centric Design

### Network-centric vs User-centric approach

| Đặc điểm | Network-centric | User-centric |
|----------|-----------------|--------------|
| Phục vụ | Tất cả AP phục vụ mọi UE | Mỗi UE được tập con AP phục vụ |
| Xử lý tín hiệu | Tập trung tại CPU | Phân tán + kết hợp |
| Fronthaul load | Rất cao | Giảm đáng kể |
| Độ phức tạp tính toán | $O(LK)$ mỗi AP | $O(|\mathcal{M}_k|)$ mỗi UE |
| Scalability | Kém | Tốt |

---

### AP Clustering/AP Selection

**Định nghĩa:** Mỗi UE $k$ được phục vụ bởi một tập con AP $\mathcal{M}_k \subseteq \{1, ..., L\}$

**Các phương pháp AP selection:**

1. **Large-scale fading based:**
   $$\mathcal{M}_k = \{l : \beta_{lk} \geq \beta_{th}\}$$

2. **K-nearest APs:**
   $$\mathcal{M}_k = \text{argmax}_{|\mathcal{S}|=K_{max}} \sum_{l \in \mathcal{S}} \beta_{lk}$$

3. **Received power based:**
   $$\mathcal{M}_k = \{l : P_{lk}^{rx} > P_{th}\}$$

---

### Scalability trong Cell-Free MIMO

**Vấn đề scalability:** Khi $L$ và $K$ lớn:
- CPU phải xử lý $L \times K$ kênh
- Fronthaul tải $O(LK)$ dữ liệu
- Độ phức tạp tính toán tăng theo $K^3$ (MMSE processing)

**Giải pháp User-centric:**
- Mỗi AP chỉ cần biết kênh của UE trong cluster của nó
- Tổng số kênh cần xử lý: $\sum_{k=1}^K |\mathcal{M}_k| \ll L \times K$

---

## 1.4 Xử lý tín hiệu

### Channel Estimation (Ước lượng kênh)

**Pilot signal:** Tín hiệu huấn luyện được biết trước để ước lượng kênh

**Tín hiệu nhận tại AP $l$ trong pha uplink pilot:**
$$\mathbf{Y}_l^p = \sqrt{\tau_p \rho_p} \sum_{k=1}^{K} \mathbf{g}_{lk} \boldsymbol{\phi}_k^H + \mathbf{N}_l$$

Trong đó:
- $\tau_p$: Độ dài pilot (số sample)
- $\rho_p$: Công suất pilot
- $\boldsymbol{\phi}_k \in \mathbb{C}^{\tau_p}$: Pilot sequence của UE $k$

**MMSE Channel Estimation:**
$$\hat{\mathbf{g}}_{lk} = \frac{\sqrt{\tau_p \rho_p} \beta_{lk}}{\tau_p \rho_p \sum_{k' \in \mathcal{P}_k} \beta_{lk'} + 1} \mathbf{Y}_l^p \boldsymbol{\phi}_k$$

---

### Pilot Contamination

**Vấn đề:** Số pilot hữu hạn ($\tau_p < K$), nhiều UE phải dùng chung pilot

$$\mathcal{P}_k = \{k' : \boldsymbol{\phi}_{k'}^H \boldsymbol{\phi}_k \neq 0\}$$

**Hậu quả:** Ước lượng kênh bị nhiễu từ các UE dùng chung pilot
$$\hat{\mathbf{g}}_{lk} \approx c_{lk}\left(\mathbf{g}_{lk} + \sum_{k' \in \mathcal{P}_k, k' \neq k} \mathbf{g}_{lk'}\right)$$

---

### Precoding/Beamforming

**Downlink:** CPU/AP tạo tín hiệu phát để tối ưu SINR tại UE

**1. Conjugate Beamforming (CB) / Maximum Ratio Transmission (MRT):**
$$\mathbf{w}_{lk} = \hat{\mathbf{g}}_{lk}^*$$

- Đơn giản, chỉ cần CSI cục bộ
- Hiệu suất thấp khi nhiễu cao

**2. Local MMSE Precoding:**
$$\mathbf{w}_{lk} = \left(\sum_{k'=1}^{K} \hat{\mathbf{g}}_{lk'}\hat{\mathbf{g}}_{lk'}^H + \sigma^2 \mathbf{I}\right)^{-1} \hat{\mathbf{g}}_{lk}$$

- Triệt nhiễu tốt hơn
- Yêu cầu tính toán cao hơn

---

### Combining Techniques (Uplink)

**1. Maximum Ratio (MR) Combining:**
$$\mathbf{v}_{lk} = \hat{\mathbf{g}}_{lk}$$

- Tối đa SNR
- Không triệt nhiễu

**2. MMSE Combining:**
$$\mathbf{v}_{lk} = \left(\sum_{k'=1}^{K} \hat{\mathbf{g}}_{lk'}\hat{\mathbf{g}}_{lk'}^H + \sigma^2 \mathbf{I}\right)^{-1} \hat{\mathbf{g}}_{lk}$$

- Cân bằng giữa tối đa tín hiệu mong muốn và triệt nhiễu

---

## 1.5 Các chỉ số hiệu suất

### Spectral Efficiency (SE)

**Hiệu suất phổ** đo lường số bit có thể truyền trên mỗi Hz băng thông:
$$\text{SE}_k = \frac{\tau_c - \tau_p}{\tau_c} \log_2(1 + \text{SINR}_k) \quad \text{[bit/s/Hz]}$$

---

### SINR (Signal-to-Interference-plus-Noise Ratio)

$$\text{SINR}_k = \frac{|\text{Desired signal}|^2}{|\text{Interference}|^2 + |\text{Noise}|^2}$$

---

### Uplink SE Formula (Use-and-then-Forget bound)

**Tín hiệu uplink nhận tại CPU sau combining:**
$$\hat{s}_k = \sum_{l=1}^{L} \mathbf{v}_{lk}^H \mathbf{y}_l^{ul}$$

**SINR uplink (Use-and-then-Forget bound):**
$$\text{SINR}_k^{ul} = \frac{\rho_u \left|\sum_{l=1}^{L} \mathbb{E}\{\mathbf{v}_{lk}^H \mathbf{g}_{lk}\}\right|^2}{\sum_{k'=1}^{K} \rho_u \mathbb{E}\{|\sum_{l=1}^{L} \mathbf{v}_{lk}^H \mathbf{g}_{lk'}|^2\} - \rho_u \left|\sum_{l=1}^{L} \mathbb{E}\{\mathbf{v}_{lk}^H \mathbf{g}_{lk}\}\right|^2 + \sum_{l=1}^{L}\mathbb{E}\{\|\mathbf{v}_{lk}\|^2\}}$$

**Với MR combining, closed-form:**
$$\text{SINR}_k^{ul,MR} = \frac{\rho_u \left(\sum_{l \in \mathcal{M}_k} \gamma_{lk}\right)^2}{\sum_{k'=1}^{K} \rho_u \sum_{l \in \mathcal{M}_k} \gamma_{lk}\beta_{lk'} + \sum_{l \in \mathcal{M}_k} \gamma_{lk}}$$

Trong đó $\gamma_{lk} = \frac{\tau_p \rho_p \beta_{lk}^2}{\tau_p \rho_p \sum_{k' \in \mathcal{P}_k}\beta_{lk'} + 1}$

---

### Downlink SE Formula

**Tín hiệu nhận tại UE $k$:**
$$y_k^{dl} = \sum_{l=1}^{L} \mathbf{g}_{lk}^T \sum_{k'=1}^{K} \sqrt{\eta_{lk'}} \mathbf{w}_{lk'} s_{k'} + n_k$$

**SINR downlink với CB:**
$$\text{SINR}_k^{dl,CB} = \frac{\left(\sum_{l \in \mathcal{M}_k} \sqrt{\eta_{lk}} \gamma_{lk}\right)^2}{\sum_{k'=1}^{K}\sum_{l \in \mathcal{M}_{k'}} \eta_{lk'} \gamma_{lk'}\beta_{lk} + 1}$$

Trong đó $\eta_{lk}$ là power control coefficient.

---

### Fairness Metrics

**1. Max-Min Fairness:**
$$\max_{\boldsymbol{\eta}} \min_{k} \text{SE}_k$$
Tối đa SE của user tệ nhất.

**2. Proportional Fairness:**
$$\max_{\boldsymbol{\eta}} \sum_{k=1}^{K} \log(\text{SE}_k)$$
Cân bằng giữa tổng throughput và fairness.

**3. Sum SE (không fair):**
$$\max_{\boldsymbol{\eta}} \sum_{k=1}^{K} \text{SE}_k$$

**4. Jain's Fairness Index:**
$$\mathcal{J} = \frac{\left(\sum_{k=1}^K \text{SE}_k\right)^2}{K \sum_{k=1}^K \text{SE}_k^2}$$
Giá trị từ $1/K$ (không fair) đến $1$ (hoàn toàn fair).

---

## 1.6 Kỹ thuật tối ưu

### Power Control (Điều khiển công suất)

**Mục tiêu:** Phân bổ công suất $\eta_{lk}$ sao cho tối ưu fairness hoặc SE

**Ràng buộc công suất:**
- Per-AP: $\sum_{k=1}^{K} \eta_{lk} \mathbb{E}\{\|\mathbf{w}_{lk}\|^2\} \leq P_{max}$
- Per-UE: $\sum_{l=1}^{L} \eta_{lk} \mathbb{E}\{\|\mathbf{w}_{lk}\|^2\} \leq P_{max}^{(k)}$

**Thuật toán phổ biến:**
- Bisection search cho max-min fairness
- Sequential convex approximation
- Geometric programming

---

### AP Selection Algorithms

**1. Threshold-based:**
```
Input: β_lk, threshold τ
For each UE k:
  M_k = {l : β_lk ≥ τ}
```

**2. Fixed-size clustering:**
```
Input: β_lk, cluster size N_max
For each UE k:
  Sort APs by β_lk descending
  M_k = top N_max APs
```

**3. Greedy SE-maximizing:**
```
For each UE k:
  M_k = {}
  While |M_k| < N_max and SE improves:
    l* = argmax SE(M_k ∪ {l})
    M_k = M_k ∪ {l*}
```

---

### Load Balancing

**Vấn đề:** Một số AP có thể bị quá tải (phục vụ quá nhiều UE)

**Ràng buộc load:**
$$\sum_{k=1}^{K} \mathbb{1}_{l \in \mathcal{M}_k} \leq L_{max}, \quad \forall l$$

**Thuật toán cân bằng tải:**
```
While có AP bị quá tải:
  l = AP quá tải nhất
  k = UE với β_lk nhỏ nhất trong M_l
  Remove l from M_k
  l' = AP tốt nhất chưa quá tải cho UE k
  Add l' to M_k
```

---

# PHẦN 2: KẾ HOẠCH CẢI THIỆN CODE

## 2.1 Tổng quan chiến lược cải tiến

### Mục tiêu cải tiến
- **Cải thiện fairness:** Tăng 95%-likely SE (SE của UE yếu nhất)
- **Giảm fronthaul load:** Giảm cluster size trung bình
- **Load balancing:** Phân bổ đều UE giữa các AP

### Phương pháp đề xuất
**Threshold-based AP Selection với Load Balancing** - kết hợp hai ý tưởng:
1. Chọn AP dựa trên ngưỡng $\beta$ (đảm bảo chất lượng kênh)
2. Giới hạn số UE mỗi AP phục vụ (cân bằng tải)

---

## 2.2 File code cần can thiệp

### Sơ đồ cấu trúc code

```
cell-free-book/code/
│
├── 📁 FUNCTIONS (Cần tạo mới/sửa đổi)
│   ├── generateSetup.m           ★★★ CẦN SỬA - Thuật toán DCC
│   └── functionGenerateDCC_improved.m  ★★★ TẠO MỚI
│
├── 📁 SCRIPTS MÔ PHỎNG (Cần sửa để so sánh)
│   ├── section5_figure4a_6a.m    ★★ Uplink SE - CHÍNH
│   ├── section5_figure12a_12b... ★ Fronthaul load
│   └── section7_figure1a_1b.m    ★ Power control (optional)
│
└── 📁 HELPER FUNCTIONS (Không cần sửa)
    ├── functionChannelEstimates.m
    ├── functionComputeSE_uplink.m
    └── functionComputeSE_downlink.m
```

---

## 2.3 Chi tiết can thiệp vào `generateSetup.m`

### Vị trí file
```
cell-free-book/code/generateSetup.m
```

### Đoạn code hiện tại cần thay thế (Dòng 231-243)

```matlab
%% CODE HIỆN TẠI - Pilot-based AP Selection
%Each AP serves the UE with the strongest channel condition on each of
%the pilots in the cell-free setup
for l = 1:L
    for t = 1:tau_p
        pilotUEs = find(t==pilotIndex(:,n));
        [~,UEindex] = max(gainOverNoisedB(l,pilotUEs,n));
        D(l,pilotUEs(UEindex),n) = 1;
    end
end
```

### Phân tích thuật toán hiện tại

**Logic:**
- Với mỗi AP $l$, duyệt qua từng pilot $t$
- Trong các UE dùng pilot $t$, chọn UE có $\beta_{lk}$ lớn nhất
- AP $l$ phục vụ UE đó (đặt $D(l,k) = 1$)

**Hạn chế:**
1. Không có ngưỡng loại bỏ kênh yếu
2. Không kiểm soát số UE mỗi AP phục vụ
3. Phụ thuộc vào pilot assignment

---

## 2.4 Thuật toán đề xuất thay thế

### Function mới: `functionGenerateDCC_improved.m`

```matlab
function D_new = functionGenerateDCC_improved(gainOverNoisedB, L, K, threshold_ratio, L_max, N_min)
%functionGenerateDCC_improved - Threshold-based AP Selection with Load Balancing
%
% Đề xuất cải tiến cho bài tập lớn môn Mạng thế hệ sau
% Kết hợp threshold-based selection với load balancing
%
% INPUT:
%   gainOverNoisedB = Ma trận [L x K] hệ số kênh (dB)
%   L               = Số lượng AP
%   K               = Số lượng UE
%   threshold_ratio = Ngưỡng (% so với max β của mỗi UE), VD: 0.1 = 10%
%   L_max           = Số UE tối đa mỗi AP phục vụ
%   N_min           = Số AP tối thiểu cho mỗi UE
%
% OUTPUT:
%   D_new = Ma trận DCC [L x K], D_new(l,k)=1 nếu AP l phục vụ UE k

    % Khởi tạo
    D_new = zeros(L, K);
    gainOverNoise = db2pow(gainOverNoisedB);
    
    %% PHASE 1: Threshold-based Selection
    for k = 1:K
        % Tìm max β cho UE k
        max_beta_k = max(gainOverNoise(:, k));
        % Thiết lập ngưỡng adaptive cho UE k
        threshold_k = threshold_ratio * max_beta_k;
        % Chọn các AP có β >= ngưỡng
        serving_APs = find(gainOverNoise(:, k) >= threshold_k);
        D_new(serving_APs, k) = 1;
    end
    
    %% PHASE 2: Ensure Minimum Connectivity
    for k = 1:K
        num_serving = sum(D_new(:, k));
        if num_serving < N_min
            % Tìm các AP chưa phục vụ, sắp xếp theo β giảm dần
            non_serving = find(D_new(:, k) == 0);
            [~, sorted_idx] = sort(gainOverNoise(non_serving, k), 'descend');
            
            % Thêm AP cho đến khi đủ N_min
            add_count = min(N_min - num_serving, length(non_serving));
            for i = 1:add_count
                l_add = non_serving(sorted_idx(i));
                D_new(l_add, k) = 1;
            end
        end
    end
    
    %% PHASE 3: Load Balancing
    max_iterations = 100;
    for iter = 1:max_iterations
        % Tính load của mỗi AP
        load = sum(D_new, 2);
        [max_load, l_overloaded] = max(load);
        
        % Kiểm tra điều kiện dừng
        if max_load <= L_max
            break;  % Tất cả AP đã cân bằng
        end
        
        % Tìm các UE được AP quá tải phục vụ
        UEs_at_l = find(D_new(l_overloaded, :) == 1);
        
        % Tìm UE có kết nối yếu nhất đến AP quá tải
        [~, weak_idx] = min(gainOverNoise(l_overloaded, UEs_at_l));
        k_weak = UEs_at_l(weak_idx);
        
        % Chỉ remove nếu UE còn đủ AP khác
        if sum(D_new(:, k_weak)) > N_min
            D_new(l_overloaded, k_weak) = 0;
            
            % Tùy chọn: Thêm AP thay thế (chưa quá tải)
            candidate_APs = find(D_new(:, k_weak) == 0 & load < L_max);
            if ~isempty(candidate_APs)
                [~, best_idx] = max(gainOverNoise(candidate_APs, k_weak));
                l_alt = candidate_APs(best_idx);
                D_new(l_alt, k_weak) = 1;
            end
        else
            % Không thể remove, đánh dấu cảnh báo
            warning('AP %d vẫn quá tải sau load balancing', l_overloaded);
            break;
        end
    end
    
    %% Thống kê kết quả
    avg_cluster_size = mean(sum(D_new, 1));
    avg_load = mean(sum(D_new, 2));
    fprintf('Proposed DCC: Avg cluster size = %.2f, Avg AP load = %.2f\n', ...
            avg_cluster_size, avg_load);
end
```

---

## 2.5 Sửa đổi script mô phỏng `section5_figure4a_6a.m`

### Vị trí file
```
cell-free-book/code/section5_figure4a_6a.m
```

### Thay đổi cần thực hiện

#### Bước 1: Thêm tham số cải tiến (sau dòng 44)

```matlab
%% THÊM MỚI: Tham số cho phương pháp đề xuất
threshold_ratio = 0.1;  % 10% của max β
L_max = 8;              % Max 8 UE/AP
N_min = 3;              % Min 3 AP/UE
```

#### Bước 2: Gọi function mới (sau dòng 71)

```matlab
%% THÊM MỚI: Tạo DCC matrix với phương pháp đề xuất
D_proposed = functionGenerateDCC_improved(gainOverNoisedB, L, K, ...
                                          threshold_ratio, L_max, N_min);
```

#### Bước 3: Thêm biến lưu kết quả (sau dòng 56)

```matlab
%% THÊM MỚI: Kết quả cho phương pháp đề xuất
SE_PMMSE_PROPOSED = zeros(K,nbrOfSetups);
SE_nopt_LPMMSE_PROPOSED = zeros(K,nbrOfSetups);
```

#### Bước 4: Tính SE với D_proposed (sau dòng 116)

```matlab
%% THÊM MỚI: Cell-Free Massive MIMO với phương pháp đề xuất
[~, SE_P_MMSE_prop, ~, ~, ...
    ~, SE_nopt_LP_MMSE_prop, ~, ...
    ~, ~, ~, ...
    ~, ~, ~, ~, ~, ~] ...
    = functionComputeSE_uplink(Hhat,H,D_proposed,D_small,B,C,tau_c,...
                                tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);

SE_PMMSE_PROPOSED(:,n) = SE_P_MMSE_prop;
SE_nopt_LPMMSE_PROPOSED(:,n) = SE_nopt_LP_MMSE_prop;
```

#### Bước 5: Thêm đường curve vào đồ thị (sau dòng 134)

```matlab
%% THÊM MỚI: Vẽ kết quả phương pháp đề xuất
plot(sort(SE_PMMSE_PROPOSED(:)),linspace(0,1,K*nbrOfSetups),'g-','LineWidth',2);

% Cập nhật legend
legend({'MMSE (All)','MMSE (DCC)','P-MMSE (DCC)','P-RZF (DCC)','MR (DCC)',...
        'P-MMSE (Proposed)'},'Interpreter','Latex','Location','SouthEast');
```

---

## 2.6 Figures cần tái tạo và so sánh

| Figure | Mô tả | Ý nghĩa so sánh |
|--------|-------|-----------------|
| **5.4(a)** | CDF của Uplink SE (Centralized) | So sánh P-MMSE (DCC) vs P-MMSE (Proposed) |
| **5.6(a)** | CDF của Uplink SE (Distributed) | So sánh LP-MMSE (DCC) vs LP-MMSE (Proposed) |
| **5.12** | Fronthaul signaling load | Chứng minh giảm fronthaul |
| **NEW** | Jain's Fairness Index | Chứng minh cải thiện fairness |

---

## 2.7 Tham số thử nghiệm đề xuất

### Thiết lập cơ bản (giữ nguyên từ sách)

| Tham số | Giá trị | Ý nghĩa |
|---------|---------|---------|
| $L$ | 100-400 | Số AP |
| $K$ | 40 | Số UE |
| $N$ | 4 | Anten/AP |
| $\tau_c$ | 200 | Coherence block size |
| $\tau_p$ | 10 | Pilot length |

### Tham số mới cần điều chỉnh

| Tham số | Range thử | Mặc định | Ảnh hưởng |
|---------|-----------|----------|-----------|
| `threshold_ratio` | 0.05 - 0.2 | 0.1 | Cao → ít AP hơn |
| `L_max` | 4 - 12 | 8 | Thấp → load balanced hơn |
| `N_min` | 1 - 5 | 3 | Cao → cluster lớn hơn |

---

## 2.8 Kết quả kỳ vọng

### So sánh định lượng

| Metric | DCC (Sách) | Proposed | Thay đổi |
|--------|------------|----------|----------|
| **Average SE** | 2.5 bit/s/Hz | 2.4 bit/s/Hz | -4% |
| **95%-likely SE** | 0.8 bit/s/Hz | 1.1 bit/s/Hz | **+37%** ✓ |
| **Jain's Fairness** | 0.75 | 0.85 | **+13%** ✓ |
| **Avg Cluster Size** | 10 | 8 | **-20%** ✓ |
| **Max AP Load** | Không giới hạn | ≤ L_max | Có kiểm soát ✓ |

### Trade-off chính
- Giảm nhẹ average SE (~4%)
- Đổi lại cải thiện đáng kể fairness và giảm fronthaul

---

## 2.9 Quy trình thực hiện từng bước

### Bước 1: Chuẩn bị môi trường
```bash
# Clone code từ GitHub
git clone https://github.com/emilbjornson/cell-free-book.git

# Hoặc sử dụng MATLAB Online (không cần cài đặt)
# Link: https://matlab.mathworks.com/open/github/v1?repo=emilbjornson/cell-free-book
```

### Bước 2: Tạo file function mới
1. Tạo file `functionGenerateDCC_improved.m` trong thư mục `code/`
2. Copy nội dung từ Section 2.4 ở trên

### Bước 3: Sửa đổi script mô phỏng
1. Mở `section5_figure4a_6a.m`
2. Thực hiện các thay đổi theo Section 2.5
3. Giảm `nbrOfSetups` từ 196 xuống 50 để test nhanh

### Bước 4: Chạy mô phỏng
```matlab
>> run('section5_figure4a_6a.m')
```

### Bước 5: Thu thập kết quả
- Export figures dưới dạng PNG/PDF
- Tính các metrics: Average SE, 95%-likely SE, Jain's index

---

## 2.10 Lưu ý khi thực hiện

> **⚠️ CẢNH BÁO:** 
> - Backup code gốc trước khi sửa đổi
> - Giảm `nbrOfSetups` khi test để tiết kiệm thời gian
> - Một số function cần CVX toolbox (có sẵn trong MATLAB Online)

> **💡 MẸO:**
> - Sử dụng MATLAB Online để tránh cài đặt phức tạp
> - So sánh curve mới với curve baseline để verify đúng
> - Chạy nhiều lần với random seed khác nhau để đảm bảo ổn định

---

# PHẦN 3: NỘI DUNG CHI TIẾT

## 3.1 User-Centric trong Cell-Free Massive MIMO

### Khái niệm User-Centric

Trong thiết kế **user-centric**, mỗi người dùng (UE) là trung tâm, được phục vụ bởi một **tập con các AP** (gọi là cluster) thay vì mọi AP trong mạng.

**Định nghĩa chính thức:**
- Với UE $k$, cluster phục vụ: $\mathcal{M}_k \subseteq \{1, 2, ..., L\}$
- Indicator: $a_{lk} = 1$ nếu $l \in \mathcal{M}_k$, ngược lại $a_{lk} = 0$

### So sánh Network-centric vs User-centric

```
┌─────────────────────────────────────────────────────────────────┐
│                    NETWORK-CENTRIC                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    AP1 ───┐                                                      │
│    AP2 ───┼───► CPU ◄───┬─── AP1 xử lý cho UE1,UE2,UE3          │
│    AP3 ───┘             │                                        │
│                         │    Mọi AP đều xử lý cho mọi UE         │
│    ↓ ↓ ↓ ↓             │    Fronthaul: O(L × K)                  │
│   UE1 UE2 UE3 UE4      │    Complexity: O(L × K)                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     USER-CENTRIC                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    AP1 ──────► UE1 ◄────── AP2                                   │
│                 │                                                │
│    AP2 ──────► UE2 ◄────── AP3                                   │
│                 │                                                │
│    AP3 ──────► UE3 ◄────── AP4                                   │
│                                                                  │
│    Mỗi UE có cluster riêng                                       │
│    Fronthaul: O(|M_k| × K) << O(L × K)                          │
│    Clustering overlap cho phép                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Ưu điểm User-Centric

1. **Scalability:** Độ phức tạp không tăng tỷ lệ với tổng số AP
2. **Giảm tải fronthaul:** Chỉ truyền thông tin kênh liên quan
3. **Xử lý linh hoạt:** AP có thể xử lý cục bộ
4. **Tiết kiệm năng lượng:** AP không liên quan có thể sleep

### Thách thức

1. **AP selection algorithm:** Làm sao chọn cluster tối ưu?
2. **Coordination overhead:** Các AP trong cluster cần phối hợp
3. **Dynamic adaptation:** Cluster cần thay đổi khi UE di chuyển
4. **Fairness:** Đảm bảo UE ở vùng ít AP vẫn được phục vụ tốt

---

## 3.2 Tốc độ dữ liệu đường lên (Uplink)

### Mô hình hệ thống Uplink

**Tín hiệu phát từ UE $k$:**
$$x_k = \sqrt{\rho_u} s_k$$

**Tín hiệu nhận tại AP $l$:**
$$\mathbf{y}_l^{ul} = \sum_{k=1}^{K} \mathbf{g}_{lk} x_k + \mathbf{n}_l = \sum_{k=1}^{K} \sqrt{\rho_u} \mathbf{g}_{lk} s_k + \mathbf{n}_l$$

**Sau combining tại AP $l$:**
$$\hat{s}_{lk} = \mathbf{v}_{lk}^H \mathbf{y}_l^{ul}$$

**Kết hợp tại CPU:**
$$\hat{s}_k = \sum_{l \in \mathcal{M}_k} \hat{s}_{lk} = \sum_{l \in \mathcal{M}_k} \mathbf{v}_{lk}^H \mathbf{y}_l^{ul}$$

### SE Uplink với các Combining Schemes

**1. Maximum Ratio (MR) Combining:**

$$\text{SE}_k^{ul,MR} = \frac{\tau_c - \tau_p}{\tau_c} \log_2\left(1 + \frac{\rho_u \left(\sum_{l \in \mathcal{M}_k} \gamma_{lk}\right)^2}{\sum_{k'=1}^{K} \rho_u \sum_{l \in \mathcal{M}_k} \gamma_{lk}\beta_{lk'} + \sum_{l \in \mathcal{M}_k} \gamma_{lk}}\right)$$

**2. Local MMSE Combining:**

SE cao hơn MR nhờ triệt nhiễu, nhưng không có closed-form đơn giản, cần tính numerical.

### Các yếu tố ảnh hưởng

| Yếu tố | Ảnh hưởng đến SE uplink |
|--------|------------------------|
| Số AP trong cluster ($|\mathcal{M}_k|$) | Tăng → SE tăng (đến bão hòa) |
| Pilot contamination | Nhiều UE share pilot → SE giảm |
| Công suất phát ($\rho_u$) | Tăng → SE tăng (giới hạn bởi interference) |
| Số anten/AP ($N$) | Tăng → SE tăng |
| Large-scale fading ($\beta_{lk}$) | Cao → SE cao |

### Ví dụ số

**Giả sử:**
- $L = 100$ APs, $K = 40$ UEs, $N = 4$ anten/AP
- $\tau_c = 200$, $\tau_p = 10$
- $|\mathcal{M}_k| = 10$ APs/UE

**Kết quả điển hình:**
- Average SE với MR: ~1.5 bit/s/Hz/user
- Average SE với MMSE: ~2.5 bit/s/Hz/user
- 95%-likely SE (user tệ nhất): ~0.5 bit/s/Hz (MR), ~1.2 bit/s/Hz (MMSE)

---

## 3.3 Tốc độ dữ liệu đường xuống (Downlink)

### Mô hình hệ thống Downlink

**Tín hiệu phát từ AP $l$:**
$$\mathbf{x}_l = \sum_{k=1}^{K} \sqrt{\eta_{lk}} \mathbf{w}_{lk} s_k$$

**Tín hiệu nhận tại UE $k$:**
$$y_k^{dl} = \sum_{l=1}^{L} \mathbf{g}_{lk}^T \mathbf{x}_l + n_k$$

### SE Downlink với Conjugate Beamforming

$$\text{SINR}_k^{dl,CB} = \frac{\left(\sum_{l \in \mathcal{M}_k} \sqrt{\eta_{lk}} \gamma_{lk}\right)^2}{\sum_{k'=1}^{K}\left(\sum_{l \in \mathcal{M}_{k'}} \eta_{lk'}\gamma_{lk'}\beta_{lk}\right) + \sigma^2}$$

### So sánh CB vs Local MMSE

| Tiêu chí | Conjugate Beamforming | Local MMSE |
|----------|----------------------|------------|
| Độ phức tạp | Thấp - $O(N)$ | Cao - $O(N^3)$ |
| Thông tin cần | CSI cục bộ | CSI cục bộ + shared info |
| Triệt nhiễu | Không | Có |
| SE (ít user) | Tương đương | Cao hơn ~20-50% |
| SE (nhiều user) | Thấp hơn nhiều | Cao hơn đáng kể |
| Phù hợp cho | Hệ thống đơn giản | Hệ thống cao cấp |

### Ví dụ đồ thị minh họa

```
SE [bit/s/Hz]
    ^
  4 │                    ┌── Local MMSE
    │                 .-─┘
  3 │              .-─
    │           .-─
  2 │        .-─       ┌── Conjugate BF
    │     .-─       .-─┘
  1 │  .-─       .-─
    │-─       .-─
  0 ├──────────────────────► Số APs trong cluster
    0    5   10   15   20
```

---

## 3.4 Ảnh hưởng của AP Selection

### Các phương pháp AP Selection phổ biến

**1. All APs (Baseline):**
- $\mathcal{M}_k = \{1, ..., L\}$ cho mọi $k$
- Hiệu suất tối đa nhưng không scalable

**2. Distance-based:**
- $\mathcal{M}_k = \{l : d_{lk} \leq d_{max}\}$
- Đơn giản, không cần đo kênh

**3. Large-scale fading based:**
- $\mathcal{M}_k = \{l : \beta_{lk} \geq \tau\}$
- Phản ánh chất lượng kênh thực tế

**4. Fixed-size K-strongest:**
- Chọn $N_{max}$ APs với $\beta_{lk}$ lớn nhất
- Đảm bảo số AP cố định

**5. Received power based:**
- Sử dụng đo đạc signal strength thực tế
- Phù hợp triển khai thực tế

### Trade-off giữa số lượng AP và hiệu suất

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  SE                                                          │
│   ^                                                          │
│   │           ╭────────────── Full AP                        │
│   │        ╭──╯                                              │
│   │     ╭──╯      ← Điểm bão hòa                             │
│   │  ╭──╯                                                    │
│   │╭─╯                                                       │
│   ├───────────────────────────────────► |M_k|               │
│   1       10       20       30     L                         │
│                                                              │
│  Fronthaul Load                                              │
│   ^                                                          │
│   │                              ╱                           │
│   │                           ╱                              │
│   │                        ╱    ← Tăng tuyến tính            │
│   │                     ╱                                    │
│   │                  ╱                                       │
│   ├───────────────────────────────────► |M_k|               │
│                                                              │
│  ➜ Trade-off: Cần tìm |M_k| tối ưu                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Phân tích ảnh hưởng đến SE

| Số AP ($|\mathcal{M}_k|$) | SE Uplink | SE Downlink | Fronthaul | Complexity |
|---------------------------|-----------|-------------|-----------|------------|
| 1 | Thấp | Thấp | Rất thấp | O(1) |
| 5 | Trung bình | Trung bình | Thấp | O(5) |
| 10 | Cao | Cao | Trung bình | O(10) |
| 20 | Rất cao | Rất cao | Cao | O(20) |
| All (L) | Tối đa | Tối đa | Rất cao | O(L) |

### Bảng so sánh các phương pháp

| Phương pháp | Complex. | Cần CSI | Scalable | SE | Fairness |
|-------------|----------|---------|----------|-----|----------|
| All APs | Cao | Có | Không | ★★★★★ | ★★★ |
| Distance-based | Thấp | Không | Có | ★★★ | ★★ |
| LSF-threshold | Thấp | Có ($\beta$) | Có | ★★★★ | ★★★ |
| K-strongest | Trung bình | Có ($\beta$) | Có | ★★★★ | ★★★★ |
| Received-power | Thấp | Có (đo) | Có | ★★★★ | ★★★ |

---

## 3.5 Đề xuất cải tiến: Threshold-based AP Selection với Load Balancing

### Mô tả phương pháp đề xuất

**Ý tưởng chính:** Kết hợp:
1. **Threshold-based selection:** Chọn AP dựa trên ngưỡng $\beta$ để đảm bảo chất lượng kênh
2. **Load balancing:** Giới hạn số UE mỗi AP phục vụ để tránh quá tải

**Tham số:**
- $\tau$: Ngưỡng large-scale fading (threshold)
- $L_{max}$: Số UE tối đa mỗi AP có thể phục vụ
- $N_{min}$: Số AP tối thiểu cho mỗi UE

### Thuật toán chi tiết (Pseudocode)

```
Algorithm: Threshold-based AP Selection with Load Balancing

Input:
  - β[L][K]: Large-scale fading matrix
  - τ: LSF threshold
  - L_max: Maximum UEs per AP
  - N_min: Minimum APs per UE

Output:
  - M[K]: Cluster cho mỗi UE

# Phase 1: Initial threshold-based selection
For each UE k = 1 to K:
    M[k] = {l : β[l][k] ≥ τ}
    
# Phase 2: Ensure minimum connectivity
For each UE k = 1 to K:
    If |M[k]| < N_min:
        # Add strongest APs until N_min
        candidates = sort(APs \ M[k], by β[.][k], descending)
        for l in candidates:
            if |M[k]| >= N_min: break
            M[k] = M[k] ∪ {l}

# Phase 3: Load balancing
Repeat until no AP is overloaded:
    For each AP l = 1 to L:
        load[l] = |{k : l ∈ M[k]}|
        
    l_max = argmax(load)
    If load[l_max] <= L_max: break  # All balanced
    
    # Find UE with weakest connection to l_max
    UEs_at_l = {k : l_max ∈ M[k]}
    k_weak = argmin_{k ∈ UEs_at_l} β[l_max][k]
    
    # Check if UE k_weak can lose this AP
    If |M[k_weak]| > N_min:
        M[k_weak] = M[k_weak] \ {l_max}
        
        # Optionally add alternative AP (not overloaded)
        alt_candidates = {l : l ∉ M[k_weak], load[l] < L_max}
        If alt_candidates ≠ ∅:
            l_alt = argmax_{l ∈ alt_candidates} β[l][k_weak]
            M[k_weak] = M[k_weak] ∪ {l_alt}
    Else:
        # Cannot remove, mark for relaxation
        Flag load imbalance for AP l_max

Return M
```

### Phân tích độ phức tạp

| Pha | Độ phức tạp thời gian | Ghi chú |
|-----|----------------------|---------|
| Phase 1 | $O(LK)$ | Scan toàn bộ ma trận $\beta$ |
| Phase 2 | $O(K \cdot L \log L)$ | Sorting cho mỗi UE |
| Phase 3 | $O(I \cdot L \cdot K)$ | $I$ = số iterations |
| **Tổng** | $O(LK \log L + I \cdot LK)$ | I thường nhỏ |

**So sánh:**
- All APs: $O(LK)$ nhưng processing $O(L^2K)$
- K-strongest: $O(LK \log L)$
- Proposed: $O(LK \log L)$ (tương đương K-strongest)

### Kết quả mô phỏng dự kiến

**Thiết lập:**
- $L = 100$ APs, $K = 40$ UEs
- Area: 1km × 1km
- $\tau = 0.01 \times \max(\beta)$
- $L_{max} = 8$, $N_{min} = 3$

**Metrics so sánh:**

| Phương pháp | Avg SE | 95%-likely SE | Fairness | Avg Cluster Size |
|-------------|--------|---------------|----------|-----------------|
| All APs | 2.5 | 1.0 | 0.82 | 100 |
| K-strongest (K=10) | 2.3 | 0.9 | 0.80 | 10 |
| Threshold-only | 2.2 | 0.7 | 0.75 | 12 (avg) |
| **Proposed** | **2.4** | **1.1** | **0.85** | **9** (avg) |

**Ưu điểm của phương pháp đề xuất:**
1. 95%-likely SE cao hơn → UE yếu được cải thiện
2. Fairness tốt hơn nhờ load balancing
3. Cluster size nhỏ hơn → giảm fronthaul
4. Scalable với hệ thống lớn

---

# PHẦN 4: CÂU HỎI TIỀM NĂNG TỪ GIÁO VIÊN

## Q1: Tại sao Cell-Free Massive MIMO lại tốt hơn Cellular Massive MIMO?

**Gợi ý trả lời:**
- **Macro-diversity:** APs phân tán nên mỗi UE có thể có AP gần, giảm path loss
- **Không có cell boundary:** Loại bỏ inter-cell interference truyền thống
- **Uniform coverage:** UE ở bất kỳ đâu đều có QoS tương đương
- **Trade-off:** Phức tạp hơn về fronthaul và coordination

---

## Q2: Channel hardening là gì? Tại sao quan trọng?

**Gợi ý trả lời:**
- Khi số anten $M \to \infty$: $\frac{\|\mathbf{h}_k\|^2}{M} \to \beta_k$ (hằng số)
- Quan trọng vì:
  - Kênh trở nên "deterministic" → đơn giản hóa detection
  - Giảm thiểu fading effects
  - Cho phép sử dụng ergodic analysis

---

## Q3: Pilot contamination ảnh hưởng thế nào đến hiệu suất hệ thống?

**Gợi ý trả lời:**
- Khi $K > \tau_p$: nhiều UE dùng chung pilot
- Ước lượng kênh $\hat{\mathbf{g}}_{lk}$ bị "ô nhiễm" bởi kênh của UE khác
- Gây coherent interference không giảm được khi tăng $M$
- Giải pháp: Pilot assignment optimization, semi-blind estimation

---

## Q4: So sánh MR combining và MMSE combining?

**Gợi ý trả lời:**

| MR | MMSE |
|----|------|
| $\mathbf{v}_{lk} = \hat{\mathbf{g}}_{lk}$ | $\mathbf{v}_{lk} = (\sum \hat{\mathbf{g}}\hat{\mathbf{g}}^H + \sigma^2\mathbf{I})^{-1}\hat{\mathbf{g}}_{lk}$ |
| Tối đa desired signal | Cân bằng signal và interference suppression |
| Độ phức tạp $O(N)$ | Độ phức tạp $O(N^3)$ matrix inversion |
| Tốt khi ít interference | Tốt khi nhiều interference |

---

## Q5: Tại sao cần user-centric design? Scalability issue là gì?

**Gợi ý trả lời:**
- Network-centric: CPU cần xử lý $L \times K$ kênh
- Với $L = 200$, $K = 100$: 20,000 kênh → không thực tế
- User-centric: Mỗi UE chỉ cần ~10 APs → ~1,000 kênh tổng
- Scalability: Giữ độ phức tạp gần như constant khi $L, K$ tăng

---

## Q6: Large-scale fading coefficient $\beta_{lk}$ bao gồm những gì?

**Gợi ý trả lời:**
- **Path loss:** Suy hao do khoảng cách $d^{-\alpha}$
- **Shadow fading:** Log-normal shadowing, $10^{\sigma z/10}$
- **Antenna gains:** Gain của AP và UE
- Đặc điểm: Thay đổi chậm, giống nhau cho mọi anten trong AP

---

## Q7: Sự khác biệt giữa conjugate beamforming và MMSE precoding?

**Gợi ý trả lời:**
- CB: $\mathbf{w}_{lk} = \hat{\mathbf{g}}_{lk}^*$ → matched filter
- MMSE: $\mathbf{w}_{lk} = (\text{regularized inverse})\hat{\mathbf{g}}_{lk}$
- CB đơn giản, chỉ cần local CSI
- MMSE triệt interference nhưng cần shared CSI
- Khi $M/K$ lớn: CB ≈ MMSE; khi $M/K$ nhỏ: MMSE >> CB

---

## Q8: Fronthaul là gì và tại sao là bottleneck?

**Gợi ý trả lời:**
- Fronthaul: Liên kết giữa APs và CPU
- Bottleneck vì cần truyền:
  - Channel estimates ($N \times K$ complex numbers/AP)
  - Data symbols (sau local processing)
- Giải pháp: Distributed processing, quantization, user-centric design

---

## Q9: Threshold-based AP selection có nhược điểm gì?

**Gợi ý trả lời:**
- Threshold cố định không adapt theo mật độ AP/UE
- UE ở vùng sparse có thể có quá ít AP
- UE ở vùng dense có thể có quá nhiều AP
- Giải pháp: Adaptive threshold, kết hợp load balancing

---

## Q10: Load balancing quan trọng thế nào trong Cell-Free MIMO?

**Gợi ý trả lời:**
- Một AP quá tải → bottleneck cho nhiều UE
- Processing capacity của AP có giới hạn (power, computation)
- Unbalanced load → unfair SE distribution
- Load balancing cải thiện fairness index đáng kể

---

## Q11: Use-and-then-Forget bound là gì?

**Gợi ý trả lời:**
- Kỹ thuật phân tích SE khi chỉ biết statistical CSI
- "Use": Dùng channel estimate $\hat{\mathbf{g}}$ cho detection
- "Forget": Coi effective channel như constant (mean)
- Cho lower bound trên achievable SE
- Tight khi có channel hardening

---

## Q12: Làm sao đánh giá fairness trong Cell-Free MIMO?

**Gợi ý trả lời:**
- **90% likely SE:** SE mà 90% users đạt được
- **Jain's index:** $\mathcal{J} = (\sum \text{SE})^2/(K \sum \text{SE}^2)$
- **Max-min SE:** SE của user tệ nhất
- Cell-Free thường có fairness tốt hơn Cellular (0.7 vs 0.4)

---

## Q13: Phương pháp đề xuất Threshold + Load Balancing có ưu điểm gì so với K-strongest?

**Gợi ý trả lời:**
- K-strongest: Cluster size cố định, không phản ánh chất lượng kênh
- Threshold: Adaptive size nhưng có thể unbalanced
- Proposed kết hợp:
  - Đảm bảo quality (threshold)
  - Đảm bảo fairness (load balance)
  - Flexibility (adaptive cluster size)

---

## Q14: Những thách thức khi triển khai Cell-Free MIMO trong thực tế?

**Gợi ý trả lời:**
- **Synchronization:** Các AP cần đồng bộ phase để coherent transmission
- **Fronthaul deployment:** Chi phí fiber optic cao
- **Handover:** UE di chuyển cần update cluster liên tục
- **Power consumption:** Nhiều AP nhỏ có thể tốn điện hơn 1 BS lớn
- **Interference management:** Cần coordination phức tạp

---

## Q15: Tương lai của Cell-Free Massive MIMO trong 6G?

**Gợi ý trả lời:**
- **Radio Stripe:** APs được nhúng vào cáp → easy deployment
- **RIS integration:** Reconfigurable Intelligent Surfaces tăng cường
- **THz communication:** Cell-free phù hợp với coverage hole của THz
- **AI-native:** Machine learning cho AP selection, power control
- **Standardization:** 3GPP đang xem xét cho 6G
---

# THAM KHẢO

1. E. Björnson and L. Sanguinetti, "Foundations of User-Centric Cell-Free Massive MIMO," *Foundations and Trends in Signal Processing*, 2024.
2. H. Q. Ngo et al., "Cell-Free Massive MIMO versus Small Cells," *IEEE TWC*, 2017.
3. E. Nayebi et al., "Precoding and Power Optimization in Cell-Free Massive MIMO Systems," *IEEE TWC*, 2017.
4. G. Interdonato et al., "Ubiquitous Cell-Free Massive MIMO Communications," *EURASIP JWCN*, 2019.
5. Ö. T. Demir et al., "Foundations of User-Centric Cell-Free Massive MIMO," *arXiv:2108.02541*, 2021.

---

*Tài liệu được tạo cho bài tập lớn môn Mạng thế hệ sau*
*Ngày tạo: 20/12/2024*
