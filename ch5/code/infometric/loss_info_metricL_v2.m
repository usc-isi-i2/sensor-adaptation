function [f,g,mv] = loss_info_metricL_v2(L, sX, sY, tX, lambda)



% sX: Ns*d
% tX: Nt*d

[mi, grad] = compute_mutual_infoL(L, sX, sY, tX, 0);

all_data = [sX; tX];
all_label = [ones( size(sX,1), 1); zeros( size(tX,1), 1)];
[mi2, grad2] = compute_mutual_infoL(L, all_data, all_label, all_data, 1);

f = -(mi - lambda*mi2);
g = -(grad - lambda*grad2);

mv = 0;
