%所有进行FDR校正的实验名
name_list=["KRR_fc1_corr",'KRR_fc2_corr','KRR_sc_corr','KRR_hc1_corr','KRR_hc2_corr','MKRR_fc1+fc2_corr','MKRR_fc1+fc2+sc_corr','MKRR_sc+fc1_corr','MKRR_sc+fc2_corr'];
n=length(name_list);
p_all=zeros([13*n,1]);
for i=1:n
    load(fullfile("logs",name_list(i),"p.mat"));
    p_all((i-1)*13+1:i*13,1)=squeeze(p);
end
[ind, threshold] = FDR(p_all, 0.05);
%输出显著预测的预测变量
for i=1:length(ind)
    index=ind(i);
    name=name_list(ceil(index/13));
    if mod(index,13)==0
        disp([name,13,p_all(index)])
    else
        disp([name,mod(index,13),p_all(index)])
    end 
end