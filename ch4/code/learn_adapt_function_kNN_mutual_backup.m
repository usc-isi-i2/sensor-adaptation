function [w error_te error_va obj] = learn_adapt_function_kNN_mutual(trX, trY, teX, teZ, K, target, degree, lambda)


% trX: D*N
% trY: 1*N
% teX: D*M
% teZ: d*M

N = size(trX,2);
M = size(teX,2);
teV = [ generate_feature([teX; teZ], degree); ones(1, size(teZ,2))];

L = -ones(M+N,M+N)/(M*N);
L(1:M,1:M) = ones(M,M)/(M^2);
L(M+1:M+N, M+1:M+N) = ones(N,N)/(N^2);

%% initializing w
D = size(trX,1);

w_cheat = learn_linear_reg( [generate_feature([teX; teZ], degree); ones(1,size(teX,2))], target, lambda);

w = learn_linear_reg( [generate_feature([trX; zeros(size(teZ,1),size(trX,2))], degree); ones(1,size(trX,2))], trY, lambda);

dist = L2_distance([trX;trY], [trX;trY]);
dist = sort(dist,2);
bd = median( dist(:) ) * 0.1;

% dist = sort(dist,2);
% threshold = zeros(N,1);
% for i = 1:N
%     threshold(i) = 10; % dist(i,K+1); %mean( dist(i,1:K) );
% end

% teY = w'*teV;
% error_init = sum( (teY - target).^2 );
% fprintf('initial error %.3f\n', error_init);
%

% teY = w'*teV;
% dist = L2_distance([teX; teY], [trX; trY]);
% [dist,idx] = sort(dist,2);
% 
% sel_te_idx = [];
% cc = 0;
% for i = 1:M
%     for j = 1:K
%         if dist(i,j) < threshold( idx(i,j) )
%             cc = cc + 1;
%             sel_te_idx(cc) = i;
%             pred(cc) = trY( idx(i,j) );
%         end
%     end
% end
% 
% if size(pred,1) > 1
%     pred = pred';
% end
% 
% w = learn_linear_reg( [generate_feature([teX(:,sel_te_idx); teZ(:,sel_te_idx)], degree); ones(1,length(sel_te_idx))], pred, lambda);

% dd = L2_distance([teX; target], [trX; trY]);
% [dum, idx] = sort(dd,2);
%
% pred2 = mean( trY( idx(:,1:K) ),2 );
% error_gt = sum( (pred2' - target).^2)

%% alternating optimization
MAX_ITER = 40;

for iter = 1:MAX_ITER
    
    teY = w'*teV;
    error_te(iter) = sum( (teY - target).^2 );
    
    % updating nearest neighbors
    % dist = L2_distance([teX; target], [trX; trY]);
    
%     if iter == 1 %|| iter == 1
%         keyboard
%     end
    
    all_data = [trX, teX; trY, teY];
    all_dist = L2_distance(all_data, all_data);
    
    dist = all_dist(1:N, N+1:N+M); %L2_distance([trX; trY], [teX; teY]);
    
    [dist, idx] = sort(dist,2);
    
    pred_tr = mean( teY( idx(:,1:K) ), 2);
    
    error_va(iter) = sum( (pred_tr' - trY).^2 );
    
    obj(iter) = lambda * w' * w;
    
    obj(iter) = obj(iter) + sum( sum( dist(:,1:K) ) );

    row_idx1 = repmat(1:N, K, 1);
    row_idx1 = row_idx1(:);
    row_idx2 = idx(:,1:K)';
    row_idx2 = row_idx2(:);
   

    dist = all_dist(N+1:N+M, 1:N); %L2_distance([teX; teY], [trX; trY]);
    
    [dist, idx] = sort(dist,2);
    
    obj(iter) = obj(iter) + sum( sum( dist(:,1:K) ) );
    
    row_idx2_rev = repmat(1:M, K, 1);
    row_idx2_rev = row_idx2_rev(:);
    
    row_idx1_rev = idx(:,1:K)';
    row_idx1_rev = row_idx1_rev(:);   
    
    row_idx1 = [row_idx1; row_idx1_rev];
    row_idx2 = [row_idx2; row_idx2_rev];

%     Kmat = exp( -all_dist / bd );
%     error_va(iter) = sum( sum( Kmat.*L ) );
    
    fprintf('iter = %g, obj = %.3f, error = %.3f, error-va = %.5f\n', iter, obj(iter), error_te(iter), error_va(iter));
    
    % updating w
%     new_X = repmat(teV, 1, K);
%     new_idx = idx(:,1:K);
%     new_Y = trY( new_idx(:) );
%     
%     w = learn_linear_reg(new_X(:,idx_in), new_Y(:,idx_in), lambda);
    
    new_Y = trY(:, row_idx1 );
    new_X = teV(:, row_idx2 );
    
    w = learn_linear_reg(new_X, new_Y, lambda);
end