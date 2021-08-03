clear all
close all
%% Data processing
% cycle through tests
job='C:\Users\Kovacs Balazs\Desktop\Egydin\test\';
addpath(job);
f_o=dir(job);
f_o={f_o.name};
f = f_o(3:end);
n=1;

for j=n:length(f)
    str=sprintf('%d \n',n);
    fprintf(str)
    str1 = fullfile(job,cell2mat(f(j)));
    addpath(str1);
%     resu{j}=ProcMeas_blank(str1,n);
    resu{j}=ProcMeas_n(str1,n);
    n=n+1;
end
save('blankData0.mat','resu')