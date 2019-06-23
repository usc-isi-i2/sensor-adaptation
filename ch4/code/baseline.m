function [w error_te error_va obj] = baseline(trX, trY, teX, teZ, K, target, degree, lambda, flag_train)

% baseline algorithms

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

w = learn_linear_reg( [generate_feature([trX; zeros(size(teZ,1),size(trX,2))], degree); ones(1,size(trX,2))], trY, lambda);
error0 = sum( (w'*teV - target).^2 )/M

w1 = learn_linear_reg( [generate_feature([teX; teZ], degree); ones(1,size(teX,2))], target, lambda);
error1 = sum( (w1'*teV - target).^2 )/M


%% predicting z
% w_z = learn_linear_reg( [generate_feature(teX, degree); ones(1,size(teX,2))], teZ, 1e-3);
% trZ = w_z' * [generate_feature(trX, degree); ones(1,size(trX,2))];
% w = learn_linear_reg( [generate_feature([trX; trZ], degree); ones(1,size(trX,2))], trY, lambda);
% error3 = sum( (w'*teV - target).^2 )/M

dist = L2_distance(trX, teX);
[dist,idx] = sort(dist,2);

pred = [];
for i = 1:N
    gg = mean(teZ(:,idx(i,1:K)),2);
    pred = [pred, gg];
end

dist = L2_distance([teX;teZ], [trX; pred]);
[dist,idx] = sort(dist,2);

pred = mean( trY(idx(:,1:K)), 2);
error4 = sum( (pred' - target).^2 ) / M

keyboard

% K2 = 5;
% dist = L2_distance(teX, trX);
% [dist,idx] = sort(dist,2);
% min_y = zeros(M,1);
% max_y = zeros(M,1);
% % 
% pred_set = zeros(M,K2);

% for i = 1:M
%     pred_set(i,:) = trY(idx(i,1:K2) );
%     min_y(i) = min(pred_set(i,:));
%     max_y(i) = max(pred_set(i,:));
%     
%     pred_avg(i) = mean( pred_set(i,:) );
%     pred_vari(i) = std( pred_set(i,:) )^2;
% end
% pred_vari = pred_vari / max(pred_vari);
% 
% gamma = 0.1;
% w = learn_linear_reg_constrain(w, teV, trX, trY, teX, min_y, max_y, lambda, gamma);

% TT = 100;
% sub_teX = teX(:,sel_idx(1:TT));
% sub_teZ = teZ(:,sel_idx(1:TT));
% sub_target = pred_x( sel_idx(1:TT) );
% w = learn_linear_reg( [generate_feature([sub_teX; sub_teZ], degree); ones(1,size(sub_teX,2))], sub_target, lambda);

% dist = L2_distance([trX;trY], [trX;trY]);
% dist = sort(dist,2);
% bd = median( dist(:) )*0.1;

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
MAX_ITER = 30;

for iter = 1:MAX_ITER
    
    teY = w'*teV;
    error_te(iter) = sum( (teY - target).^2 );
    
    % updating nearest neighbors
    % dist = L2_distance([teX; target], [trX; trY]);
    
%     if iter == 1 || iter == 20
%         keyboard
%     end
    
    all_data = [trX, teX; trY, teY];
    all_dist = L2_distance(all_data, all_data);
    
    dist = all_dist(1:N, N+1:N+M); %L2_distance([trX; trY], [teX; teY]);
    
    [dist, idx] = sort(dist,2);
   
%     error_va(iter) = 0;
% %     
%     for ss = 1:M
%   %      gg = repmat(teY(ss),1,K2) - pred_set(ss,:);
%         error_va(iter) = error_va(iter) + (teY(ss) - pred_avg(ss))^2 / ( pred_vari(ss) + 1e-5 );
%     end
    
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

%   
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
    
    error_va(iter) = 0;
    
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