function Eq = PDmax_fval(ax,par)
%%
%
NumEq=1;
NumVar=size(ax,2);

Eq=zeros(NumEq,NumVar);

for kax=1:NumVar
    
    om=ax(1,kax);
    
    b=3*9.81/2/par.L;
    tau=par.tau;
    a=par.a;
    
    Eq(1,kax)=(b+om.^2).*cos(om.*tau)+a.*om.^2-b;
end
end