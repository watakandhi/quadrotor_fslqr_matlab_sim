%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Model
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

% NonLinear Model
function dX = getNonlineardX_earth(X, U, Vw)
% Physical Parameters of Quadrotor
setParameters

% States
u=X(4,1);     v=X(5,1);     w=X(6,1);
phi=X(7,1);   th=X(8,1);    psi=X(9,1);
p=X(10,1);    q=X(11,1);    r=X(12,1);

% Force and Torques
f = U(1,1);   tx = U(2,1);  ty = U(3,1);  tz = U(4,1);

% Nonlinear Equation of Motion
fxu=[u;
     v;
     w;
     f/m*(cos(phi)*sin(th)*cos(psi)+sin(phi)*sin(psi)); % nearly equal to f/m*th (if psi=0)
     f/m*(cos(phi)*sin(th)*sin(psi)-sin(phi)*cos(psi)); % nearly equal to -f/m*phi
     f/m*(cos(phi)*cos(th))-g; % nearly equal to Uhat
     p;
     q;
     r;
     ((Iyy-Izz)*q*r + tx)/Ixx; 
     ((Izz-Ixx)*p*r + ty)/Iyy; 
     ((Ixx-Iyy)*p*q + tz)/Izz]; 
 
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
      0        0       0       0         1/Iyy   0;
      0        0       0       0       0       1/Izz]; 
Dd = Dd(1:12, 1:3);
Cd = diag([0.25 0.25 0.25]);

% dX = fxu + Dd*wgn(size(Dd,2),1, 0.1);
dX = fxu + 1/2*rho*Dd*Cd*Vw.^2;
% dX = fxu;