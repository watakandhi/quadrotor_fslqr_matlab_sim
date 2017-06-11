%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Reference:  Quadrotor control: modeling, nonlinearcontrol design, and simulation
%               by FRANCESCO SABATINO
%   MODEL:
%               xdot = A*x + B*u + Dd*d
%               y    = C*x + D*u
%   where:      x = state;          % [x,y,z,u,v,w,phi,th,psi,p,q,r]
%               u = input;          % [f,tx,ty,tz]
%               d = disturbance;    % [fwx,fwy,fwz,twx,twy,tw]
%               y = output;         % Leave it for now. Depends on sensors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=logspace(-2,3,100);
%% States
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Quadrotor SS                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    x,  y,  z,  u,  v,  w, phi, th, psi, p, q,  r;
%{%
A = [0   0   0   1   0   0   0   0   0   0   0   0;
     0   0   0   0   1   0   0   0   0   0   0   0;
     0   0   0   0   0   1   0   0   0   0   0   0;
     0   0   0   0   0   0   0   -g  0   0   0   0;
     0   0   0   0   0   0   g   0   0   0   0   0;
     0   0   0   0   0   0   0   0   0   0   0   0;
     0   0   0   0   0   0   0   0   0   1   0   0;
     0   0   0   0   0   0   0   0   0   0   1   0;
     0   0   0   0   0   0   0   0   0   0   0   1;
     0   0   0   0   0   0   0   0   0   0   0   0;
     0   0   0   0   0   0   0   0   0   0   0   0;
     0   0   0   0   0   0   0   0   0   0   0   0];
 %}
ep=10^(-9);
%{
%    x,  y,  z,  u,     v,      w,      phi,    th,     psi,    p,      q,      r;
A = [0   0   0   1      -ep      ep      0       ep      -ep     0       0       0;
     0   0   0   ep     1       -ep     -ep     0       ep      0       0       0;
     0   0   0   -ep    ep      1       ep      -ep     0       0       0       0;
     0   0   0   0      ep      -ep     0       -g      0       0       -ep     ep;
     0   0   0   -ep    0       ep      g       0       0       ep      0       -ep;
     0   0   0   ep     -ep     0        0       0       0       -ep     ep      0;
     0   0   0   0      0       0       0       ep      0       1       0       ep;
     0   0   0   0      0       0       -ep     0       0       0       1       -ep;
     0   0   0   0      0       0       ep      0       0       0       ep      1;
     0   0   0   0      0       0       0       0       0       0       ep      ep;
     0   0   0   0      0       0       0       0       0       ep      0       ep;
     0   0   0   0      0       0       0       0       0       ep      ep      0];
%}
%{
 A = [-ep   0   0   1   0   0   0   0   0   0   0   0;
     0   -ep   0   0   1   0   0   0   0   0   0   0;
     0   0   -ep   0   0   1   0   0   0   0   0   0;
     0   0   0   -ep   0   0   0   -g  0   0   0   0;
     0   0   0   0   -ep   0   g   0   0   0   0   0;
     0   0   0   0   0   -ep   0   0   0   0   0   0;
     0   0   0   0   0   0   -ep   0   0   1   0   0;
     0   0   0   0   0   0   0   -ep   0   0   1   0;
     0   0   0   0   0   0   0   0   -ep   0   0   1;
     0   0   0   0   0   0   0   0   0   -ep   0   0;
     0   0   0   0   0   0   0   0   0   0   -ep   0;
     0   0   0   0   0   0   0   0   0   0   0   -ep];
 %}

%    f     tx      ty      tz
B = [0     0       0       0;
     0     0       0       0;
     0     0       0       0;
     0     0       0       0;
     0     0       0       0;
     -1/m  0       0       0;
     0     0       0       0;
     0     0       0       0;
     0     0       0       0;
     0     1/Ixx   0       0;
     0     0       1/Iyy   0;
     0     0       0       1/Izz];
