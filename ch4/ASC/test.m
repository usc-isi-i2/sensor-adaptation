% G = rand(4,100);
% X = rand(5,100);
% W = rand(4,5);

gamma = 0.1;
load('para.mat');
W = W_init;

V = G - W*X;
obj = gamma * sum( sum(V.^2) )

W = G*X' * inv( X*X' );

V = G - W*X;
obj = gamma * sum( sum(V.^2) )