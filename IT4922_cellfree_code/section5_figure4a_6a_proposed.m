% This Matlab script is a modified version of section5_figure4a_6a.m
% used to reproduce Figures 5.4(a) and 5.6(a) in:
%
% Ozlem Tugfe Demir, Emil Bjornson and Luca Sanguinetti (2021),
% "Foundations of User-Centric Cell-Free Massive MIMO", 
% Foundations and Trends in Signal Processing: Vol. 14: No. 3-4,
% pp 162-472. DOI: 10.1561/2000000109
%
% Phiên bản này bổ sung thêm một đường cong cho
% phương án DCC đề xuất (proposed DCC) dựa trên chọn AP theo ngưỡng
% (threshold-based AP selection) kết hợp với cân bằng tải (load balancing).
%
% Cách chạy script này nhanh:
% 1) Đặt thư mục hiện tại và thư mục "cell-free-book" gốc
%    trong cùng một thư mục cha.
% 2) Trong Matlab, cd vào thư mục này:
%       >> cd IT4922_cellfree_code
%       >> run('section5_figure4a_6a_proposed.m')

% Xóa tất cả figure đang mở và biến trong workspace để bắt đầu từ trạng thái sạch
close all;
clear;

% Thêm đường dẫn tới thư mục code gốc của sách (chứa generateSetup, functionComputeSE_uplink, ...)
addpath('../cell-free-book/code');


%% Define simulation setup
% Định nghĩa kịch bản mô phỏng (phiên bản giảm kích thước để chạy nhanh)

% Số lượng cấu hình Monte-Carlo (mỗi cấu hình có vị trí AP/UE khác nhau)
nbrOfSetups = 20;  % Giảm từ 196 để thử nhanh

% Số lượng hiện thực small-scale fading trên mỗi cấu hình
nbrOfRealizations = 50;  % Giảm từ 1000 để thử nhanh

% Số lượng AP trong mạng (mỗi AP có 1 anten)
L = 100;  % Giảm từ 400 để thử nhanh

% Số anten trên mỗi AP
N = 1;

% Số lượng UE trong mạng
K = 20;  % Giảm từ 40 để thử nhanh

% Độ dài coherence block (symbol)
tau_c = 200;

% Độ dài pilot (symbol)
tau_p = 10;

% Độ lệch chuẩn góc (local scattering) theo radian
ASD_varphi = deg2rad(15);  % góc phương vị (azimuth)
ASD_theta = deg2rad(15);   % góc phương thăng (elevation)

%% Parameters for proposed DCC scheme (threshold + load balancing)
% Các tham số điều khiển thuật toán chọn AP theo ngưỡng và cân bằng tải
% TRADE-OFF DESIGN: Giảm fronthaul load (ít AP hơn DCC gốc) để đổi lấy SE cao nhất có thể
% DCC gốc: ~50 AP/UE (pilot-based, 1000 total links)
% Threshold: ~20 AP/UE (threshold-based, ~400 links = -60% fronthaul)
threshold_ratio = 0.05;  % Ngưỡng = 5% ~ 13dB (vừa phải, không quá lỏng)
L_max = 30;              % Mỗi AP phục vụ tối đa 30 UE (cho phép load balancing)
N_min = 15;              % Mỗi UE có ít nhất 15 AP (đủ diversity, không quá nhiều)


%% Propagation parameters

% Công suất phát uplink của mỗi UE (mW)
p = 100;

% Khởi tạo các ma trận lưu SE (K x nbrOfSetups) cho từng scheme
% MMSE (All APs), MMSE/P-MMSE/P-RZF/MR (DCC gốc), và Proposed DCC
SE_MMSE_original = zeros(K,nbrOfSetups); % MMSE (All)
SE_MMSE_DCC = zeros(K,nbrOfSetups);      % MMSE (DCC)
SE_PMMSE_DCC = zeros(K,nbrOfSetups);     % P-MMSE (DCC)
SE_PRZF_DCC = zeros(K,nbrOfSetups);      % P-RZF (DCC)
SE_MR_DCC = zeros(K,nbrOfSetups);        % MR (DCC)

% SE cho phương án DCC đề xuất (threshold + load balancing)
SE_PMMSE_PROPOSED = zeros(K,nbrOfSetups);       % P-MMSE (Proposed DCC)
SE_nopt_LPMMSE_PROPOSED = zeros(K,nbrOfSetups); % n-opt LSFD, LP-MMSE (Proposed DCC)

