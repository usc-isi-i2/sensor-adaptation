function [W1, W2] = DA_two_domains(Z, X1, X2, Xh1, Xh2, lambda)

% Z: d*T, X1: D*T, X2: D*T
% Xh1: D*Th, Xh2: D*Th
% lambda: regularization para

%% initialization
W1 = (Z*X1')/(X1*X1');
W2 = (Z*X2')/(X2*X2');

%% iterative update
MAX_ITER = 10;

for iter = 1:MAX_ITER
    obj(iter) = obj_value(W1, W2, Z, X1, X2, Xh1, Xh2, lambda);
    
    % fix W1
    G1 = W1*Xh1;
    W2 = ( Z*X2' + lambda*G1*Xh2') / ( X2*X2' + lambda* Xh2*Xh2' );
    % fix W2
    G2 = W2*Xh2;
    W1 = ( Z*X1' + lambda*G2*Xh1') / ( X1*X1' + lambda* Xh1*Xh1' );
end

function obj = obj_value(W1, W2, Z, X1, X2, Xh1, Xh2, lambda)

A1 = Z - W1*X1;
A2 = Z - W2*X2;
A3 = W1*Xh1 - W2*Xh2;

obj =  sum(sum(A1.^2)) + sum( sum(A2.^2) )  + lambda * sum( sum(A3.^2) );