% close all
clear all

load('data/ED_learnData.mat')
n=length(resu);
cmap=parula(8);

jok=[1 2 3 4 5 7 8 9 10 11 12 13 14 15 22 23 24 25 26 27 28];
jok1=[4 5 8 12 15 22 24 27 28];
majdnem=[1 2 3 7 9 10 11 13 14 23 25 26];
rossz=[6 16 17 18 19 20 21];
sub=jok1;%1:21;%([3 4 7 8 16]); %  subjects to investigate

jok1=[4 5 8 12 15 22 24 27 28];

q1=[4 5 6 8 12 15 16 17 18 19 20 21 24 27 28];
q0=setdiff(sub,q1);
data.a1=zeros(length(sub),6);
data.b1=zeros(length(sub),6);
data.c1=zeros(length(sub),6);
data.r1=zeros(length(sub),6);
data.ra=zeros(length(sub),6);
data.reac=zeros(length(sub),6);
compdelay=.008+.05; % sampling and filter delay

a0=3/4*9.81;
% a*x^2+b*x+c???
ft0=fittype('a*x');
ft1=fittype('a*x.^2');
% ft=fittype('a*x^2+b*x+c');
% ft=fittype('a*x^2/(b*x+c)');
x=0:.1:1;
str0={};
for i=1:length(sub)
    res=resu{sub(i)};
    LEN=res.L;
    DEL=res.T;
    q=res.Q;
    figure(sub(i));
    title(sprintf('%s',res.name{1}))
    xlim([0 1])
    ylim([0 15])
    cla
    pl=[];
    hold on;grid on;box on;
    k=1;
    for j=1:size(DEL,2)
        if j<7
        [delta, ind]=sort(compdelay+DEL{j});
        len=LEN{j}(ind);
        plot(delta,len,'color',cmap(j,:),'linestyle','none','marker','*')
        if q{j}~=0
            ft=ft1;
            fta=ft0;
            p=2;pa=1;
        else
            ft=ft0;
            fta=ft1;
            p=1;pa=2;
        end
        [fit0,gof]=  fit(delta.',len.',ft,'startpoint',[a0]);
%         [fita,gofa]=fit(delta.',len.',fta,'startpoint',[a0 0]);
        y=fit0.a*x.^p;
%         ya=fita.a*x.^pa+fita.b;
        str=sprintf('N#%d,q:%d,%.3f*x^2,R^2=%.3f',...
            j,q{j},fit0.a,gof.rsquare);
        pl(k)=plot(x,y,'color',cmap(j,:),'displayname',str,'linewidth',0.5);
%         plot(x,ya,'color',cmap(j,:),'linestyle',':','linewidth',1)
        legend(pl,'Location','northwest')
        xlabel('$\tau$[s]','interpreter','latex')
        ylabel('$L_{\rm crit}$[m]','interpreter','latex')
        k=k+1;
        data.a1(i,j)=fit0.a;
%         data.b1(i,j)=fit0.b;
%         data.c1(i,j)=fit0.c;
        data.r1(i,j)=gof.rsquare;
%         ra(i,j)=gofa.rsquare;
        data.reac(i,j)=delta(1);
        data.qpar(i,j)=q{j};
        end
    end
    str0{i}=sprintf('%d',data.qpar(i,1));
end


figure()
% for i=1:length(sub)
% figure(sub(end)+sub(i))
ax1=subplot(1,3,1);
bar(data.a1(:,:))
ylabel('a')
ax1.XTickLabel=str0;
ax2=subplot(1,3,2);
bar(data.r1(:,:))
ylabel('R^2')
ylim([0 1])
ax2.XTickLabel=str0;
ax3=subplot(1,3,3);
bar(data.reac(:,:))
ylabel('\tau')
ax3.XTickLabel=str0;
% ax4=subplot(2,3,4);
% bar(data.r1(i,:))
% ylabel('R^2')
% ylim([-.1 1.1])
% ax5=subplot(2,3,5);
% bar(data.reac(i,:))
% ylabel('delay')
% ax6=subplot(2,3,6);
% bar(data.qpar(i,:))
% ylabel('q')
linkaxes([ax1 ax2 ax3],'x')
% end