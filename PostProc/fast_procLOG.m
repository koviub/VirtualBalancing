% close all
clear all

load('data/ED_allMeasData.mat')
% load('data/oldMeasAll.mat')
n=length(resu);
cmap=parula(8);
markers={'o','+','*','x','s','d','^','v','>','<','p','h'};
jok=[1 2 3 4 5 7 8 9 10 11 12 13 14 15 22 23 24 25 26 27 28];
jok1=[4 5 8 12 15 22 24 27 28];
majdnem=[1 2 3 7 9 10 11 13 14 23 25 26];
rossz=[6 16 17 18 19 20 21];
sub=1:28;%1:21;%([3 4 7 8 16]); %  subjects to investigate

jok1=[4 5 8 12 15 22 24 27 28];
majdnem=[4];
rossz1=[10 16 17 18];

q1=[4 5 6 8 12 15 16 17 18 19 20 21 24 27 28];
q1=setdiff(q1,rossz1);
q0=setdiff(sub,q1);
sub=setdiff(q1,rossz1);
% sub=setdiff(q1,[4 5 8 12 15 24 27 28]);
% sub=1:28;
data.a1=zeros(length(sub),7);
data.a2=zeros(length(sub),7);
data.c1=zeros(length(sub),7);
data.r1=zeros(length(sub),7);
data.ra=zeros(length(sub),7);
data.reac=zeros(length(sub),7);
compdelay=.008+.05; % sampling and filter delay

figure(997);
hold on;grid on;box on;
a0=3/4*9.81;
% a*x^2+b*x+c???
ft=fittype('a1*x+a2');
% ft=fittype('a*x^2+b*x+c');
% ft=fittype('a*x^2/(b*x+c)');
x=-1.5:.1:0;
str0={};
for i=1:length(sub)
    res=resu{sub(i)};
    LEN=res.L;
    DEL=res.T;
    q=res.Q;
%      figure(sub(i));
%      title(sprintf('%s',res.name{1}))
%     xlim([-1.5 0])
%     ylim([0 3.5])
%     cla
    pl=[];
%     hold on;grid on;box on;
    k=1;
    for j=1:size(DEL,2)
        if j<8
        [deltai, ind]=sort(compdelay+DEL{j});
        data.reac(i,j)=deltai(1)-compdelay;
        delta=log(deltai);
        len=log(LEN{j}(ind));
        deltao=deltai;
        leno=LEN{j}(ind);
        % only if old data
%         delta=delta.';
%         len=len.';
        %%%%%%%%%%%%
        figure(999)
        subplot(6,4,i)
        hold on;grid on; box on;
        plot(deltao,leno,'color',cmap(j,:),'linestyle','none','marker','*')
        [fit0,gof]=  fit(delta.',len.',ft,'startpoint',[1 log(a0)]);
        y=fit0.a1*x+fit0.a2;
%         ya=fita.a*x.^pa+fita.b;
        str=sprintf('N#%d,q:%d,%.3f*x+%.3f,R^2=%.3f',...
            j,q{j},fit0.a1,fit0.a2,gof.rsquare);
        pl(k)=plot((0:.05:1),exp(fit0.a2)*(0:.05:1).^(fit0.a1),'color',cmap(j,:),'displayname',str,'linewidth',0.5);
% %         plot(x,ya,'color',cmap(j,:),'linestyle',':','linewidth',1)
%         legend(pl,'Location','northwest')
%         xlabel('log($\tau$)[s]','interpreter','latex')
%         ylabel('log($L_{\rm crit}$)[m]','interpreter','latex')
        ylim([0 25])
        k=k+1;
        data.a1(i,j)=fit0.a1;
        data.a2(i,j)=fit0.a2;
%         data.c1(i,j)=fit0.c;
        data.r1(i,j)=gof.rsquare;
%         ra(i,j)=gofa.rsquare;
        data.qpar(i,j)=q{j};
        if data.qpar(i,j)==0
            cc='r';
        else
            cc='b';
        end
        figure(997)
        hold on;
        cc=.8.*[1 1 1]-.2*(j-1);
        cc=[0 0 0];
        plot(delta,len-fit0.a2,'color',cc,'linestyle','none','marker',markers{mod(i,12)+1},'markerfacecolor',cc)
        
        end
    end
    str0{i}=sprintf('%d',data.qpar(i,1));
