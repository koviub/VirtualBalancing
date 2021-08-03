load('C:\Users\Kovacs Balazs\Desktop\StickBalance\BalanceApp\PostProc\data\ED_checkData.mat')
res2=resu;

load('C:\Users\Kovacs Balazs\Desktop\StickBalance\BalanceApp\PostProc\data\ED_testData.mat')
res1=resu;


for i=1:length(res1)
   
    res1{i}.L{end+1}=res2{i}.L{1};
    res1{i}.T{end+1}=res2{i}.T{1};
    res1{i}.Q{end+1}=res2{i}.Q{1};
    res1{i}.DATE{end+1}=res2{i}.DATE{1};
    res1{i}.name{end+1}=res2{i}.name{1};
    
end

resu=res1;
save('ED_allMeasData.mat','resu')