# ��֪�񾭿�ѧ����ҵ
������־�ļ�̫���ˣ�����û���ύ�����Դ�ļ������Ǻܺø��֣��������ֱ������
## ׼��
- ����ʦ�ṩ�����ݼ���ѹ������data�ļ�����
- ����cor.txt��ÿ��һ��Э���������֣���Gender������data�ļ�����
## ʵ�鸴��
1. ������KRRģ�͵�ʵ�飬��krr.m����������ʵ����
~~~matlab
%ʵ����
featurebase="fc2_corr";
~~~
��Σ�������������
~~~matlab
%ȷ����������
%sc= readmatrix('data/scfp_atlas400_753.txt');
fc2 = readmatrix('data/rsfc_Yeo400_753_GSR.txt');
%fc1 = readmatrix('data/rsfc_atlas400_753_4.txt');
%hc1= horzcat(fc1,sc);
%hc2= horzcat(fc2,sc);
features=fc2;
~~~
������þ���ָ��
~~~matlab
%���þ���ָ��
param.metric = 'corr';%corr,COD
~~~
2. �����ع�ģ�͵�ʵ����mkrr�������õĲ�����krrһ��
3. feature_importance.m�������FC2��KRRģ�͵�������Ҫ�ԣ������޸ģ����ƶȾ��󱣴���"logs\interpretation\fc2_corr"·����
4. p_krr.m����krrԤ��ģ���û������pֵ��ֻ���޸�ʵ��������
~~~matlab
name="KRR_hc2_corr";
~~~
5. p_mutil.m��������ع�Ԥ��ģ���û������pֵ����krr��һ��
6. fdr.mִ��FDRУ����������Լ��������޸�name_list���飬�˲�������pֵ������Ϻ���У����ջ��������FDR(Q<0.05)У������Ȼ������ʵ����,��ӦԤ�������pֵ��
~~~matlab
%���н���FDRУ����ʵ����
name_list=["KRR_fc1_corr",'KRR_fc2_corr','KRR_sc_corr','KRR_hc1_corr','KRR_hc2_corr','MKRR_fc1+fc2_corr','MKRR_fc1+fc2+sc_corr','MKRR_sc+fc1_corr','MKRR_sc+fc2_corr'];
~~~