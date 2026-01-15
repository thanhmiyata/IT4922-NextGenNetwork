function D_new = functionGenerateDCC_improved(gainOverNoisedB, L, K, threshold_ratio, L_max, N_min)
%functionGenerateDCC_improved - Threshold-based AP Selection with Load Balancing
%
% Hàm này cài đặt một thuật toán Distributed Cell-free Clustering (DCC)
% cải tiến, dựa trên large-scale fading (gain over noise, dB) và ràng buộc
% cân bằng tải trên các AP.
%
% INPUT:
%   gainOverNoisedB : ma trận [L x K] chứa gain kênh (dB) giữa AP l và UE k
%                     đã chuẩn hóa theo nhiễu
%   L               : số lượng APs
%   K               : số lượng UEs
%   threshold_ratio : ngưỡng dạng tỉ lệ so với gain lớn nhất của mỗi UE
%                     (vd: 0.1 = 10% max gain của UE đó)
%   L_max           : số UE tối đa mà mỗi AP được phép phục vụ
%   N_min           : số AP tối thiểu phải phục vụ mỗi UE
%
% OUTPUT:
%   D_new           : ma trận [L x K] DCC, D_new(l,k)=1 nếu AP l phục vụ UE k
%
% Hàm này được viết để minh họa ý tưởng user-centric Cell-Free Massive MIMO,
% thay thế cho cơ chế DCC dựa trên pilot trong generateSetup.m.


    % Kiểm tra sơ bộ kích thước đầu vào (bảo vệ lập trình)
    if size(gainOverNoisedB,1) ~= L || size(gainOverNoisedB,2) ~= K
        error('gainOverNoisedB must be of size L x K.');
    end

    % Khởi tạo ma trận DCC với tất cả phần tử = 0 (chưa AP nào phục vụ UE nào)
    D_new = zeros(L, K);

    % Đổi gain từ đơn vị dB sang tuyến tính để so sánh/nhân chia dễ hơn
    gainOverNoise = db2pow(gainOverNoisedB);

    %% PHASE 1: Threshold-based Selection (per UE)
    % Với mỗi UE, chọn những AP có gain lớn hơn ngưỡng tương đối (threshold_ratio * max gain)
    for k = 1:K
        % Tìm gain lớn nhất giữa tất cả AP với UE k
        max_beta_k = max(gainOverNoise(:, k));

        % Ngưỡng động cho UE k
        threshold_k = threshold_ratio * max_beta_k;

        % Các AP có gain lớn hơn hoặc bằng ngưỡng -> ứng viên phục vụ UE k
        serving_APs = find(gainOverNoise(:, k) >= threshold_k);

        % Gán các AP này phục vụ UE k
        D_new(serving_APs, k) = 1;
    end


    %% PHASE 2: Ensure Minimum Connectivity (N_min APs per UE)
    % Đảm bảo mỗi UE được ít nhất N_min AP phục vụ
    for k = 1:K
        num_serving = sum(D_new(:, k));  % số AP hiện tại đang phục vụ UE k

        if num_serving < N_min
            % Các AP chưa phục vụ UE k
            non_serving = find(D_new(:, k) == 0);

            if ~isempty(non_serving)
                % Sắp xếp các AP chưa phục vụ theo gain giảm dần
                [~, sorted_idx] = sort(gainOverNoise(non_serving, k), 'descend');

                % Số AP cần thêm để đạt N_min
                add_count = min(N_min - num_serving, length(non_serving));

                % Thêm lần lượt các AP tốt nhất còn lại cho UE k
                for i = 1:add_count
                    l_add = non_serving(sorted_idx(i));
                    D_new(l_add, k) = 1;
                end
            end
        end
    end


    %% PHASE 3: Load Balancing (limit UEs per AP to L_max)
    % Giai đoạn này giới hạn số UE được phục vụ bởi mỗi AP (<= L_max)
    % bằng cách loại bỏ bớt các liên kết yếu của AP bị quá tải và (nếu có thể)
    % gán lại UE đó cho AP khác ít tải hơn. Dừng sớm nếu mọi AP đã thỏa điều kiện.
    max_iterations = 100;

    for iter = 1:max_iterations
        % Tính tải hiện tại của từng AP: số UE mà AP đang phục vụ
        load = sum(D_new, 2); % [L x 1]

        % Tìm AP có tải lớn nhất
        [max_load, l_overloaded] = max(load);

        % Điều kiện dừng: mọi AP đều thỏa load <= L_max
        if max_load <= L_max
            break;
        end

        % Liệt kê các UE hiện đang được AP quá tải này phục vụ
        UEs_at_l = find(D_new(l_overloaded, :) == 1);

        if isempty(UEs_at_l)
            % Không có UE nào nhưng vẫn được đánh dấu quá tải (lỗi số học)
            break;
        end

        % Trong số các UE đó, chọn UE có link yếu nhất tới AP này
        [~, weak_idx] = min(gainOverNoise(l_overloaded, UEs_at_l));
        k_weak = UEs_at_l(weak_idx);

        % Chỉ bỏ AP này khỏi UE k nếu UE đó vẫn còn >= N_min AP phục vụ
        if sum(D_new(:, k_weak)) > N_min
            % Bỏ liên kết AP quá tải với UE có link yếu nhất
            D_new(l_overloaded, k_weak) = 0;

            % (Tùy chọn) thử gán UE này sang một AP khác không quá tải
            load = sum(D_new, 2); % tính lại tải sau khi bỏ
            candidate_APs = find(D_new(:, k_weak) == 0 & load < L_max);

            if ~isempty(candidate_APs)
                % Chọn AP ứng viên có gain lớn nhất với UE k_weak
                [~, best_idx] = max(gainOverNoise(candidate_APs, k_weak));
                l_alt = candidate_APs(best_idx);
                D_new(l_alt, k_weak) = 1;
            end

        else
            % Không thể bỏ AP này mà vẫn giữ N_min AP cho UE k_weak
            % Dừng vòng lặp để tránh lặp vô tận
            warning('AP %d remains overloaded; could not fully balance load.', l_overloaded);
            break;
        end
    end


    %% Simple statistics (printed for debugging/analysis)
    % Thống kê đơn giản để quan sát đặc tính cụm AP sau khi chạy thuật toán
    avg_cluster_size = mean(sum(D_new, 1)); % trung bình số AP/UE (|M_k|)
    avg_load = mean(sum(D_new, 2));         % trung bình số UE/AP (load)
    total_links = sum(D_new(:));            % tổng số links (fronthaul load)

    fprintf('Proposed DCC: Avg cluster size = %.2f, Avg AP load = %.2f, Total links = %d\n', ...
        avg_cluster_size, avg_load, total_links);

end

