addpath(genpath('utilities\utilities\'))
name="MKRR_sc+fc2_corr";
multiKRR_dir=fullfile('logs',name);
outdir="logs/hypothesis_test/";
subtxt="data/HCP_list_Yeo.txt";
%置换检验生成零分布
for i=1:13
    CBIG_MMP_HCP_compute_multiKRR_perm_stats(multiKRR_dir, name, i, 1, 100, subtxt, outdir);
end
%计算p值
p=CBIG_MMP_compute_HCP_permutation_p_value("logs",1:13,name,  outdir, 30);
save(fullfile('logs',name,'p.mat'),'p')