% SE cho phương án DCC dựa trên clustering (affinity clustering)
SE_PMMSE_CLUSTERING = zeros(K,nbrOfSetups);       % P-MMSE (Clustering DCC)
SE_nopt_LPMMSE_CLUSTERING = zeros(K,nbrOfSetups); % n-opt LSFD, LP-MMSE (Clustering DCC)

% SE cho các scheme LSFD + L-MMSE/LP-MMSE/MR
SE_opt_LMMSE_original = zeros(K,nbrOfSetups); % opt LSFD, L-MMSE (All)
SE_opt_LMMSE_DCC = zeros(K,nbrOfSetups);      % opt LSFD, L-MMSE (DCC)
SE_nopt_LPMMSE_DCC = zeros(K,nbrOfSetups);    % n-opt LSFD, LP-MMSE (DCC)
SE_nopt_MR_DCC = zeros(K,nbrOfSetups);        % n-opt LSFD, MR (DCC)

% Biến lưu fronthaul load (tổng qua tất cả setups)
links_all_total = 0;
links_DCC_total = 0;
links_threshold_total = 0;
links_cluster_total = 0;

%% Go through all setups
for n = 1:nbrOfSetups
    
    % In tiến độ mô phỏng để biết đang ở setup thứ mấy
    disp(['Setup ' num2str(n) ' out of ' num2str(nbrOfSetups)]);
    
    % Sinh một cấu hình: vị trí AP/UE ngẫu nhiên, large-scale fading, pilot, D (DCC gốc)
    [gainOverNoisedB,R,pilotIndex,D,D_small] = generateSetup(L,K,N,tau_p,1,0,ASD_varphi,ASD_theta);
    
    % Sinh các hiện thực kênh small-scale + ước lượng kênh (Hhat), kênh thật (H),
    % và covariance của ước lượng/sai số (B,C)
    [Hhat,H,B,C] = functionChannelEstimates(R,nbrOfRealizations,L,K,N,tau_p,pilotIndex,p);
    
    %% Original Cell-Free Massive MIMO
    
    % Trường hợp lý tưởng: mọi AP phục vụ mọi UE
    D_all = ones(L,K);
    
    
    % Tính SE (uplink) cho nhiều scheme: MMSE, P-MMSE, P-RZF, MR, LSFD...
    % khi D_all = 1 (All APs serve all UEs)
    [SE_MMSE_all, SE_P_MMSE_all, SE_P_RZF_all, SE_MR_cent_all, ...
        SE_opt_L_MMSE_all,SE_nopt_LP_MMSE_all, SE_nopt_MR_all, ...
        SE_L_MMSE_all, SE_LP_MMSE_all, SE_MR_dist_all, ...
        Gen_SE_P_MMSE_all, Gen_SE_P_RZF_all, Gen_SE_LP_MMSE_all, Gen_SE_MR_dist_all,...
        SE_small_MMSE_all, Gen_SE_small_MMSE_all] ...
        = functionComputeSE_uplink(Hhat,H,D_all,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu hai đường cần vẽ: MMSE (All) và opt LSFD, L-MMSE (All)
    SE_MMSE_original(:,n) = SE_MMSE_all;
    SE_opt_LMMSE_original(:,n) = SE_opt_L_MMSE_all;
    
    %% Cell-Free Massive MIMO with DCC (original scheme)
    
    % Tính SE cho DCC gốc (ma trận D từ generateSetup)
    [SE_MMSE, SE_P_MMSE, SE_P_RZF, SE_MR_cent, ...
        SE_opt_L_MMSE,SE_nopt_LP_MMSE, SE_nopt_MR, ...
        SE_L_MMSE, SE_LP_MMSE, SE_MR_dist, ...
        Gen_SE_P_MMSE, Gen_SE_P_RZF, Gen_SE_LP_MMSE, Gen_SE_MR_dist,...
        SE_small_MMSE, Gen_SE_small_MMSE] ...
        = functionComputeSE_uplink(Hhat,H,D,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu SE cho các scheme chính dưới DCC gốc
    SE_MMSE_DCC(:,n) =  SE_MMSE;
    SE_PMMSE_DCC(:,n) = SE_P_MMSE;
    SE_PRZF_DCC(:,n) = SE_P_RZF;
    SE_MR_DCC(:,n) =  SE_MR_cent;
    SE_opt_LMMSE_DCC(:,n) =  SE_opt_L_MMSE;
    SE_nopt_LPMMSE_DCC(:,n) =  SE_nopt_LP_MMSE;
    SE_nopt_MR_DCC(:,n) =  SE_nopt_MR;
    
    %% Cell-Free Massive MIMO with proposed DCC (threshold + load balancing)
    % Lấy large-scale fading (gainOverNoisedB) 2D của setup hiện tại
    gainOverNoisedB_2D = gainOverNoisedB(:,:,1); % L x K
    
    % Sinh ma trận D đề xuất: threshold + load balancing
    D_proposed = functionGenerateDCC_improved(gainOverNoisedB_2D, L, K, ...
        threshold_ratio, L_max, N_min);
    
    % Tính SE cho D_proposed (chỉ lấy P-MMSE và n-opt LSFD, LP-MMSE)
    [~, SE_P_MMSE_prop, ~, ~, ...
        ~, SE_nopt_LP_MMSE_prop, ~, ...
        ~, ~, ~, ...
        ~, ~, ~, ~, ~, ~] ...
        = functionComputeSE_uplink(Hhat,H,D_proposed,D_small,B,C,tau_c,...
        tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    SE_PMMSE_PROPOSED(:,n) = SE_P_MMSE_prop;
    SE_nopt_LPMMSE_PROPOSED(:,n) = SE_nopt_LP_MMSE_prop;
    
    %% Cell-Free Massive MIMO with clustering-based DCC (affinity clustering)
    % Sinh ma trận D dựa trên clustering UE theo gain vector
    [D_cluster, ~] = functionGenerateDCC_clustering(gainOverNoisedB_2D, L, K, ...
        'L_max', L_max, 'N_min', N_min, 'targetClusterSize', 5, 'topM', 6);
    
    % Tính SE cho D_cluster (chỉ lấy P-MMSE và n-opt LSFD, LP-MMSE)
    [~, SE_P_MMSE_clust, ~, ~, ...
        ~, SE_nopt_LP_MMSE_clust, ~, ...
        ~, ~, ~, ...
        ~, ~, ~, ~, ~, ~] ...
        = functionComputeSE_uplink(Hhat,H,D_cluster,D_small,B,C,tau_c,...
        tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
        SE_PMMSE_CLUSTERING(:,n) = SE_P_MMSE_clust;
    SE_nopt_LPMMSE_CLUSTERING(:,n) = SE_nopt_LP_MMSE_clust;
    
    %% Tính fronthaul load (số links) cho setup này
    links_all = sum(D_all(:));
    links_DCC = sum(D(:));
    links_threshold = sum(D_proposed(:));
    links_cluster = sum(D_cluster(:));
    
    % Cộng dồn để tính trung bình sau
    links_all_total = links_all_total + links_all;
    links_DCC_total = links_DCC_total + links_DCC;
    links_threshold_total = links_threshold_total + links_threshold;
    links_cluster_total = links_cluster_total + links_cluster;
    
    if n == 1
        % In kết quả cho setup đầu tiên
        fprintf('\n=== FRONTHAUL LOAD (Setup %d) ===\n', n);
        fprintf('Phương pháp    | Total Links | AP/UE | Reduction vs DCC\n');
        fprintf('---------------|-------------|-------|------------------\n');
        fprintf('All APs        |    %5d    | %5.1f |      --\n', links_all, links_all/K);
        fprintf('DCC Gốc        |    %5d    | %5.1f |      0%% (baseline)\n', links_DCC, links_DCC/K);
        fprintf('Threshold      |    %5d    | %5.1f |    %.1f%%\n', links_threshold, links_threshold/K, 100*(links_DCC-links_threshold)/links_DCC);
        fprintf('Clustering     |    %5d    | %5.1f |    %.1f%%\n\n', links_cluster, links_cluster/K, 100*(links_DCC-links_cluster)/links_DCC);
    end
    
    % Giải phóng bộ nhớ lớn trước khi sang setup kế
    clear Hhat H B C R;
    
end

%% Tính và in fronthaul load trung bình qua tất cả setups
links_all_avg = links_all_total / nbrOfSetups;
links_DCC_avg = links_DCC_total / nbrOfSetups;
links_threshold_avg = links_threshold_total / nbrOfSetups;
links_cluster_avg = links_cluster_total / nbrOfSetups;

fprintf('\n=== FRONTHAUL LOAD TRUNG BÌNH (%d setups) ===\n', nbrOfSetups);
fprintf('Phương pháp    | Avg Links | Avg AP/UE | Reduction vs DCC | Chi phí ($1000/link)\n');
fprintf('---------------|-----------|-----------|------------------|---------------------\n');
fprintf('All APs        |   %6.1f  |   %5.1f   |       --         |   $%6.0fK\n', links_all_avg, links_all_avg/K, links_all_avg);
fprintf('DCC Gốc        |   %6.1f  |   %5.1f   |       0%%         |   $%6.0fK (baseline)\n', links_DCC_avg, links_DCC_avg/K, links_DCC_avg);
fprintf('Threshold      |   %6.1f  |   %5.1f   |     %.1f%%       |   $%6.0fK (tiết kiệm $%.0fK)\n', ...
    links_threshold_avg, links_threshold_avg/K, 100*(links_DCC_avg-links_threshold_avg)/links_DCC_avg, ...
    links_threshold_avg, (links_DCC_avg-links_threshold_avg));
fprintf('Clustering     |   %6.1f  |   %5.1f   |     %.1f%%       |   $%6.0fK (tiết kiệm $%.0fK)\n\n', ...
    links_cluster_avg, links_cluster_avg/K, 100*(links_DCC_avg-links_cluster_avg)/links_DCC_avg, ...
    links_cluster_avg, (links_DCC_avg-links_cluster_avg));


%% Plot simulation results
% Plot Figure 5.4(a) - so sánh All, DCC gốc, và DCC đề xuất (đường xanh)
figure;
hold on; box on;
set(gca,'fontsize',16);

plot(sort(SE_MMSE_original(:)),linspace(0,1,K*nbrOfSetups),'k-','LineWidth',2);
plot(sort(SE_MMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'r-.','LineWidth',2);
plot(sort(SE_PMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',2);
plot(sort(SE_PMMSE_PROPOSED(:)),linspace(0,1,K*nbrOfSetups),'g-','LineWidth',2);
plot(sort(SE_PMMSE_CLUSTERING(:)),linspace(0,1,K*nbrOfSetups),'m-','LineWidth',2);
plot(sort(SE_PRZF_DCC(:)),linspace(0,1,K*nbrOfSetups),'b--','LineWidth',2);
plot(sort(SE_MR_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',3);

xlabel('Spectral efficiency [bit/s/Hz]','Interpreter','Latex');
ylabel('CDF','Interpreter','Latex');
legend({'MMSE (All)','MMSE (DCC)','P-MMSE (DCC)','P-MMSE (Threshold)','P-MMSE (Clustering)','P-RZF (DCC)','MR (DCC)'},...
    'Interpreter','Latex','Location','SouthEast');
xlim([0 12]);
saveas(gcf, 'figure5_4a.png');
disp('Saved figure5_4a.png');

% Plot Figure 5.6(a) - LSFD schemes bao gồm cả Threshold và Clustering
figure;
hold on; box on;
set(gca,'fontsize',16);

plot(sort(SE_opt_LMMSE_original(:)),linspace(0,1,K*nbrOfSetups),'k-','LineWidth',2);
plot(sort(SE_opt_LMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'r-.','LineWidth',2);
plot(sort(SE_nopt_LPMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',2);
plot(sort(SE_nopt_LPMMSE_PROPOSED(:)),linspace(0,1,K*nbrOfSetups),'g-','LineWidth',2);
plot(sort(SE_nopt_LPMMSE_CLUSTERING(:)),linspace(0,1,K*nbrOfSetups),'m-','LineWidth',2);
plot(sort(SE_nopt_MR_DCC(:)),linspace(0,1,K*nbrOfSetups),'b--','LineWidth',2);

xlabel('Spectral efficiency [bit/s/Hz]','Interpreter','Latex');
ylabel('CDF','Interpreter','Latex');
legend({'opt LSFD, L-MMSE (All)','opt LSFD, L-MMSE (DCC)',...
    'n-opt LSFD, LP-MMSE (DCC)','n-opt LSFD, LP-MMSE (Threshold)',...
    'n-opt LSFD, LP-MMSE (Clustering)','n-opt LSFD, MR (DCC)'},...
    'Interpreter','Latex','Location','SouthEast');
xlim([0 12]);
saveas(gcf, 'figure5_6a.png');
disp('Saved figure5_6a.png');

