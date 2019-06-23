function [ProMat eval] = myPCA(A,dim)
% PCA
% A: data matrix: n*d
% dim: required dim, could be larger than n

% ProMat: l*d,  A_new = A*ProMat'

A = A';
[rows, cols] = size(A);    % rows = d, cols = n

if(nargin < 2)
    dim = rows;
end

dim = min(dim, rows);

% subtract mean
meanA = mean(A,2);
A = A - meanA*ones(1, cols);

noise_level = 1e-6;
[evec eval] = eig(A*A'/cols+noise_level*eye(rows));      % add noise, to make the covariance matrix to be fully ranked

[eval ind]  =  sort(-1*diag(eval));

ProMat= evec(:, ind(1:dim))';