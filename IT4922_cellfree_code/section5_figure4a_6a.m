%This Matlab script can be used to reproduce Figures 5.4(a) and 5.6(a) in the monograph:
%
%Ozlem Tugfe Demir, Emil Bjornson and Luca Sanguinetti (2021),
%"Foundations of User-Centric Cell-Free Massive MIMO", 
%Foundations and Trends in Signal Processing: Vol. 14: No. 3-4,
%pp 162-472. DOI: 10.1561/2000000109
%
%This is version 1.0 (Last edited: 2021-01-31)
%
%License: This code is licensed under the GPLv2 license. If you in any way
%use this code for research that results in publications, please cite our
%monograph as described above.

% Script này là phiên bản "full-scale" của mô phỏng Hình 5.4(a) và 5.6(a)
% bao gồm cả phương án DCC gốc và DCC đề xuất (threshold + load balancing).
% Tham số được giữ giống sách (L=400, K=40, 196 setups, 1000 realizations),
% nên thời gian chạy sẽ lâu hơn so với phiên bản "proposed" rút gọn.

% Đóng tất cả figure và xóa biến trong workspace để tránh ảnh hưởng từ lần chạy trước
close all;
clear;


%% Define simulation setup
% Thiết lập kịch bản mô phỏng theo đúng cấu hình trong sách

% Số lượng cấu hình Monte-Carlo (bố trí khác nhau của AP/UE)
nbrOfSetups = 196;

% Số lượng hiện thực small-scale fading trên mỗi cấu hình
nbrOfRealizations = 1000;

% Số lượng AP trong mạng
L = 400;

% Số anten trên mỗi AP
N = 1;

% Số lượng UE trong mạng
K = 40;

% Độ dài coherence block
tau_c = 200;

% Độ dài pilot
tau_p = 10;

% Độ lệch chuẩn góc (local scattering) theo radian
ASD_varphi = deg2rad(15);  % azimuth angle
ASD_theta = deg2rad(15);   % elevation angle

%% Parameters for proposed DCC scheme (threshold + load balancing)
% Tham số cho thuật toán AP selection đề xuất
threshold_ratio = 0.1;  % Ngưỡng = 10% so với gain lớn nhất của mỗi UE
L_max = 8;              % Mỗi AP phục vụ tối đa 8 UE
N_min = 3;              % Mỗi UE phải có ít nhất 3 AP phục vụ

%% Propagation parameters

% Công suất phát uplink của mỗi UE (mW)
p = 100;

% Khởi tạo các ma trận lưu SE cho từng scheme và từng setup
SE_MMSE_original = zeros(K,nbrOfSetups); % MMSE (All)
SE_MMSE_DCC = zeros(K,nbrOfSetups);      % MMSE (DCC)
SE_PMMSE_DCC = zeros(K,nbrOfSetups);     % P-MMSE (DCC)
SE_PRZF_DCC = zeros(K,nbrOfSetups);      % P-RZF (DCC)
SE_MR_DCC = zeros(K,nbrOfSetups);        % MR (DCC)

% Proposed DCC (threshold + load balancing)
SE_PMMSE_PROPOSED = zeros(K,nbrOfSetups);      % P-MMSE (Proposed DCC)
SE_nopt_LPMMSE_PROPOSED = zeros(K,nbrOfSetups);% n-opt LSFD, LP-MMSE (Proposed DCC)

% Clustering DCC (affinity clustering on gain map)
SE_PMMSE_CLUSTERING = zeros(K,nbrOfSetups);       % P-MMSE (Clustering DCC)
SE_nopt_LPMMSE_CLUSTERING = zeros(K,nbrOfSetups); % n-opt LSFD, LP-MMSE (Clustering DCC)

% Các scheme dựa trên LSFD + L-MMSE/LP-MMSE/MR
SE_opt_LMMSE_original = zeros(K,nbrOfSetups); % opt LSFD, L-MMSE (All)
SE_opt_LMMSE_DCC = zeros(K,nbrOfSetups);      % opt LSFD, L-MMSE (DCC)
SE_nopt_LPMMSE_DCC = zeros(K,nbrOfSetups);    % n-opt LSFD, LP-MMSE (DCC)
SE_nopt_MR_DCC = zeros(K,nbrOfSetups);        % n-opt LSFD, MR (DCC)


