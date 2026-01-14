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

% Xóa toàn bộ các cửa sổ figure đang mở để bắt đầu mô phỏng với giao diện sạch
close all;
% Xóa toàn bộ biến trong workspace để tránh ảnh hưởng từ các lần chạy trước
clear;

% Thêm đường dẫn tới thư mục chứa các hàm gốc của sách (generateSetup, functionComputeSE_uplink, ...)
addpath('../cell-free-book/code');


%% Define simulation setup
% Phần này định nghĩa các tham số chính của hệ thống Cell-Free Massive MIMO

% Số lượng cấu hình Monte-Carlo (mỗi cấu hình tương ứng với một bố trí ngẫu nhiên của AP và UE)
nbrOfSetups = 20;  % REDUCED for faster testing (bản gốc thường lớn hơn, ví dụ 196)

% Số lượng hiện thực kênh small-scale fading trên mỗi cấu hình
nbrOfRealizations = 50;  % REDUCED for faster testing (bản gốc dùng 1000)

% Số lượng AP trong mạng (mỗi AP có vị trí riêng, được sinh ngẫu nhiên trong generateSetup)
L = 100;  % REDUCED for faster testing

% Số anten trên mỗi AP (ở đây mỗi AP chỉ có 1 anten để đơn giản hóa)
N = 1;

% Số lượng UE trong mạng
K = 20;  % REDUCED for faster testing

% Độ dài block tương quan (coherence block) tính theo số symbol
% Trong một coherence block, large-scale fading và small-scale fading được coi là không đổi
tau_c = 200;

% Độ dài chuỗi pilot (số symbol dùng cho ước lượng kênh trong mỗi coherence block)
tau_p = 10;

% Độ lệch chuẩn góc trong mô hình tán xạ cục bộ (local scattering), đơn vị radian
% ASD_varphi: góc phương vị (azimuth), ASD_theta: góc phương thăng (elevation)
ASD_varphi = deg2rad(15);  % azimuth angle, đổi từ 15 độ sang radian
ASD_theta = deg2rad(15);   % elevation angle, đổi từ 15 độ sang radian

%% Propagation parameters
% Các tham số liên quan đến công suất phát và lan truyền kênh

% Tổng công suất phát uplink của mỗi UE (theo đơn vị mW)
p = 100;

% Chuẩn bị các ma trận để lưu kết quả Spectral Efficiency (SE) cho từng UE và từng setup
% Mỗi ma trận có kích thước K x nbrOfSetups, cột thứ n tương ứng với setup thứ n

% SE cho trường hợp MMSE combiner với cấu hình "All APs serve all UEs" (không DCC)
SE_MMSE_original = zeros(K,nbrOfSetups); % MMSE (All)
% SE cho MMSE combiner với cấu hình DCC (Dynamic Cell-free Clustering)
SE_MMSE_DCC = zeros(K,nbrOfSetups);      % MMSE (DCC)
% SE cho P-MMSE (một biến thể practical/partial của MMSE) với DCC
SE_PMMSE_DCC = zeros(K,nbrOfSetups);     % P-MMSE (DCC)
% SE cho P-RZF (Regularized Zero-Forcing) với DCC
SE_PRZF_DCC = zeros(K,nbrOfSetups);      % P-RZF (DCC)
% SE cho MR (Maximum Ratio) combiner với DCC
SE_MR_DCC = zeros(K,nbrOfSetups);        % MR (DCC)

% SE cho trường hợp tối ưu LSFD + Local MMSE khi tất cả AP phục vụ tất cả UE
SE_opt_LMMSE_original = zeros(K,nbrOfSetups); % opt LSFD, L-MMSE (All)
% SE cho opt LSFD + Local MMSE trong cấu hình DCC
SE_opt_LMMSE_DCC = zeros(K,nbrOfSetups);      % opt LSFD, L-MMSE (DCC)
% SE cho non-optimal LSFD + LP-MMSE (Local Partial MMSE) trong DCC
SE_nopt_LPMMSE_DCC = zeros(K,nbrOfSetups);    % n-opt LSFD, LP-MMSE (DCC)
% SE cho non-optimal LSFD + MR trong DCC
SE_nopt_MR_DCC = zeros(K,nbrOfSetups);        % n-opt LSFD, MR (DCC)


