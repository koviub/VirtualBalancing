par.L=1;%15;%.0284;
par.g=9.81;
par.In=1/3*par.L^2;
par.Gr=par.g*par.L/2;
% controller
par.tau=.15;%.05;
par.p=25;
par.d=6;
par.a=0;

par.q=1;

par.h=.0005;
par.r=100;

[ps,pe,ds,de]=PDRegion(par,12);

plot(par.p,par.d,'r*')


par.L=.5886;%15;%.0284;
[ps,pe,ds,de]=PDRegion(par,12);