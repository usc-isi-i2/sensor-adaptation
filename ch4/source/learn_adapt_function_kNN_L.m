function [w error_te error_va obj] = learn_adapt_function_kNN_L(trX, trY, teX, teZ, vaX, vaY, K, target, degree, lambda)


% trX: D*N
% trY: 1*N
% teX: D*M
% teZ: d*M

% learn a transformation L: low_dim*D

N = size(trX,2);
M = size(teX,2);
teV = [ generate_feature([teX; teZ], degree); ones(1, size(teZ,2))];

%% initializing w
D = size(trX,1);
low_dim = D-1;

%w = learn_linear_reg( [generate_feature([teX; teZ], degree); ones(1,size(teX,2))], target, lambda);

w = learn_linear_reg( [generate_feature([trX; zeros(size(teZ,1),size(trX,2))], degree); ones(1,size(trX,2))], trY, lambda);

dist = L2_distance([trX;trY], [trX;trY]);

dist = sort(dist,2);
threshold = zeros(N,1);
for i = 1:N
    threshold(i) = 100;%dist(i,K+1); %mean( dist(i,1:K) );
end

%% alternating optimization
MAX_ITER = 30;

for iter = 1:MAX_ITER
    
    teY = w'*teV;
    
    error_te(iter) = sum( (teY - target).^2 );
    
    % updating nearest neighbors
    % dist = L2_distance([teX; target], [trX; trY]);
    
    if iter == 1
        dist = L2_distance([trX; trY], [teX; teY]);
    else
        dist = L2_distance([L*trX; trY], [L*teX; teY]);
    end
    
    [dist, idx] = sort(dist,2);
    
    obj(iter) = lambda * w' * w;
    
    cc = 0;
    for i = 1:N
        sub_idx = find( dist(i,1:K) < threshold(i) );
        
        if isempty(sub_idx)
            cc = cc + 1;
        end
        
        obj(iter) = obj(iter) + sum( dist(i,sub_idx) ); % + ( K-length(sub_idx) ) * threshold(i);
    end
  %  disp(cc);
 
    
    sub_dist = dist(:,1:K);
    
    G = 0;
    for i = 1:N
        for j = 1:K
            v = trX(:,i) - teX(:, idx(i,j));
            G = G + v*v'; 
        end
    end
    
    sub_dist = sub_dist(:);
    thresh = repmat( threshold, 1, K);
    thresh = thresh(:);
    idx_in = sub_dist < thresh;
    
    row_idx1 = repmat(1:N, K, 1);
    row_idx1 = row_idx1(:);
    row_idx2 = idx(:,1:K)';
    row_idx2 = row_idx2(:);
    
%     sub_dist = dist(:,1:K);
%     sub_dist = sub_dist(:);
%     idx_in = find( sub_dist <= R );
%     idx_out = find( sub_dist > R );
    
    %   fprintf('%g\n', length(idx_out));
  %  obj(iter) = sum( sub_dist(idx_in) ) + (R+1) * ( M*K-length(idx_in) ) + lambda * w'*w;
    
    % using test data to classify validation data
    if iter == 1
        dist_va = L2_distance([vaX; vaY], [teX; teY]);
    else
        dist_va = L2_distance([L*vaX; vaY], [L*teX; teY]);
    end
    
    [dist_va, idx_va] = sort(dist_va,2);
    
%     pred_va = mean( teY( idx_va(:,1:K) ),2 );
%     error_va(iter) = sum( (pred_va' - vaY).^2);

    error_va(iter) = sum( sum( dist_va(:,1:K) ) );
    
    fprintf('iter = %g, obj = %.3f, error = %.3f, error-va = %.3f\n', iter, obj(iter), error_te(iter), error_va(iter));
    
    % updating w
%     new_X = repmat(teV, 1, K);
%     new_idx = idx(:,1:K);
%     new_Y = trY( new_idx(:) );
%     
%     w = learn_linear_reg(new_X(:,idx_in), new_Y(:,idx_in), lambda);
    
    new_Y = trY(:, row_idx1(idx_in) );
    new_X = teV(:, row_idx2(idx_in) );
    
    w = learn_linear_reg(new_X, new_Y, lambda);
    
    if iter > 1
        old_L = L;
    end
    
    [VV,DD] = eig(G);
    L = VV(:,1:low_dim);
    L = L';
end