%% Go through all setups
% Vòng lặp chính trên các cấu hình Monte-Carlo khác nhau (khác nhau về vị trí AP/UE và large-scale fading)
for n = 1:nbrOfSetups
    
    % Hiển thị tiến độ mô phỏng trên Command Window: "Setup n out of nbrOfSetups"
    disp(['Setup ' num2str(n) ' out of ' num2str(nbrOfSetups)]);
    
    % Sinh một cấu hình mạng: vị trí ngẫu nhiên của UEs và APs, large-scale fading, pilot, và ma trận D cho DCC
    % gainOverNoisedB: ma trận (L x K x ?) thể hiện gain/noise theo dB
    % R: các ma trận tương quan kênh (large-scale correlation)
    % pilotIndex: chỉ số pilot của từng UE (kích thước K x 1)
    % D: ma trận DCC (L x K), D(m,k)=1 nếu AP m phục vụ UE k
    % D_small: ma trận D cho trường hợp "small" được dùng trong một số phân tích khác
    [gainOverNoisedB,R,pilotIndex,D,D_small] = generateSetup(L,K,N,tau_p,1,0,ASD_varphi,ASD_theta);
    
    % Sinh các hiện thực kênh small-scale và ước lượng kênh tương ứng, cùng với ma trận covariance của ước lượng
    % Hhat: ước lượng kênh (theo mô hình LMMSE), dùng cho precoding/combining
    % H: kênh thực (ground truth), dùng trong bước tính toán hiệu năng
    % B: covariance của ước lượng kênh
    % C: covariance của sai số ước lượng kênh
    [Hhat,H,B,C] = functionChannelEstimates(R,nbrOfRealizations,L,K,N,tau_p,pilotIndex,p);
    
    %% Original Cell-Free Massive MIMO
    % Phần này xét trường hợp lý tưởng: tất cả AP đều phục vụ tất cả UE (không clustering)
    
    % Khai báo ma trận D_all = 1 (L x K), nghĩa là AP m phục vụ mọi UE k
    D_all = ones(L,K);
    
    
    % Tính SE sử dụng các kiểu combining/decoding được trình bày ở Section 5 (sách)
    % cho uplink với xử lý tập trung và phân tán, trong trường hợp D_all (All APs serve all UEs)
    [SE_MMSE_all, SE_P_MMSE_all, SE_P_RZF_all, SE_MR_cent_all, ...
        SE_opt_L_MMSE_all,SE_nopt_LP_MMSE_all, SE_nopt_MR_all, ...
        SE_L_MMSE_all, SE_LP_MMSE_all, SE_MR_dist_all, ...
        Gen_SE_P_MMSE_all, Gen_SE_P_RZF_all, Gen_SE_LP_MMSE_all, Gen_SE_MR_dist_all,...
        SE_small_MMSE_all, Gen_SE_small_MMSE_all] ...
        = functionComputeSE_uplink(Hhat,H,D_all,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu lại SE cho hai đường cần vẽ trong Figure 5.4(a) và 5.6(a):
    % 1) MMSE (All)
    % 2) opt LSFD, L-MMSE (All)
    SE_MMSE_original(:,n) = SE_MMSE_all;
    SE_opt_LMMSE_original(:,n) = SE_opt_L_MMSE_all;
    
    %% Cell-Free Massive MIMO with DCC
    % Phần này xét trường hợp thực tế hơn: mỗi UE chỉ được phục vụ bởi một tập con AP (DCC)
    
    % Tính SE sử dụng các kiểu combining/decoding tương tự, nhưng với ma trận D (DCC)
    [SE_MMSE, SE_P_MMSE, SE_P_RZF, SE_MR_cent, ...
        SE_opt_L_MMSE,SE_nopt_LP_MMSE, SE_nopt_MR, ...
        SE_L_MMSE, SE_LP_MMSE, SE_MR_dist, ...
        Gen_SE_P_MMSE, Gen_SE_P_RZF, Gen_SE_LP_MMSE, Gen_SE_MR_dist,...
        SE_small_MMSE, Gen_SE_small_MMSE] ...
        = functionComputeSE_uplink(Hhat,H,D,D_small,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex);
    
    % Lưu SE cho các scheme chính trong cấu hình DCC để dùng cho việc vẽ Hình 5.4(a), 5.6(a)
    % "MMSE (DCC)", "P-MMSE (DCC)", "P-RZF (DCC)", "MR (DCC)",
    % "opt LSFD, L-MMSE (DCC)", "n-opt LSFD, LP-MMSE (DCC)",
    % và "n-opt LSFD, MR (DCC)"
    SE_MMSE_DCC(:,n) =  SE_MMSE;
    SE_PMMSE_DCC(:,n) = SE_P_MMSE;
    SE_PRZF_DCC(:,n) = SE_P_RZF;
    SE_MR_DCC(:,n) =  SE_MR_cent;
    SE_opt_LMMSE_DCC(:,n) =  SE_opt_L_MMSE;
    SE_nopt_LPMMSE_DCC(:,n) =  SE_nopt_LP_MMSE;
    SE_nopt_MR_DCC(:,n) =  SE_nopt_MR;
    
    % Giải phóng bộ nhớ cho các ma trận kênh lớn trước khi chuyển sang setup tiếp theo
    clear Hhat H B C R;
    
