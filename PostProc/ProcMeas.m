function ProcMeas(job)

aeh=9.81*3/4;
n=1;
names = {};

%% Data processing
% cycle through tests
addpath(job);
f_o=dir(job);
f_o={f_o.name};
f = f_o(3:end);

% count files
for i=1:length(f)
    % cycle through q0 - q1 measurements
    str = fullfile(job,cell2mat(f(i)));
    addpath(str);
    f1_o=dir(str);
    f1_o={f1_o.name};
    f1 = f1_o(3:end);
    for j=1:length(f1)
        % cycle through files
        str1 = fullfile(str,cell2mat(f1(j)));
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
end

% get data from files
waitbar_h = waitbar(0,sprintf('Reading data... 0-%d',length(names)));
n = 1;
nn=length(names);
DEL0=[];DEL1=[];LEN0=[];LEN1=[];
for i=1:length(f)
    % cycle through q0 - q1 measurements
    str = fullfile(job,cell2mat(f(i)));
    addpath(str);
    f1_o=dir(str);
    f1_o={f1_o.name};
    f1 = f1_o(3:end);
    
    for j=1:length(f1)
        % cycle through files
        str1 = fullfile(str,cell2mat(f1(j)));
        addpath(str1);
        f2_o=dir(str1);
        f2_o={f2_o.name};
        file = f2_o(3:end);
        m=1;delays=[];lens=[];lengths={};
        for k=1:length(file)
            
            fn=cell2mat(file(k));
            fn=fn(1:end-4);
            tn=split(fn,'_');
            temp=strcmp(tn,'Reaction');
            temp=find(temp,1);
            str2=fullfile(str1,cell2mat(file(k)));
            
            if(isempty(temp))
                if(m==1)
                    delays(m)=str2double(cell2mat(tn(end-2)));
                    m=m+1;p=1;
                elseif(delays(m-1)~=str2double(cell2mat(tn(end-2))))
                    delays(m)=str2double(cell2mat(tn(end-2)));
                    m=m+1;p=1;
                end
                
                lengths{m-1,p}=str2double(cell2mat(tn(end)));
                p=p+1;
                
                res=ImportData(str2);
                res1{k,j}=struct('Len',res.L,'Del',res.tau,'Q',res.q,'Ts',...
                    res.Ts,'dT',res.dT,'src',res.srs,'fn',str2);
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
        if(strcmp(f1(j),'q0'))
            col='b';
            LEN0=[LEN0 lens];
            DEL0=[DEL0 av+delays];
        else
            col='r';
            LEN1=[LEN1 lens];
            DEL1=[DEL1 av+delays];
        end
    end
end

%% Visualize results
figure(1);hold on;grid on;box on;
plot(DEL0,LEN0,'b*')
plot(DEL1,LEN1,'r*')
tau=linspace(0,.7,50);
L1=aeh*tau.^2;
L2=aeh*tau;
pl0=plot(tau,L1,'k','displayname',sprintf('a_{ref}=%.3f',3/4*9.81));
plot(tau,L2,'k')

ft0=fittype('a*x');
ft1=fittype('a*x.^2');
[fitt0,gof0]=fit(DEL0.',LEN0.',ft0,'startpoint',aeh)
[~,gof0alt]=fit(DEL0.',LEN0.',ft1,'startpoint',aeh)
[fitt1,gof1]=fit(DEL1.',LEN1.',ft1,'startpoint',aeh)
[~,gof1alt]=fit(DEL1.',LEN1.',ft0,'startpoint',aeh)

pl1=plot(fitt0,'b-');
set(pl1,'displayname',sprintf('a_{q:0}=%.3f,R^2=%.3f|(R_{alt}^2=%.3f)',...
    fitt0.a,gof0.rsquare,gof0alt.rsquare));
pl2=plot(fitt1,'r-');
set(pl2,'displayname',sprintf('a_{q:1}=%.3f,R^2=%.3f|(R_{alt}^2=%.3f)',...
    fitt1.a,gof1.rsquare,gof1alt.rsquare));
legend([pl1,pl2,pl0])
xlabel('$\tau$[s]','interpreter','latex')
ylabel('$L_{\rm crit}$[m]','interpreter','latex')
xlim([0 .7])
ylim([0 7])
set(gca,'Fontsize',12)
close(waitbar_h);
end