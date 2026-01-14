function [D_cluster, stats] = functionGenerateDCC_clustering(gainOverNoisedB, L, K, varargin)
%functionGenerateDCC_clustering Xây dựng ma trận D thông qua clustering UE dựa trên gain map.
%   Thuật toán này gom các UE thành cụm dựa trên độ tương đồng của vector large-scale gain,
%   sau đó gán một bộ AP "chữ ký" chung cho mỗi cụm, và thực thi các ràng buộc về tải.
%
% INPUTS (Đầu vào):
%   gainOverNoisedB : Ma trận [L x K] chứa tỷ số gain-to-noise theo dB.
%                     Mỗi cột k là vector gain của UE k đến L AP.
%                     Ví dụ: gainOverNoisedB(m,k) = 50 dB nghĩa là AP m 
%                     thấy UE k với gain rất mạnh.
%   L               : Số lượng AP trong mạng (ví dụ: 100 hoặc 400).
%   K               : Số lượng UE trong mạng (ví dụ: 20 hoặc 40).
%
% OPTIONAL PARAMETERS (Tham số tùy chọn - name-value pairs):
%   'L_max'             : Số UE tối đa mà mỗi AP được phép phục vụ (mặc định 8).
%                         Ví dụ: L_max=8 nghĩa là AP m không được phục vụ quá 8 UE.
%   'N_min'             : Số AP tối thiểu phải phục vụ mỗi UE (mặc định 3).
%                         Ví dụ: N_min=3 nghĩa là mỗi UE phải có ít nhất 3 AP.
%   'targetClusterSize' : Số UE mục tiêu trong mỗi cụm (mặc định 5).
%                         Ví dụ: targetClusterSize=5 với K=20 → khoảng 4 cụm.
%   'topM'              : Số AP đầu tiên (mạnh nhất) được gán cho mỗi cụm (mặc định 6).
%                         Ví dụ: topM=6 nghĩa là mỗi cụm dùng chung 6 AP mạnh nhất.
%   'distType'          : Kiểu khoảng cách cho pdist (mặc định 'cosine').
%                         'cosine' đo góc giữa các vector → tập trung vào hướng gain.
%                         Các tùy chọn khác: 'euclidean', 'correlation', 'cityblock'.
%   'linkMethod'        : Phương pháp linkage cho clustering (mặc định 'average').
%                         'average': average linkage (UPGMA).
%                         Các tùy chọn khác: 'single', 'complete', 'ward'.
%
% OUTPUTS (Đầu ra):
%   D_cluster : Ma trận nhị phân [L x K], D_cluster(m,k)=1 nếu AP m phục vụ UE k.
%   stats     : Struct chứa thông tin về clustering và load:
%               - numClusters: số cụm đã tạo
%               - clusterSizes: vector kích thước từng cụm
%               - topM, targetClusterSize, L_max, N_min: các tham số đã dùng
%               - avgLoad: trung bình số UE/AP
%               - maxLoad: tải cao nhất trên một AP
%               - iterations: số vòng lặp cân bằng tải
%
% GHI CHÚ:
%   - Sử dụng hierarchical clustering trên các vector gain đã chuẩn hóa (không cần training).
%   - Thực thi ràng buộc N_min cho mỗi UE và giới hạn tải L_max cho mỗi AP bằng greedy repair.
%   - Yêu cầu Statistics and Machine Learning Toolbox (pdist, linkage, cluster).
%   
% CẢNH BÁO VỀ PILOT CONTAMINATION (QUAN TRỌNG):
%   - Clustering CÓ THỂ gom các UE dùng chung pilot vào cùng cụm
%   - Khi đó: các UE cùng pilot + cùng bộ AP → pilot contamination CỰC MẠNH
%   - Hậu quả: SE giảm mạnh hoặc = 0, đặc biệt với LSFD schemes (LP-MMSE, MR)
%   - Hiện tượng: ~20% UE có SE ≈ 0 trong Figure 5.6a (LSFD)
%   
%   GIẢI PHÁP:
%   1. Pilot-aware clustering: Tránh gom UE cùng pilot vào cùng cụm
%   2. Sử dụng centralized schemes (P-MMSE) thay vì LSFD khi có clustering
%   3. Tăng số pilot (τ_p) để giảm pilot reuse
%   4. Modify distance metric: Thêm penalty cho UE cùng pilot
%
% VÍ DỤ SỬ DỤNG:
%   % Với L=100 AP, K=20 UE, mỗi AP tối đa 8 UE, mỗi UE tối thiểu 3 AP
%   [D, stats] = functionGenerateDCC_clustering(gainOverNoisedB, 100, 20, ...
%       'L_max', 8, 'N_min', 3, 'targetClusterSize', 5, 'topM', 6);
%   % Kiểm tra: số AP phục vụ UE 1
%   numAPs_UE1 = sum(D(:,1));  % nên >= 3
%   % Kiểm tra: số UE được phục vụ bởi AP 10
%   numUEs_AP10 = sum(D(10,:)); % nên <= 8