end

% 
% figure(99)
% % for i=1:length(sub)
% % figure(sub(end)+sub(i))
% ax1=subplot(1,3,1);
% bar(data.a1(:,:))
% ylabel('a1')
% ylim([0 2.2])
% ax1.XTickLabel=str0;
% ax2=subplot(1,3,2);
% bar(data.a2(:,:))
% ylabel('a2')
% ax2.XTickLabel=str0;
% ax3=subplot(1,3,3);
% bar(data.r1(:,:))
% ylim([0 1])
% ylabel('R^2')
% ax3.XTickLabel=str0;
% % ax4=subplot(2,3,4);
% % bar(data.r1(i,:))
% % ylabel('R^2')
% % ylim([-.1 1.1])
% % ax5=subplot(2,3,5);
% % bar(data.reac(i,:))
% % ylabel('delay')
% % ax6=subplot(2,3,6);
% % bar(data.qpar(i,:))
% % ylabel('q')
% linkaxes([ax1 ax2 ax3],'x')
% end
c0=3*9.81/4;
figure(1004)
for i=1:size(data.a2,1)
subplot(6,4,i)
yyaxis right
hold on; 
plot(exp(data.a2(i,1:end-2))/c0,'linestyle','none','marker','d','color','r','markerfacecolor','r')
plot(6,exp(data.a2(i,end-1))/c0,'linestyle','none','marker','s','color','r','markerfacecolor','r')
plot(7,exp(data.a2(i,end))/c0,'linestyle','none','marker','o','color','r','markerfacecolor','r')
ylabel('$c/c_0$','interpreter','latex')
ylim(exp([2 3.5])/c0)
yyaxis left
grid on; box on;
plot([.5 7.5],[2 2],'b--')
plot([.5 7.5],[1 1],'b--')
plot(data.a1(i,1:end-2),'linestyle','none','marker','d','color','b','markerfacecolor','b')
plot(6,data.a1(i,end-1),'linestyle','none','marker','s','color','b','markerfacecolor','b')
plot(7,data.a1(i,end),'linestyle','none','marker','o','color','b','markerfacecolor','b')
text(1,2,sprintf('S%dq%d',sub(i),data.qpar(i)),'backgroundcolor','w','interpreter','latex')
ylabel('$\kappa$','interpreter','latex')
ylim([0 2.25])
xlabel('weeks','interpreter','latex')
set(gca,'xtick',[1 2 3 4 5 6 7],'xlim',[.5 7.5]);
end

weeks=1:7;
figure()
subplot(1,2,1)
hold on;grid on; box on;
plot([.5 7.5],[2 2],'b--')
plot([.5 7.5],[1 1],'b--')
errorbar(weeks,mean(data.a1),std(data.a1),'linestyle','none','marker','d','color','b','markerfacecolor','b')
ylabel('$\kappa$','interpreter','latex')
xlabel('weeks','interpreter','latex')
ylim([0 2.25])
xlim([.5 7.5])
subplot(1,2,2)
hold on;grid on; box on;
plot([.5 7.5],[1 1],'r--')
errorbar(weeks,mean(exp(data.a2)/c0),std(exp(data.a2)/c0),'linestyle','none','marker','d','color','r','markerfacecolor','r')
ylabel('$c/c_0$','interpreter','latex')
xlabel('weeks','interpreter','latex')
ylim([0 3.5])
xlim([.5 7.5])
set(gca,'xtick',[1 2 3 4 5 6 7],'xlim',[.5 7.5]);



% figure(1005)
% hold on; grid on; box on;
% for i=1:size(data.a1,2)
% plot(data.a1(i,:),markers{mod(i,12)+1},'color','k','markerfacecolor',cc)
% end
% ylabel('$a_2$','interpreter','latex')
% xlabel('weeks','interpreter','latex')
% set(gca,'xtick',[1 2 3 4 5 6],'xlim',[.5 6.5]);