C = eye(12); 
D = zeros(size(C,1), size(B,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Augmented Plant                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Cref = [1 0 0 0 0 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0 0 0 0 0;
        0 0 1 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 1 0 0 0];
Aap = [A    zeros(length(A), size(Cref,1));
       -Cref   zeros(size(Cref,1), size(Cref,1))];
Bap = [B; zeros(size(Cref,1), size(B,2))];
Cap = [C zeros(size(C,1), size(Cref,1))];
Dap = zeros(size(Cap,1), size(D,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Frequency Weight                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gain=1; 
f=0.1; ze=0.9; w=2*pi*f; num=[1 2*ze*w w^2]; den=[1 0 0]; 
f=50; ze=0.7; w=2*pi*f; numLow=[0 0 w^2]; denLow=[1 2*ze*w w^2];
f=0.5; ze=1.3; w=2*pi*f; numBand=[0 2*ze*w 0]; denBand=[1 2*ze*w w^2];
f1=0.01; f2=0.05;  w1=2*pi*f1; w2=2*pi*f2; numLag=[1 w2]; denLag=[1 w1]; 
f=0.5; ze=0.5; w=2*pi*f; numBef=[1 2*ze*w w^2]; denBef=[1 0 w^2];
    e = nd2sys(numLag, denLag, gain);
    q = nd2sys(numBand, denBand, 10);
    q_g = frsp(q, W); 
    e_g = frsp(e, W);
    xq=daug(q,q,1);
    xq1=daug(1,1,1);
    xe=daug(e, e, 1, 1);
    Xq=daug(xq, xq1, xq1, xq1, xe);
    [Aq,Bq,Cq,Dq]=unpck(Xq);
    
gain=1; f=1; ze=0.7; w=2*pi*f; num=[0 0 w^2]; den=[1 2*ze*w w^2]; 
% f=0.5; ze=1; w=2*pi*f; numBef=[1 2*ze*w w^2]; denBef=[1 0 w^2];
f1=5; f2=10; w1=2*pi*f1;w2=2*pi*f2; gain=gain*(w1/w2); numLead=[1 w2]; denLead=[1 w1]; 
%     num=conv(num,numBef); den=conv(den,denBef);
    r = nd2sys(numLead, denLead, gain);
    Xr=daug(1,r,r,1);
    [Ar,Br,Cr,Dr]=unpck(Xr);
    r_g = frsp(r, W); figure; vplot('liv,lm', q_g, r_g, e_g);
    title('Frequency Weight'); xlabel('Frequency [rad/s]'); ylabel('Gain [dB]'); legend('{\itW_q}', '{\itW_r}', '{\itW_e}');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Augmented General Plant                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aag=[Aap                              zeros(length(Aap),length(Aq))     Bap*Cr;
    Bq                                Aq                              zeros(length(Aq),length(Ar));
    zeros(length(Ar),length(Aap))     zeros(length(Ar),length(Aq))    Ar];
Bag=[Bap*Dr;
    zeros(length(Aq), size(Br,2));
    Br];
Cag=[Dq Cq zeros(size(Cq,1), length(Ar))]; Dag=zeros(size(Cag,1), size(Bag,2));
[K_lqr, Pg, e] = lqr(Aag, Bag, eye(size(Aag)), eye(size(Bag,2)));
Kx=K_lqr(:,1:length(Aap));     Kq=K_lqr(:,length(Aap)+1:length(Aap)+length(Aq));     Kr=K_lqr(:,length(Aap)+length(Aq)+1:length(Aap)+length(Aq)+length(Ar));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                Controller                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ak=[ Aq         zeros(length(Aq), size(Ar-Br*Kr,2));
     -Br*Kq     Ar-Br*Kr];
Bk=[ Bq; -Br*Kx];
Ck=[ -Dr*Kq  Cr-Dr*Kr];
Dk= -Dr*Kx;
Gk = pck(Ak, Bk, Ck, Dk);
Gk_g=frsp(Gk,W);
figure
vplot('liv,lm',vsvd(Gk_g)); 
legend('{\it f}','{\tau_x}','{\tau_y}','{\tau_z}'); grid on;
title('Controller');xlabel('Frequency [rad/s]'); ylabel('Gain [dB]');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Disturbance Resp                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pap = pck(Aap,Bap,Cap,Dap);
Wd = daug(daug(0, 0, 0, 1, 1, 1), daug(0, 0, 0, 0, 0, 0));

systemnames = ' Pap Wd ';
inputvar = '[ dist{12}; control{4} ]';
outputvar = '[ Pap; -Pap-Wd ]';
input_to_Wd = '[ dist ]';
input_to_Pap = '[ control ]';
sysoutname = 'sim_ic';
cleanupsysic = 'yes';
sysic
CL=starp(sim_ic, Gk, 12, 4);
CLtrans = sel(CL, 1:3, 1:12);
CLtrans_g=frsp(CLtrans,W);
figure
vplot('liv,lm',vsvd(CLtrans_g));
legend('{\it x}','{\it y}','{\it z}');
% legend('{\it x}','{\it y}','{\it z}','{\it u}','{\it v}','{\it w}');
title('Disturbance Response');xlabel('Frequency [rad/s]'); ylabel('Gain [dB]');

CLrotat = sel(CL, 7:9, 1:12);
CLrotat_g=frsp(CLrotat,W);
figure
vplot('liv,lm',vsvd(CLrotat_g));
legend('{\phi}','{\theta}','{\psi}');
% legend('{\phi}','{\theta}','{\psi}','{\it p}','{\it q}','{\it r}');
title('Disturbance Response');xlabel('Frequency [rad/s]'); ylabel('Gain [dB]');

%%
% Disturbances (This matrix will be needed for Hinfinity Controller)
%{
%   fwx,    fwy,    fwz,    twx,    twy,    twz
Dd = [0        0       0       0       0       0;
      0        0       0       0       0       0;
      0        0       0       0       0       0;
      1/m      0       0       0       0       0;
      0        1/m     0       0       0       0;
      0        0       1/m     0       0       0;
      0        0       0       0       0       0;
      0        0       0       0       0       0;
      0        0       0       0       0       0;
      0        0       0       1/Ixx   0       0;
      0        0       0       0       1/Iyy   0;
      0        0       0       0       0       1/Izz];
% this all should be 1. as disturbances applied will be the dryden wind
% model
% https://jp.mathworks.com/help/aeroblks/drydenwindturbulencemodeldiscrete.html
% a lot to think of
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             poles and zeros                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = pck(A,B,C,D);
% Bode Diagram of Plant P

P_g = frsp(P,W);
%{
for i=1:length(A)
   Psel_g = sel(P_g, i, 1:size(B,2));
   figure
   vplot('bode', Psel_g); title(sprintf('%i',i));
   legend('u','tx','ty','tz');
end
%}

% poles and pole diagram of Plant P
Pss = ss(A,B,C,D);
%{
for i=1:size(B,2)
    for j=1:size(A,1)
        bode(Pss(j,i),w); 
        hold on
    end
end
%}
% figure
% pzmap(Pss);

% Transfer Function of P (from 4inputs to 12 outputs)
tfmat = tf(Pss);
spoles(P)

%{
tf1=tf([1],[1 1]);
tf2=tf([1],[1 2 1]);
tf3=tf([1],[1 3 3 1]);
tf4=tf([1], [1 4 6 4 1]);
systf=[ 0   0   tf4     0;
        0   tf4 0       0;
        tf2 0   0       0;
        0   0   tf3     0;
        0   tf3 0       0;
        tf1 0   0       0;
        0   tf2 0       0;
        0   0   tf2     0;
        0   0   0       tf2;
        0   tf1 0       0;
        0   0   tf1     0;
        0   0   0       tf1];
Pss = ss(systf);
P = pck(Pss.A,Pss.B,Pss.C,Pss.D);
%}
%% Checking for Controllability & Observability
co=ctrb(A,B);
if rank(co)==size(A)
   disp('This system is controllable.')
else
   if rank(co)==0
      disp('This system is uncontrollable.')
   else
      disp('This system is stabilizable.')
   end
end
Controllability = rank(co)
obs=obsv(A,C);
if rank(obs)==size(A)
   disp('This system is observable.')
else
   if rank(obs)==0
      disp('This system is unobservable.')
   else
      disp('This system is detectable.')
   end
end
Observability = rank(obs)