%% Phân tích tham số đầu vào và thiết lập giá trị mặc định
% Sử dụng inputParser để xử lý các tham số name-value một cách linh hoạt
p = inputParser;
p.addParameter('L_max', 8);              % Tải tối đa mỗi AP (số UE)
p.addParameter('N_min', 3);              % Số AP tối thiểu mỗi UE
p.addParameter('targetClusterSize', 5);  % Kích thước cụm mục tiêu (số UE/cụm)
p.addParameter('topM', 6);               % Số AP đầu tiên gán cho cụm
p.addParameter('distType', 'cosine');    % Kiểu khoảng cách cho clustering
p.addParameter('linkMethod', 'average'); % Phương pháp linkage
p.parse(varargin{:});

% Lấy giá trị đã parse từ input arguments
L_max = p.Results.L_max;
N_min = p.Results.N_min;
targetClusterSize = p.Results.targetClusterSize;
topM = p.Results.topM;
distType = p.Results.distType;
linkMethod = p.Results.linkMethod;

%% Kiểm tra tính hợp lệ của tham số đầu vào
% Đảm bảo kích thước ma trận gainOverNoisedB đúng với L và K
if size(gainOverNoisedB,1) ~= L || size(gainOverNoisedB,2) ~= K
    error('gainOverNoisedB must be of size L x K.');
end

% N_min không thể lớn hơn tổng số AP trong hệ thống
if N_min > L
    error('N_min cannot exceed number of APs.');
end

% Điều chỉnh topM nếu vượt quá số AP có sẵn
% Ví dụ: nếu L=100 nhưng topM=150 → điều chỉnh topM=100
if topM > L
    topM = L;
end

%% Tiền xử lý bản đồ gain để chuẩn bị cho clustering
% Chuyển đổi gain từ dB sang thang tuyến tính
% Công thức: gainLin = 10^(gainOverNoisedB/10)
% Ví dụ: 50 dB → 10^5 = 100000 (tuyến tính)
gainLin = db2pow(gainOverNoisedB);  % Ma trận L x K

% Chuẩn hóa gain theo từng UE để tập trung vào "hình dạng không gian" của gain vector
% Tìm gain lớn nhất của mỗi UE (max theo chiều AP)
% ueNorm: vector 1 x K, ueNorm(k) = max gain của UE k
% Thêm epsilon nhỏ (1e-12) để tránh chia cho 0 khi UE có gain rất nhỏ
ueNorm = max(gainLin, [], 1) + 1e-12;  % 1 x K

% Chuẩn hóa: chia mỗi cột (UE) cho gain max của nó
% gainNorm(m,k) = gainLin(m,k) / max_gain_of_UE_k
% Sau chuẩn hóa: mỗi UE có gain lớn nhất = 1, các AP khác có tỷ lệ tương đối
% Ví dụ: UE 1 có gain đến AP [100, 80, 10] → sau chuẩn hóa [1.0, 0.8, 0.1]
%        UE 2 có gain đến AP [50, 40, 5]   → sau chuẩn hóa [1.0, 0.8, 0.1]
%        → Hai UE này sẽ được coi là "tương đồng" về spatial signature
gainNorm = gainLin ./ ueNorm;  % L x K

%% Gom cụm UE dựa trên độ tương đồng của gain vectors
% Tính số cụm mục tiêu: chia K UE cho targetClusterSize
% Ví dụ: K=20, targetClusterSize=5 → numClusters = ceil(20/5) = 4 cụm
numClusters = max(1, ceil(K / targetClusterSize));

