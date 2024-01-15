# 认知神经科学大作业
由于日志文件太大了，我们没有提交结果的源文件，但是很好复现，代码均可直接运行
## 准备
- 将老师提供的数据集解压并放在data文件夹下
- 创建cor.txt，每行一个协变量的名字，如Gender，放在data文件夹下
## 实验复现
1. 首先是KRR模型的实验，打开krr.m，首先设置实验名
~~~matlab
%实验名
featurebase="fc2_corr";
~~~
其次，设置输入特征
~~~matlab
%确定输入特征
%sc= readmatrix('data/scfp_atlas400_753.txt');
fc2 = readmatrix('data/rsfc_Yeo400_753_GSR.txt');
%fc1 = readmatrix('data/rsfc_atlas400_753_4.txt');
%hc1= horzcat(fc1,sc);
%hc2= horzcat(fc2,sc);
features=fc2;
~~~
最后，设置精度指标
~~~matlab
%设置精度指标
param.metric = 'corr';%corr,COD
~~~
2. 多核岭回归模型的实验在mkrr，需设置的参数与krr一致
3. feature_importance.m计算基于FC2的KRR模型的特征重要性，无需修改，相似度矩阵保存在"logs\interpretation\fc2_corr"路径下
4. p_krr.m计算krr预测模型置换检验的p值，只需修改实验名即可
~~~matlab
name="KRR_hc2_corr";
~~~
5. p_mutil.m计算多核岭回归预测模型置换检验的p值，与krr的一致
6. fdr.m执行FDR校正，需根据自己的命名修改name_list数组，此操作需在p值计算完毕后进行，最终会输出经过FDR(Q<0.05)校正后依然显著的实验名,对应预测变量和p值。
~~~matlab
%所有进行FDR校正的实验名
name_list=["KRR_fc1_corr",'KRR_fc2_corr','KRR_sc_corr','KRR_hc1_corr','KRR_hc2_corr','MKRR_fc1+fc2_corr','MKRR_fc1+fc2+sc_corr','MKRR_sc+fc1_corr','MKRR_sc+fc2_corr'];
~~~