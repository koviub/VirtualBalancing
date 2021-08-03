load('data\blankData0.mat')

res1=resu;
load('data\blankData.mat')
res=resu;

for i=1:length(res)

    
    res{i}.Blank(end+1)=res1{i}.Blank;
    res{i}.React(end+1)=res1{i}.React;
    
end

resu=res;
save('blankDataAll.mat','resu')