% Bước 1: Tính ma trận khoảng cách giữa các cặp UE
% pdist() nhận input là ma trận K x L (mỗi hàng là 1 UE)
% nên phải transpose gainNorm từ L x K → K x L
% distVec là vector chứa khoảng cách giữa tất cả cặp UE (độ dài = K*(K-1)/2)
% Ví dụ với K=4: distVec chứa d(1,2), d(1,3), d(1,4), d(2,3), d(2,4), d(3,4)
% distType='cosine': khoảng cách cosine = 1 - cos(θ) với θ là góc giữa 2 vector
%   → UE có gain vector gần song song sẽ có khoảng cách nhỏ (tương đồng cao)
distVec = pdist(gainNorm.', distType);

% Bước 2: Xây dựng cây phân cấp (dendrogram) bằng hierarchical clustering
% linkage() kết nối các UE/cụm dựa trên khoảng cách
% linkMethod='average': khoảng cách giữa 2 cụm = trung bình khoảng cách giữa mọi cặp
% Z: ma trận (K-1) x 3 mô tả cây phân cấp
Z = linkage(distVec, linkMethod);

% Bước 3: Cắt cây để tạo numClusters cụm
% cluster() gán mỗi UE vào 1 cụm (label từ 1 đến numClusters)
% labels: vector K x 1, labels(k) = ID cụm của UE k
% Ví dụ: labels = [1, 1, 2, 1, 2, 3, 3, 2, ...] nghĩa là
%        UE 1,2,4 thuộc cụm 1; UE 3,5,8 thuộc cụm 2; UE 6,7 thuộc cụm 3
labels = cluster(Z, 'maxclust', numClusters);

% Đếm số UE trong mỗi cụm
% accumarray(labels, 1) đếm số lần xuất hiện của mỗi label
% clusterSizes: vector numClusters x 1, clusterSizes(c) = số UE trong cụm c
clusterSizes = accumarray(labels, 1, [numClusters 1]);

%% Xây dựng "chữ ký AP" cho mỗi cụm và khởi tạo ma trận D
% Khởi tạo ma trận D với toàn bộ phần tử = 0
D_cluster = zeros(L, K);

% Cell array lưu danh sách AP ưu tiên (theo thứ tự gain giảm dần) cho mỗi UE
% Dùng để sửa chữa (repair) khi cần đảm bảo N_min hoặc giảm tải
ueApOrder = cell(K,1);

% Duyệt qua từng cụm
for c = 1:numClusters
    % Tìm tất cả UE thuộc cụm c
    % members: vector chứa các index của UE trong cụm c
    % Ví dụ: nếu cụm 1 có UE [2, 5, 7] → members = [2; 5; 7]
    members = find(labels == c);
    
    % Nếu cụm rỗng (không có UE) → bỏ qua
    if isempty(members)
        continue;
    end
    
    % Tính gain trung bình của cụm đến từng AP
    % gainLin(:, members) là ma trận L x |members| (gain của các UE trong cụm)
    % mean(..., 2) lấy trung bình theo chiều UE → vector L x 1
    % meanGain(m) = gain trung bình từ cụm c đến AP m
    % Ý nghĩa: AP nào có meanGain cao → phù hợp với "nhóm UE" này
    % Ví dụ: Cụm có 3 UE [1,2,3] với gain đến AP_10 là [100, 90, 110]
    %        → meanGain(AP_10) = (100+90+110)/3 = 100
    meanGain = mean(gainLin(:, members), 2);  % L x 1
    
    % Sắp xếp các AP theo meanGain giảm dần → tìm AP "tốt nhất" cho cụm
    % apOrder: vector L x 1 chứa index của AP theo thứ tự từ mạnh nhất → yếu nhất
    % Ví dụ: apOrder = [45, 12, 78, ...] nghĩa là AP 45 tốt nhất, AP 12 thứ 2, ...
    [~, apOrder] = sort(meanGain, 'descend');
    apOrder = apOrder(:);  % đảm bảo là vector cột
    
    % Chọn topM AP đầu tiên (mạnh nhất) để gán cho tất cả UE trong cụm
    % Ví dụ: topM=6 → chọn 6 AP đầu tiên từ apOrder
    selectCount = min(topM, L);  % đảm bảo không vượt quá số AP có sẵn
    selectedAPs = apOrder(1:selectCount);  % vector chứa index của topM AP
    
    % Gán topM AP này cho tất cả UE trong cụm
    for u = members.'  % duyệt qua từng UE trong cụm (transpose để lặp đúng)
        % Đặt D_cluster(selectedAPs, u) = 1
        % Nghĩa là: tất cả selectedAPs đều phục vụ UE u
        D_cluster(selectedAPs, u) = 1;
        
        % Lưu danh sách ưu tiên đầy đủ (toàn bộ L AP) cho UE u
        % Dùng sau này khi cần thêm/bớt AP để thỏa mãn ràng buộc
        ueApOrder{u} = apOrder;
    end
end

%% GIAI ĐOẠN 1: Đảm bảo mỗi UE có ít nhất N_min AP phục vụ
% Sau khi gán AP theo cụm, một số UE có thể có ít hơn N_min AP
% (do topM nhỏ hoặc cụm có gain thấp với nhiều AP)
% Vòng lặp này sẽ bổ sung thêm AP cho các UE thiếu

for u = 1:K
    % Lấy danh sách AP ưu tiên của UE u (đã lưu trong bước trước)
    apOrder = ueApOrder{u};
    
    % Trường hợp dự phòng: nếu UE không có apOrder (do lỗi clustering)
    % → dùng gain riêng của UE đó để sắp xếp AP
    if isempty(apOrder)
        [~, apOrder] = sort(gainLin(:,u), 'descend');
        ueApOrder{u} = apOrder;
    end
    
    % Đếm số AP hiện đang phục vụ UE u
    % currentAPs: vector chứa index các AP có D_cluster(m,u) = 1
    currentAPs = find(D_cluster(:,u));
    
    % Duyệt qua danh sách AP ưu tiên cho đến khi đủ N_min AP
    idx = 1;  % con trỏ trong apOrder
    while numel(currentAPs) < N_min && idx <= numel(apOrder)
        cand = apOrder(idx);  % AP ứng viên tiếp theo
        
        % Nếu cand chưa phục vụ UE u → thêm vào
        if ~ismember(cand, currentAPs)
            D_cluster(cand, u) = 1;
            currentAPs(end+1) = cand; %#ok<AGROW>
        end
        idx = idx + 1;
    end
    
    % Sau vòng lặp: UE u sẽ có ít nhất N_min AP (trừ khi L < N_min - đã check trước)
    % Ví dụ: UE 5 ban đầu có 2 AP, N_min=3 → thêm 1 AP mạnh nhất còn lại
end

%% GIAI ĐOẠN 2: Cân bằng tải - Đảm bảo mỗi AP không phục vụ quá L_max UE
% Tính tải hiện tại của mỗi AP (số UE đang được phục vụ)
% loadAP: vector L x 1, loadAP(m) = số UE mà AP m đang phục vụ
% loadAP(m) = sum(D_cluster(m,:)) = tổng số 1 trên hàng m
loadAP = sum(D_cluster, 2);  % L x 1

% Giới hạn số vòng lặp để tránh vòng lặp vô tận
% Ví dụ: K=20 → maxIter = 200 vòng
maxIter = 10 * K;
iter = 0;  % đếm số vòng lặp thực tế đã chạy

% Lặp cho đến khi không còn AP nào quá tải (loadAP(m) > L_max)
% hoặc đạt giới hạn số vòng lặp
while any(loadAP > L_max) && iter < maxIter
    iter = iter + 1;
    
    % Sắp xếp các AP theo tải giảm dần
    % apList: vector L x 1 chứa index AP từ quá tải nhất → ít tải nhất
    % Ví dụ: apList = [23, 5, 12, ...] nghĩa là AP 23 có tải cao nhất
    [~, apList] = sort(loadAP, 'descend');
    
    % Duyệt qua các AP từ quá tải nhất
    for idxAP = 1:numel(apList)
        m = apList(idxAP);  % index của AP đang xét
        
        % Nếu AP m không quá tải → bỏ qua, xét AP tiếp theo
        if loadAP(m) <= L_max
            continue;
        end
        
        % AP m đang quá tải → cần loại bỏ một số UE
        % Tìm tất cả UE đang được AP m phục vụ
        servedUEs = find(D_cluster(m,:) == 1);
        
        % Sắp xếp các UE này theo gain tăng dần (yếu nhất trước)
        % Ý tưởng: loại bỏ UE có gain yếu với AP m trước (ít ảnh hưởng nhất)
        % orderUE: vector chứa thứ tự UE từ yếu → mạnh
        % Ví dụ: servedUEs = [1, 5, 8, 12], gain tương ứng [50, 20, 80, 30]
        %        → orderUE = [2, 4, 1, 3] tương ứng UE [5, 12, 1, 8]
        [~, orderUE] = sort(gainLin(m, servedUEs), 'ascend');
        
        % Thử loại bỏ UE yếu nhất trước
        for j = 1:numel(orderUE)
            u = servedUEs(orderUE(j));  % UE đang xét (yếu nhất còn lại)
            
            % Đếm số AP hiện đang phục vụ UE u
            currentAPs = find(D_cluster(:,u));
            
            % Nếu UE u chỉ có đúng N_min AP → KHÔNG thể loại bỏ
            % (vì sẽ vi phạm ràng buộc N_min)
            if numel(currentAPs) <= N_min
                continue;  % bỏ qua UE này, thử UE tiếp theo
            end
            
            % Loại bỏ AP m khỏi danh sách phục vụ UE u
            D_cluster(m, u) = 0;
            loadAP(m) = loadAP(m) - 1;  % giảm tải của AP m
            
            % Cố gắng "bù" cho UE u bằng cách thêm một AP khác
            % (để UE u không bị giảm số AP phục vụ quá nhiều)
            apOrder = ueApOrder{u};  % danh sách AP ưu tiên của UE u
            
            % Duyệt qua các AP ứng viên theo thứ tự ưu tiên
            for cand = apOrder.'
                % Kiểm tra: cand chưa phục vụ u VÀ cand chưa quá tải
                if D_cluster(cand, u) == 0 && loadAP(cand) < L_max
                    % Thêm cand vào phục vụ UE u
                    D_cluster(cand, u) = 1;
                    loadAP(cand) = loadAP(cand) + 1;
                    break;  % chỉ thêm 1 AP thay thế rồi dừng
                end
            end
            
            % Kiểm tra: nếu AP m đã không còn quá tải → dừng loại bỏ UE
            if loadAP(m) <= L_max
                break;  % AP m đã OK, chuyển sang AP khác
            end
        end
        % Sau vòng for j: AP m đã giảm tải (hoặc đã hết UE có thể loại)
    end
    % Sau vòng for idxAP: đã xử lý tất cả AP quá tải trong vòng lặp này
    % Quay lại while để kiểm tra xem còn AP quá tải không
end

% Kết thúc GIAI ĐOẠN 2: D_cluster đã thỏa mãn cả N_min và L_max
% (hoặc đạt maxIter nếu không thể cân bằng hoàn toàn - trường hợp hiếm)

%% Thu thập thống kê về kết quả clustering và cân bằng tải
% Tạo struct chứa các thông tin hữu ích để phân tích

stats.numClusters = numClusters;          % Số cụm đã tạo (ví dụ: 4)
stats.clusterSizes = clusterSizes;        % Vector kích thước từng cụm (ví dụ: [5; 6; 4; 5])
stats.topM = topM;                        % Số AP đầu tiên gán cho mỗi cụm (ví dụ: 6)
stats.targetClusterSize = targetClusterSize; % Kích thước cụm mục tiêu (ví dụ: 5)
stats.L_max = L_max;                      % Tải tối đa cho mỗi AP (ví dụ: 8)
stats.N_min = N_min;                      % Số AP tối thiểu cho mỗi UE (ví dụ: 3)

% Tính tải trung bình trên các AP
% avgLoad = tổng số kết nối (AP-UE pairs) / số AP
% Ví dụ: nếu có 100 AP phục vụ tổng cộng 400 kết nối → avgLoad = 4.0
stats.avgLoad = mean(loadAP);

% Tải cao nhất trên một AP (để kiểm tra xem có AP nào vẫn quá tải)
% Ví dụ: maxLoad = 8 nghĩa là AP bận nhất phục vụ 8 UE
stats.maxLoad = max(loadAP);

% Số vòng lặp đã chạy trong quá trình cân bằng tải
% Ví dụ: iterations = 15 nghĩa là cần 15 vòng để cân bằng tải
stats.iterations = iter;

% Tổng số links (fronthaul load) = tổng số phần tử = 1 trong ma trận D
stats.totalLinks = sum(D_cluster(:));

% In thông tin tổng hợp
fprintf('Proposed DCC: Avg cluster size = %.2f, Avg AP load = %.2f, Total links = %d\n', ...
    mean(sum(D_cluster, 1)), stats.avgLoad, stats.totalLinks);

end