%% Go through all setups
for n = 1:nbrOfSetups
    
    % In tiến độ mô phỏng
    disp(['Setup ' num2str(n) ' out of ' num2str(nbrOfSetups)]);
    
    % Sinh 1 cấu hình: vị trí AP/UE ngẫu nhiên, large-scale fading, pilot, D (DCC gốc)
    [gainOverNoisedB,R,pilotIndex,D,D_small] = generateSetup(L,K,N,tau_p,1,0,ASD_varphi,ASD_theta);
    
    % Sinh small-scale fading + ước lượng kênh (Hhat), kênh thật (H), covariance B,C
    [Hhat,H,B,C] = functionChannelEstimates(R,nbrOfRealizations,L,K,N,tau_p,pilotIndex,p);
    
    %% Original Cell-Free Massive MIMO (All APs serve all UEs)
    % Ma trận D_all toàn 1: mỗi AP phục vụ tất cả UE
    D_all = ones(L,K);
    
    % Tính SE cho nhiều scheme (MMSE, P-MMSE, P-RZF, MR, LSFD...) khi D_all
    [SE_MMSE_all, SE_P_MMSE_all, SE_P_RZF_all, SE_MR_cent_all, ...
        SE_opt_L_MMSE_all,SE_nopt_LP_MMSE_all, SE_nopt_MR_all, ...
        SE_L_MMSE_all, SE_LP_MMSE_all, SE_MR_dist_all, ...
        Gen_SE_P_MMSE_all, Gen_SE_P_RZF_all, Gen_SE_LP_MMSE_all, Gen_SE_MR_dist_all,...
        SE_small_MMSE_all, Gen_SE_small_MMSE_all] ...
        = functionComputeSE_uplink(Hhat,H,D_all,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu hai đường: MMSE (All) và opt LSFD, L-MMSE (All)
    SE_MMSE_original(:,n) = SE_MMSE_all;
    SE_opt_LMMSE_original(:,n) = SE_opt_L_MMSE_all;
    
    %% Cell-Free Massive MIMO with DCC (original)
    % Tính SE cho DCC gốc (ma trận D từ generateSetup)
    [SE_MMSE, SE_P_MMSE, SE_P_RZF, SE_MR_cent, ...
        SE_opt_L_MMSE,SE_nopt_LP_MMSE, SE_nopt_MR, ...
        SE_L_MMSE, SE_LP_MMSE, SE_MR_dist, ...
        Gen_SE_P_MMSE, Gen_SE_P_RZF, Gen_SE_LP_MMSE, Gen_SE_MR_dist,...
        SE_small_MMSE, Gen_SE_small_MMSE] ...
        = functionComputeSE_uplink(Hhat,H,D,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu SE cho các scheme chính của DCC gốc
    SE_MMSE_DCC(:,n) =  SE_MMSE;
    SE_PMMSE_DCC(:,n) = SE_P_MMSE;
    SE_PRZF_DCC(:,n) = SE_P_RZF;
    SE_MR_DCC(:,n) =  SE_MR_cent;
    SE_opt_LMMSE_DCC(:,n) =  SE_opt_L_MMSE;
    SE_nopt_LPMMSE_DCC(:,n) =  SE_nopt_LP_MMSE;
    SE_nopt_MR_DCC(:,n) =  SE_nopt_MR;

    %% Cell-Free Massive MIMO with proposed DCC (threshold + load balancing)
    % Lấy gainOverNoisedB 2D (L x K) của setup hiện tại để sinh D đề xuất
    gainOverNoisedB_2D = gainOverNoisedB(:,:,1); % L x K
    
    % Sinh D_proposed theo thuật toán threshold + load balancing
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
    
    %% Cell-Free Massive MIMO with clustering-based DCC
    % Sinh D dựa trên affinity clustering của UE theo gain vector
    [D_cluster, ~] = functionGenerateDCC_clustering(gainOverNoisedB_2D, L, K, ...
        'L_max', L_max, 'N_min', N_min, 'targetClusterSize', 5, 'topM', 6);
    
    % Tính SE cho D_cluster
    [~, SE_P_MMSE_clust, ~, ~, ...
        ~, SE_nopt_LP_MMSE_clust, ~, ...
        ~, ~, ~, ...
        ~, ~, ~, ~, ~, ~] ...
        = functionComputeSE_uplink(Hhat,H,D_cluster,D_small,B,C,tau_c,...
        tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    SE_PMMSE_CLUSTERING(:,n) = SE_P_MMSE_clust;
    SE_nopt_LPMMSE_CLUSTERING(:,n) = SE_nopt_LP_MMSE_clust;
    
    % Giải phóng bộ nhớ lớn trước khi sang setup tiếp theo
    clear Hhat H B C R;
    
end


%% Plot simulation results
% Plot Figure 5.4(a)
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
legend({'MMSE (All)','MMSE (DCC)','P-MMSE (DCC)','P-MMSE (Proposed)','P-MMSE (Clustering)','P-RZF (DCC)','MR (DCC)'},'Interpreter','Latex','Location','SouthEast');
xlim([0 12]);

% Plot Figure 5.6(a)
figure;
hold on; box on;
set(gca,'fontsize',16);

plot(sort(SE_opt_LMMSE_original(:)),linspace(0,1,K*nbrOfSetups),'k-','LineWidth',2);
plot(sort(SE_opt_LMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'r-.','LineWidth',2);
plot(sort(SE_nopt_LPMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',2);
plot(sort(SE_nopt_MR_DCC(:)),linspace(0,1,K*nbrOfSetups),'b--','LineWidth',2);

xlabel('Spectral efficiency [bit/s/Hz]','Interpreter','Latex');
ylabel('CDF','Interpreter','Latex');
legend({'opt LSFD, L-MMSE (All)','opt LSFD, L-MMSE (DCC)','n-opt LSFD, LP-MMSE (DCC)','n-opt LSFD, MR (DCC)'},'Interpreter','Latex','Location','SouthEast');
xlim([0 12]);
