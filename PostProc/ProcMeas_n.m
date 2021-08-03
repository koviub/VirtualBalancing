function resu=ProcMeas_n(job,num)

if nargin<2
    num=1;
end
n=1;
names = {};

%% Data processing
% cycle through tests
addpath(job);
f_o=dir(job);
f_o={f_o.name};
f = f_o(3:end);

% count files

for j=1:length(f)
    str1 = fullfile(job,cell2mat(f(j)));
    addpath(str1);
    f2_o=dir(str1);
    f2_o={f2_o.name};
    file = f2_o(3:end);
    for k=1:length(file)
        fn=cell2mat(file(k));
        str2=fullfile(str1,fn);
        names{n}=str2;
        n=n+1;
    end
end


% get data from files
waitbar_h = waitbar(0,sprintf('Reading data... 0-%d',length(names)));
n = 1;
nn=length(names);
DEL=[];LEN=[];DATE=[];QQ=[];NAME=[];


for j=1:length(f)
    str1 = fullfile(job,cell2mat(f(j)));
    addpath(str1);
    f2_o=dir(str1);
    f2_o={f2_o.name};
    file = f2_o(3:end);
    m=1;delays=[];lens=[];lengths={};
    for k=1:length(file)
        fn=cell2mat(file(k));
        fn=fn(1:end-4);
        tn=split(fn,'_');
        tn=strrep(tn,',','.');
        temp=strcmp(tn,'Reaction');
        temp=find(temp,1);
        str2m=fullfile(str1,cell2mat(file(k)));
        str2=strrep(str2m,',','.');
        % if blank test dont do anythying; size of tn  6 ??
        
        
        if(isempty(temp))
            res=ImportData(str2m);
            resi=struct('Len',res.L,'Del',res.tau,'Q',res.q,'Ts',...
                res.Ts,'dT',res.dT,'src',res.srs,'fn',str2);
            
            if isempty(find(strcmp(tn,'B'),1))
            res1{k,j}=resi;
            if(m==1)
                delays(m)=resi.Del; % str2double(cell2mat(tn(end-2)));
                
                m=m+1;p=1;
            elseif(delays(m-1)~=resi.Del) % str2double(cell2mat(tn(end-2))))
                delays(m)= resi.Del; % str2double(cell2mat(tn(end-2)));
                
                m=m+1;p=1;
            end
            
            lengths{m-1,p}=resi.Len; % str2double(cell2mat(tn(end)));
            p=p+1;
            
            date=cell2mat(tn(end-4));
            parq=resi.Q;
            end
        else
            [av,sdev]=ImportReaction(str2);
            res2{j}=struct('mean',av,'dev',sdev,'fn',str2);
        end
        
        waitbar(n/nn,waitbar_h,sprintf('Reading data... %d-%d',n,nn));
        n=n+1;
        
    end
    % collect results
    for v=1:m-1
        ll=cell2mat(lengths(v,:));
        lens(v)=ll(end);
    end
    
    % rows contain the different days of meas
    col='b';
    LEN{end+1}=lens;
    DEL{end+1}=av+delays;
    DATE{end+1}=str2double(date);
    QQ{end+1}=parq;
    NAME{end+1}=tn{1};
    
    %         if(strcmp(f1(j),'q0'))
    %             col='b';
    %             LEN0=[LEN0;lens];
    %             DEL0=[DEL0;av+delays];
    %         else
    %             col='r';
    %             LEN1=[LEN1 lens];
    %             DEL1=[DEL1 av+delays];
    %         end
end

resu.L=LEN;
resu.T=DEL;
resu.Q=QQ;
resu.DATE=DATE;
resu.name=NAME;

close(waitbar_h);
cmap=parula(8);
figure(num);hold on;grid on;box on;
title(sprintf('%f',QQ{1}))
for i=1:size(DEL,2)
   [delta, ind]=sort(DEL{i}); 
   plot(delta,LEN{i}(ind),'color',cmap(i,:),'linestyle','none','marker','*')
   if QQ{i}==0
   ft0=fittype('a*x+b');
   ft1=fittype('a*x.^2+b');
   xp0=1;
   xp1=2;
   else
   ft1=fittype('a*x+b');
   ft0=fittype('a*x.^2+b');
   xp0=2;
   xp1=1;
   end
    aeh=[9.81*3/4 0];
    [fit0,gof0]=fit(delta.',LEN{i}(ind).',ft0,'startpoint',aeh);
    [fit1,gof1]=fit(delta.',LEN{i}(ind).',ft1,'startpoint',aeh);
    x=0:0.1:1;xv=x;
    y=fit0.a.*x.^xp0+fit0.b;
    yv=fit1.a.*x.^xp1+fit1.b;
    str=sprintf('N#%d,q:%d,a=%.3f,b=%.3f,R^2=%.3f|(R_{alt}^2=%.3f)',...
    i,QQ{i},fit0.a,fit0.b,gof0.rsquare,gof1.rsquare);
    pl(i)=plot(x,y,'color',cmap(i,:),'displayname',str,'linewidth',1.5);
    plot(xv,yv,'color',cmap(i,:),'linestyle',':','linewidth',1)
    
legend(pl)
xlabel('$\tau$[s]','interpreter','latex')
ylabel('$L_{\rm crit}$[m]','interpreter','latex')
set(gca,'Fontsize',9)

end
% tau=linspace(0,.7,50);
% L1=aeh*tau.^2;
% L2=aeh*tau;
% pl0=plot(tau,L1,'k','displayname',sprintf('a_{ref}=%.3f',3/4*9.81));
% plot(tau,L2,'k')

end