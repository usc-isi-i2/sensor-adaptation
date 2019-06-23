function [f,g, mv] = loss_info_metricL(L, sX, sY, tX, lambda)


% sX: Ns*d
% tX: Nt*d
mv = 0;

noise = 1e-10;

Ns = size(sX,1);
Nt = size(tX,1);
dim = size(sX,2);

Dist = L2_distance(L'*sX', L'*tX');
expD = exp(-Dist);

P = expD ./ repmat( sum(expD), Ns, 1);

C = length(unique(sY));
Q = zeros(Ns, Nt);
P_c = zeros(C, Nt);

Idx = zeros(Ns,C);
for i = 1:C
    id = (sY == i);
    Idx(id, i) = 1;
    R = sum( expD(id,:) );
    Q(id,:) = repmat(R, sum(id), 1);
    
    P_c(i,:) = sum( P(id,:) );
end

Q = expD ./ Q;

val1 = sum(P_c,2)/Nt;

f1 = entropy( val1 );

f1 = f1 - entropy( P_c(:) ) / Nt;

f2 = entropy(Q(:)) / (Nt*C);

f = -(f1 + lambda*f2);  % for minimization purpose

%% compute gradient
% alpha
alpha_ct = ( log( P_c + noise) - repmat(log( val1+noise ), 1, Nt) )/Nt;
alpha = zeros(Ns, Nt);

for i = 1:C
    id = (sY == i);
    alpha(id,:) = repmat( alpha_ct(i,:), sum(id), 1);
end

% beta
beta = -log( Q + noise) / (Nt*C);

% gamma
gamma = ( repmat( sum( alpha .* P ), Ns, 1) - alpha ).* P;

beta_q_mat = zeros(Ns, Nt);
for i = 1:C
    id = (sY == i);
    
    beta_q_mat(id,:) = repmat( sum( beta(id,:) .* Q(id,:) ), sum(id),1);
end

gamma = gamma + lambda*(beta_q_mat - beta).*Q;

g = -sX'*gamma*tX - tX'*gamma'*sX;

g = g + sX'* diag(sum(gamma,2)) *sX + tX'* diag(sum(gamma))* tX;

g = -2*g*L;% for minimization purpose


function etp = entropy(val)

noise = 1e-10;
etp = -sum( val .* log(val+noise) );



