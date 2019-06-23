function [f,g] = loss_info_metric_v2(M, sX, sY, tX, lambda)


% sX: Ns*d
% tX: Nt*d

[mi, grad] = compute_mutual_info(M, sX, sY, tX, 0);

all_data = [sX; tX];
all_label = [ones( size(sX,1), 1); zeros( size(tX,1), 1)];
[mi2, grad2] = compute_mutual_info(M, all_data, all_label, all_data, 1);

f = -(mi - lambda*mi2);
g = -(grad - lambda*grad2);
g = g(:);






