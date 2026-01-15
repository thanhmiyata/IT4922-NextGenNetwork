%% DEBUG: So sánh số lượng AP được chọn bởi các phương pháp
% Script này giúp xác định nguyên nhân tại sao Threshold và Clustering
% lại cho SE thấp hơn DCC gốc

clear; close all; clc;

% Thêm đường dẫn
addpath('../cell-free-book/code');

%% Tham số hệ thống
L = 100;            % Số AP
K = 20;             % Số UE
N = 1;              % Số anten mỗi AP
tau_p = 10;         % Số pilot
ASD_varphi = 30;    % Azimuth angular standard deviation
ASD_theta = 15;     % Elevation angular standard deviation

% Tham số cho các phương pháp AP selection - TRADE-OFF DESIGN
threshold_ratio = 0.05;  % 5% ~ 13dB (trade-off)
L_max = 30;              % Load balancing
N_min = 15;              % Diversity vs complexity

%% Sinh một setup để kiểm tra
[gainOverNoisedB,R,pilotIndex,D_DCC,D_small] = generateSetup(L,K,N,tau_p,1,0,ASD_varphi,ASD_theta);

% Lấy gain 2D
gainOverNoisedB_2D = gainOverNoisedB(:,:,1);

%% Tạo các ma trận D khác nhau
D_all = ones(L,K);

D_threshold = functionGenerateDCC_improved(gainOverNoisedB_2D, L, K, ...
    threshold_ratio, L_max, N_min);

[D_cluster, stats_cluster] = functionGenerateDCC_clustering(gainOverNoisedB_2D, L, K, ...
    'L_max', L_max, 'N_min', N_min, 'targetClusterSize', 5, 'topM', 6);

%% Phân tích số lượng AP phục vụ mỗi UE
num_APs_all = sum(D_all, 1);           % Mỗi UE: L AP
num_APs_DCC = sum(D_DCC, 1);           % DCC gốc
num_APs_threshold = sum(D_threshold, 1); % Threshold
num_APs_cluster = sum(D_cluster, 1);   % Clustering

fprintf('=== SỐ LƯỢNG AP PHỤC VỤ MỖI UE ===\n\n');
fprintf('Phương pháp        | Trung bình | Min | Max | Tổng links\n');
fprintf('-------------------|------------|-----|-----|------------\n');
fprintf('All APs            |   %6.2f   | %3d | %3d |   %5d\n', mean(num_APs_all), min(num_APs_all), max(num_APs_all), sum(num_APs_all));
fprintf('DCC Gốc            |   %6.2f   | %3d | %3d |   %5d\n', mean(num_APs_DCC), min(num_APs_DCC), max(num_APs_DCC), sum(num_APs_DCC));
fprintf('Threshold          |   %6.2f   | %3d | %3d |   %5d\n', mean(num_APs_threshold), min(num_APs_threshold), max(num_APs_threshold), sum(num_APs_threshold));
fprintf('Clustering         |   %6.2f   | %3d | %3d |   %5d\n\n', mean(num_APs_cluster), min(num_APs_cluster), max(num_APs_cluster), sum(num_APs_cluster));

%% Phân tích tải AP (số UE mà mỗi AP phục vụ)
num_UEs_per_AP_all = sum(D_all, 2);
num_UEs_per_AP_DCC = sum(D_DCC, 2);
num_UEs_per_AP_threshold = sum(D_threshold, 2);
num_UEs_per_AP_cluster = sum(D_cluster, 2);

fprintf('=== TẢI TRÊN MỖI AP (SỐ UE MÀ MỖI AP PHỤC VỤ) ===\n\n');
fprintf('Phương pháp        | Trung bình | Min | Max\n');
fprintf('-------------------|------------|-----|-----\n');
fprintf('All APs            |   %6.2f   | %3d | %3d\n', mean(num_UEs_per_AP_all), min(num_UEs_per_AP_all), max(num_UEs_per_AP_all));
fprintf('DCC Gốc            |   %6.2f   | %3d | %3d\n', mean(num_UEs_per_AP_DCC), min(num_UEs_per_AP_DCC), max(num_UEs_per_AP_DCC));
fprintf('Threshold          |   %6.2f   | %3d | %3d\n', mean(num_UEs_per_AP_threshold), min(num_UEs_per_AP_threshold), max(num_UEs_per_AP_threshold));
fprintf('Clustering         |   %6.2f   | %3d | %3d\n\n', mean(num_UEs_per_AP_cluster), min(num_UEs_per_AP_cluster), max(num_UEs_per_AP_cluster));

%% Kiểm tra ràng buộc N_min
violations_threshold = sum(num_APs_threshold < N_min);
violations_cluster = sum(num_APs_cluster < N_min);

fprintf('=== KIỂM TRA RÀNG BUỘC N_min = %d ===\n\n', N_min);
fprintf('Threshold: %d UE vi phạm (< %d AP)\n', violations_threshold, N_min);
fprintf('Clustering: %d UE vi phạm (< %d AP)\n\n', violations_cluster, N_min);

%% Kiểm tra ràng buộc L_max
violations_L_max_threshold = sum(num_UEs_per_AP_threshold > L_max);
violations_L_max_cluster = sum(num_UEs_per_AP_cluster > L_max);

fprintf('=== KIỂM TRA RÀNG BUỘC L_max = %d ===\n\n', L_max);
fprintf('Threshold: %d AP vi phạm (> %d UE)\n', violations_L_max_threshold, L_max);
fprintf('Clustering: %d AP vi phạm (> %d UE)\n\n', violations_L_max_cluster, L_max);

%% So sánh chi tiết cho 5 UE đầu tiên
fprintf('=== CHI TIẾT 5 UE ĐẦU TIÊN ===\n\n');
fprintf('UE | All | DCC | Threshold | Clustering\n');
fprintf('---|-----|-----|-----------|------------\n');
for k = 1:min(5,K)
    fprintf('%2d | %3d | %3d |    %3d    |    %3d\n', k, ...
        num_APs_all(k), num_APs_DCC(k), num_APs_threshold(k), num_APs_cluster(k));
end

% KHÔNG VẼ HÌNH để tránh crash
fprintf('\n✅ Hoàn tất phân tích\n');
