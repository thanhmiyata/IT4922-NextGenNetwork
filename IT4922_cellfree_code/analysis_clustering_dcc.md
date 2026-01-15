# Phân tích Chi tiết: Thuật toán Clustering-based DCC

Tài liệu này phân tích thuật toán **Hierarchical Clustering** áp dụng cho Cell-free Massive MIMO, được thực thi trong file `functionGenerateDCC_clustering.m`.

---

## 1. Triết lý thiết kế

Khác biệt hoàn toàn với cách tiếp cận chọn AP theo từng cá nhân (UE-specific), thuật toán này sử dụng tư duy **Phân nhóm (Grouping)**. Mục tiêu là tìm ra các UE có đặc điểm truyền dẫn tương đồng để phục vụ theo cụm, giúp tối ưu hóa việc quản lý tài nguyên điều khiển.

---

## 2. Nguyên lý hoạt động của Thuật toán Clustering

### 2.1. Khái niệm Spatial Signature (Chữ ký không gian)

Thuật toán không chỉ nhìn vào độ mạnh của tín hiệu mà nhìn vào **hướng** và **tương quan**:

* Vector gain của mỗi UE được chuẩn hóa (Normalization) để loại bỏ ảnh hưởng của khoảng cách tuyệt đối.
* Sau khi chuẩn hóa, vector này đại diện cho "vùng ảnh hưởng" của UE đối với tập hợp các AP. Hai UE đứng gần nhau sẽ có "chữ ký" giống nhau.

### 2.2. Các bước xử lý chính

1. **Tính toán ma trận khoảng cách:** Sử dụng khoảng cách **Cosine** thay vì Euclidean. Khoảng cách Cosine đo góc giữa 2 vector, giúp xác định hai UE có cùng hướng thu phát mạnh hay không.
2. **Phân cấp (Hierarchical Clustering):** Xây dựng cây phân cấp (Dendrogram) để nhóm các UE.
3. **Cắt cây (Cutting):** Dựa trên `targetClusterSize` để quyết định số lượng cụm (Clusters) tối ưu cho mạng.
4. **Xác định "Chữ ký AP" cho cụm:**
   * Tính trung bình độ lợi kênh của cả cụm đến từng AP.
   * Sắp xếp và chọn ra `topM` AP tốt nhất cho cả nhóm UE này cùng lúc.
5. **Cân bằng tải:** Vẫn áp dụng các ràng buộc `L_max` và `N_min` để đảm bảo không cụm nào chiếm dụng quá nhiều tài nguyên của một AP.

---

## 3. Các thông số đặc thù

| Thông số                      | Ý nghĩa                        | Ảnh hưởng                                                                                                                                                    |
| :------------------------------ | :------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`targetClusterSize`** | Số UE mục tiêu trong 1 cụm   | Cụm càng lớn thì việc quản lý càng đơn giản (ít nhóm điều khiển) nhưng độ chính xác trong việc chọn AP cho từng cá nhân sẽ giảm.    |
| **`topM`**              | Số AP "chữ ký" cho cụm       | Lượng tài nguyên AP cấp cho mỗi nhóm. Nếu quá thấp, UE trong cụm sẽ bị sụt giảm SE. Nếu quá cao, các cụm sẽ bị chồng lấn AP gây nhiễu. |
| **`distType`**          | Phương pháp đo khoảng cách | `cosine` là tối ưu nhất cho hướng sóng. `euclidean` tập trung vào vị trí địa lý thuần túy.                                                  |

---

## 4. Ưu và Nhược điểm so với DCC truyền thống

### Ưu điểm:

* **Giảm chi phí báo hiệu (Overhead):** Thay vì mỗi UE có một danh sách AP riêng biệt cần phối hợp, giờ đây chúng ta quản lý theo từng cụm. Việc trao đổi thông tin giữa các AP trong cụm trở nên tập trung hơn.
* **Hỗ trợ Joint Beamforming:** Cực kỳ hiệu quả khi triển khai các kỹ thuật truyền dẫn phối hợp cho nhóm người dụng (Multi-user MIMO phối hợp).

### Nhược điểm:

* **Đánh đổi độ chính xác:** Một số UE ở "rìa" của cụm có thể không được dùng AP thực sự tốt nhất của mình vì phải tuân theo lựa chọn chung của cả cụm.
* **Độ phức tạp tính toán:** Thuật toán Clustering yêu cầu tính toán ma trận tương quan giữa các UE, đòi hỏi CPU tại trạm gốc mạnh hơn.

---

## 5. Kết luận

Thuật toán Clustering-based DCC là một giải pháp mang tính chiến lược cho các khu vực có **mật độ người dùng cực cao**. Nó chuyển dịch từ bài toán "tối ưu hóa người dùng" sang bài toán "tối ưu hóa hạ tầng mạng".