end


%% Plot simulation results
% Phần này vẽ các kết quả mô phỏng dưới dạng CDF của SE để tái tạo lại Figures 5.4(a) và 5.6(a)

% Plot Figure 5.4(a) - so sánh các scheme MMSE/P-MMSE/P-RZF/MR giữa All APs và DCC
figure;              % Tạo một cửa sổ figure mới
hold on; box on;     % Giữ các đường vẽ trên cùng 1 trục, bật khung box quanh trục
set(gca,'fontsize',16); % Thiết lập cỡ chữ trên trục tọa độ

% Vẽ CDF của SE cho MMSE (All)
% SE_MMSE_original(:) vector hóa toàn bộ SE (K x nbrOfSetups) thành một vector
% sort(...) sắp xếp tăng dần để làm trục x của CDF
% linspace(0,1,K*nbrOfSetups) tạo trục y từ 0 đến 1 với cùng số lượng điểm
plot(sort(SE_MMSE_original(:)),linspace(0,1,K*nbrOfSetups),'k-','LineWidth',2);

% Vẽ CDF cho MMSE (DCC)
plot(sort(SE_MMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'r-.','LineWidth',2);

% Vẽ CDF cho P-MMSE (DCC)
plot(sort(SE_PMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',2);

% Vẽ CDF cho P-RZF (DCC)
plot(sort(SE_PRZF_DCC(:)),linspace(0,1,K*nbrOfSetups),'b--','LineWidth',2);

% Vẽ CDF cho MR (DCC)
plot(sort(SE_MR_DCC(:)),linspace(0,1,K*nbrOfSetups),'m:','LineWidth',2);

% Đặt nhãn cho trục x và trục y, sử dụng Latex để hiển thị đẹp hơn
xlabel('Spectral efficiency [bit/s/Hz]','Interpreter','Latex');
ylabel('CDF','Interpreter','Latex');

% Tạo legend cho 5 đường CDF tương ứng với thứ tự các lệnh plot ở trên
legend({'MMSE (All)','MMSE (DCC)','P-MMSE (DCC)','P-RZF (DCC)','MR (DCC)'},'Interpreter','Latex','Location','SouthEast');

% Giới hạn trục x từ 0 đến 12 bit/s/Hz (như trong hình của sách)
xlim([0 12]);

% Lưu figure hiện tại thành file PNG với tên figure5_4a_original.png
saveas(gcf, 'figure5_4a_original.png');
% In thông báo để biết rằng file hình đã được lưu thành công
disp('Saved figure5_4a_original.png');

% Plot Figure 5.6(a) - so sánh các scheme dựa trên LSFD + L-MMSE/LP-MMSE/MR
figure;              % Tạo figure mới cho Hình 5.6(a)
hold on; box on;     % Giữ nhiều đường vẽ trên cùng trục, bật khung box
set(gca,'fontsize',16); % Thiết lập kích thước font cho trục

% Vẽ CDF của SE cho opt LSFD, L-MMSE (All APs serve all UEs)
plot(sort(SE_opt_LMMSE_original(:)),linspace(0,1,K*nbrOfSetups),'k-','LineWidth',2);

% Vẽ CDF của SE cho opt LSFD, L-MMSE (DCC)
plot(sort(SE_opt_LMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'r-.','LineWidth',2);

% Vẽ CDF cho n-opt LSFD, LP-MMSE (DCC)
plot(sort(SE_nopt_LPMMSE_DCC(:)),linspace(0,1,K*nbrOfSetups),'k:','LineWidth',2);

% Vẽ CDF cho n-opt LSFD, MR (DCC)
plot(sort(SE_nopt_MR_DCC(:)),linspace(0,1,K*nbrOfSetups),'b--','LineWidth',2);

% Đặt nhãn cho trục x và y
xlabel('Spectral efficiency [bit/s/Hz]','Interpreter','Latex');
ylabel('CDF','Interpreter','Latex');

% Legend cho 4 đường CDF trong Figure 5.6(a)
legend({'opt LSFD, L-MMSE (All)','opt LSFD, L-MMSE (DCC)','n-opt LSFD, LP-MMSE (DCC)','n-opt LSFD, MR (DCC)'},'Interpreter','Latex','Location','SouthEast');

% Giới hạn trục x từ 0 đến 12 bit/s/Hz
xlim([0 12]);

% Lưu figure thành file PNG với tên figure5_6a_original.png
saveas(gcf, 'figure5_6a_original.png');
% In thông báo để biết rằng file hình đã được lưu thành công
disp('Saved figure5_6a_original.png');
