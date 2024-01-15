% 设置要操作的文件夹路径
folder_path = 'C:\Users\24967\Desktop\认知神经科学\Ooi2022_MMP\examples\scripts\utilities\temp\KRR_hc2_cod';

% 获取文件夹中的所有文件和文件夹
all_files = dir(folder_path);

% 遍历所有文件和文件夹
for i = 1:length(all_files)
    file_name = all_files(i).name;
    files=dir(fullfile(folder_path, file_name,"results/"));
    for j=1:length(files)
        file_name1=files(j).name;
        if ~strcmp(file_name1, '.') && ~strcmp(file_name1, '..') && ~strcmp(file_name1, 'final_result_KRR_hc2_cod.mat')
            if files(j).isdir
                % 如果是文件夹，就使用 rmdir 函数删除
                rmdir(fullfile(folder_path, file_name,"results/",file_name1), 's');
            else
                % 如果是文件，就使用 delete 函数删除
                delete(fullfile(folder_path, file_name,"results/",file_name1));
            end
        end
    end
end