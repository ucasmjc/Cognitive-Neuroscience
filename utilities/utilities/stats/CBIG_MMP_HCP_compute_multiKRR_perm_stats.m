function CBIG_MMP_HCP_compute_multiKRR_perm_stats(multiKRR_dir, outstem, score_ind, ...
 perm_seed_start, N_perm, subject_list, outdir)

% function CBIG_MMP_HCP_compute_multiKRR_perm_stats(multiKRR_dir, outstem, score_ind, ...
% perm_seed_start, N_perm, family_list, subject_list, outdir)
% Adapted from CBIG_TRBPC_compute_multiKRR_perm_stats.
% This function performs the permutation test for the singleKRR model and
% saves out the prediction accuracies of the permutation test
%
% Inputs:
%   - singleKRR_dir:
%     The directory wherre the singleKRR results are
%
%   - outstem
%     A string appended to the filename to specify the output files in the
%     singleKRR prediction. Must be the same as the input argument `outstem`
%     when you perform singleKRR
%
%   - score_ind
%     A scalar. The index of the score you want to perfom the permutation test.
%     Range from 1 to # Target Variables in your kernel regression
%
%   - perm_seed_start
%     A scalar. The function will do the permutation N_perm times using
%     permutation seed from perm_seed_start to perm_seed_start+N_perm-1
%
%   - N_perm
%     Number of permutation
%
%   - family_list
%     A csv containing the family IDs of subjects.
%
%   - subject_list
%     A text file where each line is the subject ID to be extracted from family_list.
%
%   - outdir
%     Output directory for the permutation results
%
% Outputs:
%    prediction accuracies of the permutation test will be saved in the
%    outdir
%
% Written by Leon Ooi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

% check if output already exist
%result_file = fullfile(outdir,['/acc_score' num2str(score_ind) '_allFolds_permStart' num2str(perm_seed_start) '.mat']);
%if ~exist(result_file,'file')

%% check input arguments
if(isstr(score_ind))
	score_ind = str2num(score_ind);
end

if ~exist(outdir,'dir')
	mkdir(outdir);
end
    
% get subjects 
fid = fopen(subject_list,'r');
file = textscan(fid, '%d');
fclose(fid);
subjects = file{:};

% get families
family_all = file{:};
[~, ~, family_ind] = unique(family_all);
N_family = max(family_ind);
for i = 1:N_family
	family_count(i,:) = sum(family_ind == i);
end
    
%% load cross-validation split
N_seeds = 30;
for h=1:N_seeds
	seed = num2str(h);
	disp(seed);
	if ~exist(fullfile(outdir,seed),'dir')
	    mkdir(fullfile(outdir,seed));
	end
	sub_fold_file = dir(fullfile(multiKRR_dir, seed, 'results', '*sub_list.mat'));
	if length(sub_fold_file) ~= 1
	    error('There should be one and only one sub_fold file in the multiKRR directory');
	end
	load(fullfile(multiKRR_dir, seed, 'results', sub_fold_file.name));
	N_fold = length(sub_fold);

	%% compute permutation
	metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};
	for i = 1:length(metrics)
	    stats_perm.(metrics{i}) = zeros(N_fold,N_perm);
	end

        load(strjoin([fullfile(multiKRR_dir, seed, 'results'), ['\final_result_' outstem '.mat']],''));
        outfile = fullfile(outdir, seed,...
            ['/acc_score' num2str(score_ind) '_allFolds_permStart' num2str(perm_seed_start) '.mat']);
        if ~exist(outfile)
		for i = 1:N_fold
			disp(['fold ' num2str(i)]);
			% load data
			load(strjoin([fullfile(multiKRR_dir, seed, 'results', 'y'), ['\fold_' num2str(i) '\y_regress_' outstem '.mat']],''));
            load(strjoin([fullfile(multiKRR_dir, seed, 'results', 'optimal_acc'), ['\fold_' num2str(i) '\acc_' outstem '.mat']],''));
			y_resid = y_resid(:,score_ind);
			lambda_vect = opt_hyp{:,score_ind};
			test_ind = sub_fold(i).fold_index;
			train_ind = ~test_ind;

			% load FSM
			kernel_folders = dir(fullfile(multiKRR_dir, seed, 'results', 'Kernel_*'));
			num_kernel = length(kernel_folders);
			for ker = 1:num_kernel
				load(fullfile(multiKRR_dir, seed, 'results', ['/Kernel_' num2str(ker)], '/FSM_test/', 'fold_1', 'FSM_corr.mat'));
				FSM_all(:,:,ker) = FSM;
			end

			FSM_train = FSM_all(train_ind,train_ind,:);
			FSM_pred = FSM_all(test_ind,train_ind,:);

			% number of subjects
			num_train_subj = size(FSM_train,1);
			num_test_subj = size(FSM_pred,1);
            
			% compute intermediate matrices
			FSM_tmp = reshape(FSM_pred,num_test_subj, num_train_subj*num_kernel);
			K_tmp = repmat(reshape(FSM_train,num_train_subj,num_train_subj*num_kernel),...
			num_kernel,1);
			kr_eye_tmp = eye(num_kernel*num_train_subj);
			kr_lambda_tmp = reshape(repmat(lambda_vect,num_train_subj,1),...
			num_train_subj*num_kernel,1);
			kr_tmp = bsxfun(@times, kr_eye_tmp, kr_lambda_tmp);
			K_tmp = K_tmp + kr_tmp;

			% Perform training and prediction
			% training
			X = ones(num_train_subj*num_kernel,1);
			inv_K_tmp = inv(K_tmp);
			beta_pre = (X' * (inv_K_tmp * X)) \ X' * inv_K_tmp;

			for j = 1:N_perm
				% permute behavior within site
				y_perm = y_resid;
				% split into max(family_count) groups
				perm_group = zeros(length(family_ind),1);
				rng(j+perm_seed_start-1);
				for k = 1:N_family
				    sorting_order = datasample([1:max(family_count)],family_count(k),'Replace', false);
				    perm_group(find(family_ind == k)) = sorting_order;
				end
				% permute within groups
				for n = 1:max(family_count)
				    y_tmp = y_perm(perm_group == n);
				    y_tmp = y_tmp(randperm(length(y_tmp)));
				    y_perm(perm_group == n) = y_tmp;
				end

				y_train_resid = y_perm(train_ind);
				y_test_resid = y_perm(test_ind);
				% predict
				y_tmp = repmat(y_train_resid,num_kernel,1);
				beta = beta_pre * y_tmp;
				alpha = inv_K_tmp * (y_tmp - X * beta);
				y_predicted = FSM_tmp * alpha + ones(num_test_subj,1) .* beta;
		
				for k = 1:length(metrics)
				    stats_perm.(metrics{k})(i,j) = ...
				        CBIG_compute_prediction_acc_and_loss(y_predicted,y_test_resid,metrics{k},y_train_resid);
				end
			end
		end
		save(outfile,'stats_perm');
	end
end
