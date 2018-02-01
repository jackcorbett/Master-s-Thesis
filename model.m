function [A,Bu,Bmeal,C]=model(BW, Gb, SI)

% Population Parameters
Sg = .01000;
Vg = 1.6000 ;
p2 = .02000;
%ktau = .0893;
ktau = .02;
kabs = .01193;
f = .9;
ksc = .09088;
kd = .02;
kcl = .16; % Caumo, Florea, Luzi have two clearance parameters: .125 (from plasma) .185 from (liver)
VI = .06005;

% Linearized continuous-time model
Ac=[    -Sg     -Gb     0   0   0               0       0       (kabs*f/(Vg*BW))
        0       -p2     0   0   (p2*SI/(VI*BW)) 0       0       0
        0       0       -kd 0   0               0       0       0
        0       0       kd  -kd 0               0       0       0
        0       0       0   kd  -kcl            0       0       0
        ksc     0       0   0   0               -ksc    0       0
        0       0       0   0   0               0       -ktau   0
        0       0       0   0   0               0       ktau    -kabs];
Buc = [0 0 1 0 0 0 0 0]';
Bmealc = [0 0 0 0 0 0 1 0]';
Cc=[0 0 0 0 0 1 0 0];


% continuous to dscrete transformation by hand
h = 5;
[n,m]=size(Buc);
F=expm([[Ac Buc]*h; zeros(m,n+m)]);
A=F(1:n,1:n);
Bu=F(1:n,n+1:end);

F=expm([[Ac Bmealc]*h; zeros(m,n+m)]);
Bmeal=F(1:n,n+1:end);

C = Cc;