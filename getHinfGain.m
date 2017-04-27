%% Weight -> xdot=Ax+Bu, y=Cx;
% draw general plant on a piece of paper
% xdot_in = Ain*xin, Bin*u*in;

% which weight?
% x,y,z for cetain omega/ u,v,w for low omega
% u for high omega
% [Ax, Bx, Cx, Dx] = tf2ss(num, den);

%% build general plant

systemnames = ' P Ws Wt Wd';
inputvar =  '[ dist{6}; control{4} ]';
outputvar = '[ Ws; Wt; -P]';
input_to_P = '[ Wd; control ]';
input_to_Ws = '[ P(1:6) ]';
input_to_Wt = '[ control ]';
input_to_Wd = '[ dist ]';
sysoutname = 'G';
cleanupsysic = 'yes';
sysic;
[K, CL, gamma] = hinfsyn(G,12,4,1,10,0.001,2);

%% think of if hinfsyn cannot solve?
% epsilon1
% �g��ngeneral plant����
%

%% calculate K
% [K, CL, gamma] = hinfsyn(G,12,4,1,10,0.01,2);
