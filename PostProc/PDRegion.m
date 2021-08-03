function [ps,pe,ds,de]=PDRegion(par,num)

if nargin<2
    dr=false;
else
    dr=true;
end

addpath('C:\Users\Kovacs Balazs\Desktop\MDBM-Matlab-master\code_folder')

b=3*9.81/2/par.L;
tau=par.tau;
a=par.a;
q=par.q;
II=par.In;
GG=par.Gr;

om=0.01:.01:300;

% HD (checking)
% p=((GG+II*om.^2).*cos(om.*tau))+a.*om.^2;
% d=((GG+II*om.^2).*sin(om.*tau))./om;

% "F=m*(q*a+(1-q)*v)" (PD)
% p=(b+q.*om.^2).*cos(om.*tau)+(1-q).*om.*sin(om.*tau);
% d=((b+q.*om.^2).*sin(om.*tau)-(1-q).*om.*cos(om.*tau))./om;

% PDA
p=((b+om.^2).*cos(om.*tau))+a.*om.^2;
d=((b+om.^2).*sin(om.*tau))./om;

%% Multi-Dimensional Bisection Method
% parameter dimension : 1
% co-dimension (number of equations): 1

ax=[];
ax(1).val=linspace(0,1000,51);  % om
par.interpolationorder=2;
Niteration=5;
bound_function_name='PDmax_fval';
mdbm_sol=mdbm(ax,bound_function_name,Niteration,[],par);

    frek_end=mdbm_sol.posinterp(1,2);

index=find(om>frek_end);
ds=d(1);

de1=d(index(1));
[pk,loc]=findpeaks(d);
    de0=pk(1);
    if index(1)<loc(1)
        de=de1;
    else
        de=de0;
    end


ps=p(1);
[pk,~]=findpeaks(p);
if(isempty(pk))
    pe=2*par.p;
else
    pe=pk(1);
end

if dr
    % figure(num);
    hold on;grid on
    plot(p,d,'b')
    plot([b b],[-de de]*2,'r')
    plot([-1 2]*pe,[0 0],'k:')
    plot([0 0],[-1,2]*de,'k:')
    rectangle('position',[ps ds abs(pe-ps) abs(de-ds)])
    xlim([0 pe+1])
    ylim([0-1 de+1])
end

end
