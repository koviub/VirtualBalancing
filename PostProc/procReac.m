clear all
% close all

load('data/blankData.mat');
n=length(resu);
rossz1=[10 16 17 18];
q1=[4 5 6 8 12 15 16 17 18 19 20 21 24 27 28];
q0=setdiff(1:28,q1);
q1=setdiff(q1,rossz1);
q0=setdiff(q0,rossz1);
sub=[q1,q0];
acceptH0=0;acceptH1=0;
for i=1:length(sub)
    
    res=resu{sub(i)};
    
    Test1=res.React;
    Test2=res.Blank;
%     figure();hold on;grid on;box on;
    data1=zeros(10,6);data1(data1==0)=NaN;
    data2=zeros(10,6);data2(data2==0)=NaN;
    for j=1:size(Test1,2)
        if isstruct(Test2{j})&&isstruct(Test1{j})
        data1(:,j)=Test1{j}.data(1:10);
        data2(1:length(Test2{j}.data),j)=Test2{j}.data;
        [h,p,ci,stats]=ttest2(data1(:,j),data2(:,j),'Vartype','unequal','Tail','right');
        end
        if h==0
           acceptH0=acceptH0+1; 
        else
           acceptH1=acceptH1+1;
        end
    end
    
    REA(:,i)=mean(data1,'omitnan');
    BLA(:,i)=mean(data2,'omitnan');
    
        subplot(1,2,1)
        hold on;box on;grid on;
        boxplot(REA)
        ylim([0 .5])
        subplot(1,2,2)
        hold on;box on;grid on;
        boxplot(BLA)
        ylim([0 .5])
end
