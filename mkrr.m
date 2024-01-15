addpath(genpath('utilities\utilities\'))
%设置路径
sub_txt="data/HCP_list_Yeo.txt";
score_csv={char("data/HCP_s1200.csv")};
pred_var_txt="data/prediction_variables.txt";
cov_txt="data/cor.txt";
y_mat="y.mat";
cov_mat="covariates.mat";
y_output="logs/y.mat";
cov_output="logs/covariates.mat";
outdir="logs/";
num_outer_folds = 3;
param.num_inner_folds = 3;
%实验名
feature_name = "fc1+fc2+sc_corr";
outstem = convertStringsToChars(strcat("MKRR_", feature_name)); 
param.outstem = outstem;
%读取数据
fc1 = readmatrix('data/rsfc_atlas400_753_4.txt');
fc2 = readmatrix('data/rsfc_Yeo400_753_GSR.txt');
sc = readmatrix('data/scfp_atlas400_753.txt');
%回归模型设置
lambda_set = [ 0 0.00001 0.0001 0.001 0.004 0.007 0.01 0.04 0.07 0.1 0.4 0.7 1 1.5 2 2.5 3 3.5 4 5 10 15 20];
param.lambda_set = lambda_set;
param.domain = [0 20];
param.with_bias = 1;
param.ker_param.type = 'corr'; 
param.ker_param.scale = NaN;
param.threshold = 'None';
param.group_kernel = ["1","2","3"];
param.acc_metric = 'corr';
for seed=1:30
    for fold_id=1:num_outer_folds 
        param.outdir = fullfile(outdir, outstem, num2str(seed), 'results');
        %划分训练集
        fold_mat = 'no_relative_3_fold_sub_list.mat';
        if ~exist(fullfile(param.outdir, fold_mat))
            sub_fold = CBIG_cross_validation_data_split(sub_txt, 'NONE', ...
            'NONE', 'NONE', num_outer_folds, seed, param.outdir, ','); 
        else
            fprintf('Using existing sub_fold file \n')
            fold_temp = load(fullfile(param.outdir, fold_mat));
            sub_fold = fold_temp.sub_fold;
        end
        param.sub_fold  = sub_fold;
        %保存y矩阵
    
        if ~exist(fullfile(outdir, y_mat))
            % get names of tasks to predict
            fid = fopen(pred_var_txt,'r'); % variable names text file
            score_list = textscan(fid,'%s');
            score_names = score_list{1};
            fclose(fid);
            num_scores = size(score_names,1);
            % generate y
            score_types = cell(1,num_scores); % define score types
            score_types(:) = {'continuous'};
            y = CBIG_read_y_from_csv(score_csv, 'Subject', score_names, score_types,...
                sub_txt, fullfile(outdir, y_mat), ',');
        else
            fprintf('Using existing y file \n')
            y_temp = load(fullfile(outdir,y_mat));
            y = y_temp.y;
        end
        param.y = y;
    
        %保存协变量矩阵 
    
        if ~exist(fullfile(outdir,cov_mat))
            % generate covariates
            fid = fopen(cov_txt,'r'); % covariate names text file
            cov_list = textscan(fid,'%s');
            cov_names = cov_list{1};
            fclose(fid);
            num_cov = size(cov_names,1);
            cov_types = {'categorical'}; % define covariate types
            cov = CBIG_generate_covariates_from_csv(score_csv, 'Subject', cov_names, cov_types, ...
                sub_txt, 'none', 'none', fullfile(outdir,cov_mat), ',');
        else
            fprintf('Using existing covariate file \n')
            cov_temp = load(fullfile(outdir, cov_mat));
            cov = cov_temp.covariates;
        end
        param.covariates = cov;
    
        %选择特征
        feat_mat{1}=fc2;
        feat_mat{2}=fc1;
        feat_mat{3}=sc;
        %进行MKRR模型的训练和测试
        CBIG_MMP_MultiKRR_workflow_parallel_subfolds('',0, fullfile(param.outdir,fold_mat), ...
            fullfile(outdir,y_mat), fullfile(outdir,cov_mat), feat_mat, ...
            param.num_inner_folds, param.outdir, param.outstem,fold_id);
    end
end
