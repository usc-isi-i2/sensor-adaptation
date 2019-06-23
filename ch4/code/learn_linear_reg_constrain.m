function w = learn_linear_reg_constrain(w0, teV, trX, trY, teX, min_y, max_y, lambda, gamma)


D = size(teV,1);
M = size(teV,2);

teV_mean = mean(teV,2);

d = size(trX,1);
P = zeros(D,d+1);
f = zeros(d+1,1);

for i = 1:d
    u = trX(i,:);
    v = trY;
    N = length(u);
    f(i) = (u - repmat( mean(u), 1, N )) * (v - repmat( mean(v), 1, N))' / N;
    
    P(:,i) = ( teV - repmat( teV_mean, 1, M ) ) * teX(i,:)' / M;
end

P(:,d+1) = teV_mean;  % mean of trX
f(d+1) = mean(trY);

H = 2*P*P' + 2*lambda*eye(D);
f = -2*f'*P';
f = f';

MAX_ITER = 8000;
step_size = 1e-4;

w = w0;

fprintf('initializing w\n');
for iter = 1:MAX_ITER
    [obj(iter),g] = obj_fun(w, H, f, teV, min_y, max_y, gamma);
    
    w = w - step_size * g;
    
%     if iter > 1
%         if obj(iter) < obj(iter-1)
%             step_size = step_size * 1.1;
%         elseif obj(iter) > obj(iter-1)
%             step_size = step_size * 1.8;
%         end
%     end
end
fprintf('initialized w\n');

function [obj,g] = obj_fun(w, H, f, teV, min_y, max_y, gamma)

obj = w'*H*w/2 + f'*w;
g = H*w + f;

pred = teV'*w;

xi = pred - max_y;
N = length(xi);
for i = 1:N
    if xi(i) > 0
        obj = obj + gamma * xi(i) * xi(i);
        g = g + 2 * gamma * xi(i) * teV(:,i);
    end
end

xi = min_y - pred;
for i = 1:N
    if xi(i) > 0
        obj = obj + gamma * xi(i) * xi(i);
        g = g - 2 * gamma * xi(i) * teV(:,i);
    end
end
