function [xhat, p_vec] = retrospective_multihypothesis_kalman(siopt, fastingBG, BW, dCGM, dU, meal_mgpmin_hypotheses)

% Parameters
K1 = 200000;  % process noise covariance (needs to be double checked)
K2 = 100;   % sensor noise covariance (needs to be double checked)

% proceed with retroactive application of OLFC %%%%%%%%%%%%%%%%%%%%%%

% get patient model
[...
    A, ...
    Bu, ...
    Bmeal, ...
    C] = model(BW, fastingBG, siopt);
B = Bu;
G = Bmeal;

% get dimensions
ns = length(A(:,1));
ny = length(C(:,1));
nw = length(G(1,:));

% Planning Horizon
T = length(dU(:,1));

% Error, process noise, measurement noise covariances and weights
W = K1*eye(nw);
V = K2*eye(ny);
X0 = dare(A',C',G*W*G',V);

nH = length(meal_mgpmin_hypotheses(1,:));

% set up uniform priors
priors = ones(1,nH)/nH;
p_vec = zeros(T,nH);
lik_vec = zeros(T,nH);

% data structure initialization
x0bar = zeros(ns,1);
x = x0bar;
y_vec = zeros(T,ny);
xbreve = zeros(ns,nH);
xhat = zeros(ns,nH);
yhat = zeros(ny,nH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial observation - actually noise free!!
y = C*x;
y_vec(1,:) = y';

% Initialization of the filters
P = X0;
%Pbreve = A*P*A' + H*W*H';
Pbreve = P;
L = Pbreve*C'/(C*Pbreve*C'+V);
P = (eye(ns)-L*C)*Pbreve;
for h = 1:nH,
    xbreve(:,h) = x0bar;
    xhat(:,h) = xbreve(:,h) + L*(y-C*xbreve(:,h));
    yhat(:,h) = C*xbreve(:,h); %CORRECTED HERE
end

% Compute Posterior
dumtotal = 0;
for h = 1:nH
    dum = normpdf(y,yhat(:,h),sqrt(C*Pbreve*C'+V))*priors(h); %CORRECTED HERE
    p_vec(1,h) = dum;
    dumtotal = dumtotal + dum;
end
p_vec(1,:) = p_vec(1,:)/dumtotal;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Big Simulation
for t = 1:T-1,
    
%     t
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Simulate next sensor reading, noise free!!
    y = dCGM(t+1, 1);
    y_vec(t+1,:) = y';
    
    %y
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update filter gains (common to all hypotheses)
    Pbreve = A*P*A' + G*W*G';
    S = C*Pbreve*C'+V;
    L = Pbreve*C'/(S);
    P = (eye(ns)-L*C)*Pbreve;
    
    % Update Filters
    
    for h = 1:nH,
        xbreve(:,h) = A*xhat(:,h) ...
            + B * dU(t, 1) ...
            + G * meal_mgpmin_hypotheses(t,h);
        xhat(:,h) = xbreve(:,h) + L*(y-C*xbreve(:,h));
        yhat(:,h) = C*xbreve(:,h); %CORRECTED HERE
    end
    
    % Compute Posterior
    lik_total = 0;
    for h = 1:nH
        lik = normpdf(y,yhat(:,h),sqrt(C*Pbreve*C'+V))*p_vec(t,h); %CORRECTED HERE
        lik_vec(t+1,h) = lik;
        p_vec(t+1,h) = lik;
        lik_total = lik_total + lik;
    end
    p_vec(t+1,:) = p_vec(t+1,:)/lik_total;
    
end