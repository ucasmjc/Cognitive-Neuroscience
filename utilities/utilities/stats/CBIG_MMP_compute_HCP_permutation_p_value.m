function p_value = CBIG_MMP_compute_HCP_permutation_p_value(ref_dir, behav_ind, outstem, perm_dir, seeds_total)
%% compare with permutation: MODIFY HERE IF YOU CHANGED FOLDS / PERMUTATIONS
perm_per_file = 200;
N_folds = 3;

for i = 1:length(behav_ind)
    N_worse = 0;
    behav = behav_ind(i);
	
    % load reference
    disp([outstem, ref_dir])
    acc_vec = CBIG_MMP_HCP_read_model_results(outstem, ref_dir, seeds_total, N_folds, behav_ind, 'corr', 0);
    for curr_seed = 1:seeds_total
        seed_str = strcat('seed_', num2str(curr_seed));
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

rmpath(fullfile(getenv('CBIG_CODE_DIR'),'stable_projects', 'predict_phenotypes', ...
   'Ooi2022_MMP', 'regression', 'HCP', 'utilities')) 
