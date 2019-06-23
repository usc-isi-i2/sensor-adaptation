function [ProMat eval] = myPCA(A,dim)

% PCA
% A: data matrix: n*d
% dim: required dim, could be larger than n

% ProMat: l*d,  A_new = A*ProMat'

% e.g.
%   data = rand(100, 20);       % 100 data points with 20 dim
%   P = myPCA(data, 5);         % project to 5 dim
%   new_data = data*P';         % get projection

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
[evec eval] = eig(A*A'/cols);      % add noise, to make the covariance matrix to be fully ranked

[eval ind]  =  sort(-1*diag(eval));

ProMat= evec(:, ind(1:dim))';