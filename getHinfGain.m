%% Weight -> xdot=Ax+Bu, y=Cx;
% draw general plant on a piece of paper
% xdot_in = Ain*xin, Bin*u*in;

% which weight?
% x,y,z for cetain omega/ u,v,w for low omega
% u for high omega
% [Ax, Bx, Cx, Dx] = tf2ss(num, den);

%% build general plant

%{
systemnames = ' P Ws Wt Wd Wn';
inputvar =  '[ dist{6}; noise{12}; control{4} ]';
outputvar = '[ Ws; Wt; -Wn-P]';
input_to_P = '[ Wd; control ]';
input_to_Ws = '[ Wn(1:6)+P(1:6) ]';
input_to_Wt = '[ control ]';
input_to_Wd = '[ dist ]';
input_to_Wn = '[ noise ]';
sysoutname = 'G';
cleanupsysic = 'yes';
sysic;
minfo(G)
[AG, BG, CG, DG] = unpck(G);
SYS = ss(AG,BG, CG, DG);
pzplot(SYS)
spoles(G)
spoles(Ws)
[K, CL, gamma] = hinfsyn(G,12,4,1,10,0.01,2);
%}
%{%
systemnames = 'P Ws Wt Wn';
inputvar = '[noise{4}; dist{12}; control{4}]';
outputvar = '[Ws; Wt; -P-dist]';
input_to_P = '[control+Wn]';
input_to_Ws = '[dist(1:3)+P(1:3)]';
input_to_Wt = '[control]';
input_to_Wn = '[noise]';
sysoutname = 'G';
cleanupsysic='yes';
sysic;
[K,CL,GAM]=hinfsyn(G,12,4,1,10,0.01,2);
[Actr,Bctr,Cctr,Dctr]=unpck(K);

figure
omega = logspace(-2,6,100);
CL_g = frsp(CL,omega);
vplot('liv,lm',vsvd(CL_g))
title('Singular Value Plot of CL')
xlabel('Frequency (rad/sec)')
ylabel('Magnitude')
%}
%{
systemnames = 'P Ws Wt';
inputvar = '[ dist{12}; control{4} ]';
outputvar = '[ Ws; Wt; -P-dist ]';
input_to_P = '[ control ]';
input_to_Ws = '[ P(1:3)+dist(1:3) ]';
input_to_Wt = '[ control]';
sysoutname = 'G';
cleanupsysic='yes';
sysic;
[K,CL,GAM]=hinfsyn(G,12,4,1,10,0.01,2);
[Actr,Bctr,Cctr,Dctr]=unpck(K);
%}

systemnames = ' P ';
inputvar = '[ref{12}; noise{4}; dist{12}; control{4} ]';
outputvar = '[ P(1:3)+dist(1:3); ref-P-dist ]';
input_to_P = '[ control+noise ]';
sysoutname = 'sim_ic';
cleanupsysic = 'yes';
sysic

figure
clp=starp(sim_ic, K);
omega=logspace(-4,2,100);
Wp_g=frsp(Ws,omega);
Wpi_g=minv(Wp_g);
sen_loop=sel(clp,1:3,17:28);
sen_g=frsp(sen_loop,omega);
vplot('liv,lm', Wpi_g, 'm--', vnorm(sen_g), 'y-')
title('CLOSED-LOOP Sensitivity Function')
xlabel('Frequency [rad/s]'); ylabel('Magnitude');
legend('Inverse Weighting function', ...
        'Nominal Sensitivity function')
%%
spoles(K)
omega=logspace(-2,6,100);
clp_g=frsp(CL,omega);
vplot('liv,lm',vsvd(clp_g))

%}

%% think of if hinfsyn cannot solve?
% epsilon1
% ?g???ngeneral plant????
%

%% calculate K
% [K, CL, gamma] = hinfsyn(G,12,4,1,10,0.01,2);
