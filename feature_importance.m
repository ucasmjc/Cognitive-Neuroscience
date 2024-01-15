addpath(genpath('utilities\utilities\'))
%����·���ʹ������ʵ����
results_dir='logs/';
feature='fc2_corr';
input_dir = 'data/rsfc_Yeo400_753_GSR.txt';
%haufe�任
CBIG_MMP_HCP_Haufe(input_dir, results_dir, feature)
mat=load(fullfile("logs\interpretation",feature, 'cov_mat_mean.mat'));
data=mean(mat.cov_mat_mean,1);
%�������ƶȾ���
similarity_matrix = 1 - squareform(pdist(squeeze(data)', 'correlation'));
save(fullfile("logs\interpretation",feature, 'similar.mat'), 'similarity_matrix');