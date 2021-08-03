function resu=ProcMeas_blank(job,num)

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
    %     figure();
    %     hold on;grid on;box on;
    %     plot([.5 .5],[0 1],'k:')
    kk=1;
    T_react=[];
    asum=zeros(61,1);
    for k=1:length(file)
        fn=cell2mat(file(k));
        fn=fn(1:end-4);
        tn=split(fn,'_');
        tn=strrep(tn,',','.');
        temp=strcmp(tn,'Reaction');
        temp=find(temp,1);
        str2m=fullfile(str1,cell2mat(file(k)));
        str2=strrep(str2m,',','.');
        
        if(isempty(temp))
            res=ImportData(str2m);
            resi=struct('Len',res.L,'Del',res.tau,'Q',res.q,'Ts',...
                res.Ts,'dT',res.dT,'src',res.srs,'fn',str2);
            
            if ~isempty(find(strcmp(tn,'B'),1))
                res1{k,j}=resi;
                % resi blank-out test ertekelese feldolgozása
                
                ts=resi.Ts;
                td=resi.dT;
                t=resi.src.t;
                x_raw=resi.src.x;
                x=smooth(t,x_raw,0.016,'rloess');
                v_raw=[0;diff(x_raw)];
                v=smooth(t,v_raw,0.016,'rloess');
                a_raw=resi.src.xpp;
                a=smooth(t,a_raw,0.016,'rloess');
                fi=resi.src.fi;
                om_raw=[0;diff(fi)*60];
                om=smooth(t,om_raw,0.016,'rloess');
                
                tmp=find(t>ts);
                if ~isempty(tmp)
                    index0=tmp(1);
                    tmp=find(t>ts+td);
                    if ~isempty(tmp)
                        index1=tmp(1);
                        tmp=find(t>ts+td+.5);
                        if ~isempty(tmp)
                            index2=tmp(1);
                            
                            sig=.1;
                            T=t(index0:index2)-t(index0);
                            if T(1)>=0&&(index2-index0)==60&&...
                                    abs(om(index1))<.05&&...
                                    abs(a(index1))<.065
                                %             weight=1/sqrt(sig)*(exp(-1/2*((T-.5)/sig).^2)+exp(-1/2*((T-.65)/sig).^2)+...
                                %                 exp(-1/2*((T-.8)/sig).^2)+exp(-1/2*((T-.9)/sig).^2));
                                X=x(index0:index2);
                                V=v(index0:index2);
                                A=a(index0:index2);
                                asum=asum+abs(A);
                                avr=asum/kk;
                                N=18;
                                a_int=zeros(length(A),1);
                                a_back=zeros(N,1);
                                a_front=zeros(N,1);
                                fi_back=zeros(N,1);
                                fi_front=zeros(N,1);
                                om_back=zeros(N,1);
                                om_front=zeros(N,1);
                                Pi=zeros(length(A),1);
                                if (length(A)+index1+N-1)<=length(a_raw)
                                    for i=1:length(A)-1
                                        dt=T(i+1)-T(i);
                                        a_int(i+1)=a_int(i)+abs(A(i+1))*dt;
                                        a_back=a_raw(index0+i-N:index0+i-1);
                                        a_front=a_raw(index0+i+1:index1+i+N);
                                        fi_back=fi(index0+i-N:index0+i-1);
                                        fi_front=fi(index0+i+1:index1+i+N);
                                        om_back=om_raw(index0+i-N:index0+i-1);
                                        om_front=om_raw(index0+i+1:index1+i+N);
                                        Pi(i+1)=.1*(mean(abs(a_back))-mean(abs(a_front)))^2+...
                                         50*(mean(abs(om_back))-mean(abs(om_front)))^2;
                                    end
                                end
                                
                                tmp=find(T>.6);
                                [pks,locs]=findpeaks(Pi(tmp),T(tmp));
                                [~,ind]=max(pks);
                                if ~isempty(locs)
                                    T_react(kk)=locs(ind)-td;
                                    av=mean(T_react);sdev=std(T_react);
                                    res0{j}=struct('mean',av,'dev',sdev,'data',T_react,'fn',str2);
                                    kk=kk+1;
                                    
                                    figure();
                                    subplot(2,1,1);hold on;
                                    yyaxis left
                                    rectangle('position',[0 0 td max(abs(A))],'Facecolor',[.8 .8 .8],'Edgecolor','k','linestyle','--')
                                    plot(T,abs(A),'displayname',fn)
                                    plot([locs(ind) locs(ind)],[0 max(abs(A))],'k--')
                                    ylabel('$|a|$[m/s$^2$]','interpreter','latex')
                                    yyaxis right
                                    plot(T,Pi,'k')
                                    plot(locs,pks,'k*')
                                    ylabel('$\Pi$[m$^2$/s$^4$]','interpreter','latex')
                                    xlabel('$t$[s]','interpreter','latex')
                                    subplot(2,1,2);hold on;
                                    yyaxis left
                                    rectangle('position',[0 min(fi(index0:index2)) td max(fi(index0:index2))-min(fi(index0:index2))],'Facecolor',[.8 .8 .8],'Edgecolor','k','linestyle','--')
                                    plot(T,fi(index0:index2),'b')
                                    ylim([min(fi(index0:index2)) max(fi(index0:index2))])
                                    plot([locs(ind) locs(ind)],[min(fi(index0:index2)) max(fi(index0:index2))],'k--')
                                    ylabel('$\varphi$[rad]','interpreter','latex')
                                    yyaxis right
                                    plot(T,om_raw(index0:index2),'r')
                                    ylim([min(om_raw(index0:index2)) max(om_raw(index0:index2))])
                                    plot([locs(ind) locs(ind)],[min(om_raw(index0:index2)) max(om_raw(index0:index2))],'k--')
                                    ylabel('$\omega$[rad/s]','interpreter','latex')
                                    xlabel('$t$[s]','interpreter','latex')
                                end
                            end
                        end
                    end
                end
            end
        else
            [av,sdev,data]=ImportReaction(str2);
            res2{j}=struct('mean',av,'dev',sdev,'data',data,'fn',str2);
        end
        
        waitbar(n/nn,waitbar_h,sprintf('Reading data... %d-%d',n,nn));
        n=n+1;
        
    end
    
    %plot(T,avr,'r','linewidth',2,'displayname','average')
    %             ylim([0 .2])
    %             legend('show')
    
    close all
end
resu.Blank=res0;
resu.React=res2;

close(waitbar_h);

end