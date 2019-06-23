function [idx_A, idx_B] = select_stations(N_clus, N_sub)

rdp = randperm(N_clus);
A_clus = rdp(1);
B_clus = rdp(2);

A_sub = randi(N_sub);
B_sub = randi(N_sub);

idx_A.clus = A_clus;
idx_A.sub = A_sub;

idx_B.clus = B_clus;
idx_B.sub = B_sub;
