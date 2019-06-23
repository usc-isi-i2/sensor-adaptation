function [obj error] = learn_mmd_rbf(trX, trY, teX, teZ, target, degree, lambda, scale)

% trX: D*N
% trY: D*1
% teX: D*M
% teU: V*M   V > D
% degree, lambda used in polynomial regression
% b, c used in the kernel

N = size(trX,2);
M = size(teX,2);

MAX_ITER = 200;

L = -ones(N+M,N+M)/(N*M);
L(1:N, 1:N) = 1/(N^2);
L(N+1:N+M, N+1:N+M) = 1/(M^2);

teV = [ generate_feature([teX; teZ], degree); ones(1, size(teZ,2))];

% initialize w
w = learn_linear_reg( [generate_feature([trX; zeros(size(teZ,1),size(trX,2))], degree); ones(1,size(trX,2))], trY, lambda);

%w0 = learn_linear_reg( [generate_feature([teX; teZ], degree); ones(1,size(teX,2))], target, lambda);

%w = w0;
step_size = 0.1;

dist = L2_distance( [trX; trY], [trX; trY]);
md = median(dist(:));

iw = 1/(md*scale);

for iter = 1:MAX_ITER

    teY = w'*teV;
    all_data = [[trX; trY], [teX; teY]];
    
    G = L2_distance(all_data, all_data);
	K = exp( -G * iw );
    
    obj(iter) = sum(sum( K.*L )) + lambda * w'*w;
    error(iter) = sum( (teY-target).^2 );
    
    fprintf('iter = %g, obj = %.5f, error = %.5f\n', iter, obj(iter), error(iter));
    
    % computing gradient
    A = K(N+1:N+M,N+1:N+M).*L(N+1:N+M,N+1:N+M);
    g = -2*iw * teV* (diag( sum(A,2) ) + diag( sum(A) ) -2*A) *teV'*w ;
    
    B = K(N+1:N+M,1:N).*L(N+1:N+M,1:N);
    g = g + 2*iw * teV*B*trY' - 2*iw * teV * diag( sum(B,2) ) * teV'*w  + 2*lambda*w;
    
    w = w - step_size * g;
end