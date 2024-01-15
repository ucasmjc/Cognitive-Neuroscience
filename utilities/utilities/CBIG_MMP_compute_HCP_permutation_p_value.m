function p_value = CBIG_MMP_compute_HCP_permutation_p_value(ref_dir, behav_ind, outstem, perm_dir, seeds_total)
perm_per_file = 100;
N_folds = 3;

for i = 1:length(behav_ind)
    N_worse = 0;
    behav = i;
	
    % load reference,13*90
    acc_vec = CBIG_MMP_HCP_read_model_results(outstem, ref_dir, seeds_total, N_folds, behav_ind, 'corr', 0);
    for curr_seed = 1:seeds_total
        seed_str =  num2str(curr_seed);
        seed_alloc = [ ((curr_seed-1)*N_folds + 1):curr_seed*N_folds ];
        ref = mean(acc_vec(i,seed_alloc));
        % load permutations
        load(fullfile(perm_dir, num2str(curr_seed), ['/acc_score' num2str(behav) '_allFolds_permStart1.mat']));
        curr_acc = squeeze(mean(stats_perm.corr,1));
        curr_N_worse = sum(curr_acc > ref);
        N_worse = N_worse + curr_N_worse;
    end
    p_value(i) = (1+N_worse)/(1+seeds_total*perm_per_file);
end


