function D_new = functionGenerateDCC_improved(gainOverNoisedB, L, K, threshold_ratio, L_max, N_min)
%functionGenerateDCC_improved - Threshold-based AP Selection with Load Balancing
%
% This function implements an improved Distributed Cell-free Clustering (DCC)
% based on large-scale fading (or channel gain over noise, in dB) and
% load balancing constraints.
%
% INPUT:
%   gainOverNoisedB : [L x K] matrix of channel gains (in dB) between
%                     AP l and UE k, normalized by noise variance
%   L               : Number of APs
%   K               : Number of UEs
%   threshold_ratio : Threshold as a fraction of the maximum gain of each UE
%                     (e.g., 0.1 = 10% of max gain for that UE)
%   L_max           : Maximum number of UEs that each AP can serve
%   N_min           : Minimum number of APs that must serve each UE
%
% OUTPUT:
%   D_new           : [L x K] DCC matrix, where D_new(l,k)=1 if AP l serves UE k
%
% This Matlab function was written for educational purposes in the context of
% studying user-centric Cell-Free Massive MIMO, as an alternative to the
% pilot-based DCC in generateSetup.m. It does not modify any of the original
% code; it is meant to be called from simulation scripts (e.g.,
% section5_figure4a_6a.m).


    % Basic input sanity check (dimensions)
    if size(gainOverNoisedB,1) ~= L || size(gainOverNoisedB,2) ~= K
        error('gainOverNoisedB must be of size L x K.');
    end

    % Initialize DCC matrix
    D_new = zeros(L, K);

    % Convert from dB to linear scale for comparisons
    gainOverNoise = db2pow(gainOverNoisedB);

    %% PHASE 1: Threshold-based Selection (per UE)
    for k = 1:K
        % Find maximum gain for UE k
        max_beta_k = max(gainOverNoise(:, k));

        % Adaptive threshold for UE k
        threshold_k = threshold_ratio * max_beta_k;

        % APs whose gain is above the adaptive threshold
        serving_APs = find(gainOverNoise(:, k) >= threshold_k);

        D_new(serving_APs, k) = 1;
    end


    %% PHASE 2: Ensure Minimum Connectivity (N_min APs per UE)
    for k = 1:K
        num_serving = sum(D_new(:, k));

        if num_serving < N_min
            % APs that are not yet serving UE k
            non_serving = find(D_new(:, k) == 0);

            if ~isempty(non_serving)
                % Sort remaining APs by gain in descending order
                [~, sorted_idx] = sort(gainOverNoise(non_serving, k), 'descend');

                % Number of APs to add
                add_count = min(N_min - num_serving, length(non_serving));

                for i = 1:add_count
                    l_add = non_serving(sorted_idx(i));
                    D_new(l_add, k) = 1;
                end
            end
        end
    end


    %% PHASE 3: Load Balancing (limit UEs per AP to L_max)
    max_iterations = 100;

    for iter = 1:max_iterations
        % Compute current load per AP (number of UEs served)
        load = sum(D_new, 2); % [L x 1]

        [max_load, l_overloaded] = max(load);

        % Check stopping condition: all APs satisfy load <= L_max
        if max_load <= L_max
            break;
        end

        % UEs currently served by the overloaded AP
        UEs_at_l = find(D_new(l_overloaded, :) == 1);

        if isempty(UEs_at_l)
            % No UEs served but marked overloaded due to numerical reasons
            break;
        end

        % Among those UEs, find the one with the weakest link to this AP
        [~, weak_idx] = min(gainOverNoise(l_overloaded, UEs_at_l));
        k_weak = UEs_at_l(weak_idx);

        % Only remove this AP if the UE still has at least N_min serving APs
        if sum(D_new(:, k_weak)) > N_min
            D_new(l_overloaded, k_weak) = 0;

            % Optional: try to add an alternative AP that is not overloaded
            load = sum(D_new, 2); % recompute after removal
            candidate_APs = find(D_new(:, k_weak) == 0 & load < L_max);

            if ~isempty(candidate_APs)
                % Choose the candidate AP with the strongest gain
                [~, best_idx] = max(gainOverNoise(candidate_APs, k_weak));
                l_alt = candidate_APs(best_idx);
                D_new(l_alt, k_weak) = 1;
            end

        else
            % Cannot remove this AP without violating the N_min constraint
            % Stop iterations to avoid infinite loop
            warning('AP %d remains overloaded; could not fully balance load.', l_overloaded);
            break;
        end
    end


    %% Simple statistics (printed for debugging/analysis)
    avg_cluster_size = mean(sum(D_new, 1)); % average |M_k| over UEs
    avg_load = mean(sum(D_new, 2));         % average load over APs

    fprintf('Proposed DCC: Avg cluster size = %.2f, Avg AP load = %.2f\n', ...
        avg_cluster_size, avg_load);

end

