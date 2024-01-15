addpath(genpath('utilities\utilities\'))
name="KRR_hc2_corr";
singleKRR_dir=fullfile('logs',name);
outdir="logs/hypothesis_test/";
subtxt="data/HCP_list_Yeo.txt";
%置换检验生成零分布
for i=1:13
    CBIG_MMP_HCP_compute_singleKRR_perm_stats(singleKRR_dir, name, i, ...
     1, 100, subtxt, outdir);
end
%根据零分布计算p值
p=CBIG_MMP_compute_HCP_permutation_p_value("logs",1:13,name,  outdir, 30);
save(fullfile('logs',name,'p.mat'),'p')

