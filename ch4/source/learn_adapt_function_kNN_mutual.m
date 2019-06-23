function [w error_te error_va obj] = learn_adapt_function_kNN_mutual(trX, trX0, trY, teX, teX0, teZ, K, target, degree, lambda, flag_train)

% adapt to new sensors

% trX: D*N
% trY: 1*N
% teX: D*M
% teZ: d*M

N = size(trX,2);
M = size(teX,2);
teV = [ generate_feature([teX; teZ], degree); ones(1, size(teZ,2))];

dist = L2_distance(trX, teX);
[dum, idx_te] = sort(dist,2);


%% initializing w
D = size(trX,1);

gg = zeros(size(teZ,1),size(trX,2));
w = learn_linear_reg( [generate_feature([trX; gg], degree); ones(1,size(trX,2))], trY, lambda);
%w = learn_linear_reg( [generate_feature([teX; teZ], degree); ones(1,size(teX,2))], target, lambda);
%% alternating optimization
MAX_ITER = 50;

f0 = corr(trX0', trY');

for iter = 1:MAX_ITER
    
    teY = w'*teV;
    error_te(iter) = sum( (teY - target).^2 );
    
%     if iter == 1 || iter == 10
%         keyboard
%     end
    
    all_data = [trX, teX; trY, teY];
    all_y = [trY, teY];
    all_dist = L2_distance(all_data, all_data);
    
    dist = all_dist(1:N, N+1:N+M); 
    
    [dist, idx] = sort(dist,2);
    
    
    obj(iter) = lambda * w' * w;
    
    row_idx1 = [];
    row_idx2 = [];
    
    if flag_train == 1
        obj(iter) = obj(iter) + sum( sum( dist(:,1:K) ) );
        
        row_idx1 = repmat(1:N, K, 1);
        row_idx1 = row_idx1(:);
        row_idx2 = idx(:,1:K)';
        row_idx2 = row_idx2(:);
    end


    dist = all_dist(N+1:N+M, 1:N); 
    
    [dist, idx] = sort(dist,2);
    
    obj(iter) = obj(iter) + sum( sum( dist(:,1:K) ) );
    
    row_idx2_rev = repmat(1:M, K, 1);
    row_idx2_rev = row_idx2_rev(:);
    
    row_idx1_rev = idx(:,1:K)';
    row_idx1_rev = row_idx1_rev(:);   
    
    row_idx1 = [row_idx1; row_idx1_rev];
    row_idx2 = [row_idx2; row_idx2_rev];
    
    
 %   pred = mean( teY( idx_te(:,1:11) ), 2)';
 %   error_va(iter) = sum( (pred - trY).^2 );
  
    ff = corr(teX0', teY');
    
    dd = f0 - ff;
    error_va(iter) = dd'*dd;
 
    fprintf('iter = %g, obj = %.3f, error = %.3f, error-va = %.5f\n', iter, obj(iter), error_te(iter), error_va(iter));
    
    new_Y = trY(:, row_idx1 );
    new_X = teV(:, row_idx2 );
    
    w = learn_linear_reg(new_X, new_Y, lambda);
end