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
%{
figure
vplot('liv,lm',vsvd(Gk_g)); 
legend('{\it f}','{\tau_x}','{\tau_y}','{\tau_z}'); grid on;
title('Controller');xlabel('Frequency [rad/s]'); ylabel('Gain [dB]');
%}
%%

Q = [10 0  0  0  0  0  0  0  0  0  0  0;
     0   10 0  0  0  0  0  0  0  0  0  0;
     0   0  1  0  0  0  0  0  0  0  0  0;
     0   0  0  1  0  0  0  0  0  0  0  0;
     0   0  0  0  1  0  0  0  0  0  0  0;
     0   0  0  0  0  1  0  0  0  0  0  0;
     0   0  0  0  0  0  1  0  0  0  0  0;
     0   0  0  0  0  0  0  1  0  0  0  0;
     0   0  0  0  0  0  0  0  1  0  0  0;
     0   0  0  0  0  0  0  0  0  1  0  0;
     0   0  0  0  0  0  0  0  0  0  1  0;
     0   0  0  0  0  0  0  0  0  0  0  1];
R = eye(4);
[K_lqr, P, e] = lqr(A, B, Q, R);
% [K, P, e] = lqr(A, B, Q, R);

Qap = [ 1   0  0  0  0  0  0  0  0  0  0  0;
        0   1  0  0  0  0  0  0  0  0  0  0;
        0   0  1  0  0  0  0  0  0  0  0  0;
        0   0  0  1  0  0  0  0  0  0  0  0;
        0   0  0  0  1  0  0  0  0  0  0  0;
        0   0  0  0  0  1  0  0  0  0  0  0;
        0   0  0  0  0  0  1  0  0  0  0  0;
        0   0  0  0  0  0  0  1  0  0  0  0;
        0   0  0  0  0  0  0  0  1  0  0  0;
        0   0  0  0  0  0  0  0  0  1  0  0;
        0   0  0  0  0  0  0  0  0  0  1  0;
        0   0  0  0  0  0  0  0  0  0  0  1];
eap = [ 1 0 0 0;
        0 1 0 0;
        0 0 1 0;
        0 0 0 1];
Qap = [ Qap                                 zeros(length(Qap), size(Bap,2));
        zeros(size(Bap,2), length(Qap))     eap];
    
Rap = eye(4);
[K_explqr, Pg, e] = lqr(Aap, Bap, Qap, Rap);
