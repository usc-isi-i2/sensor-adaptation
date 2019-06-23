function [mi, grad] = compute_mutual_infoL(L, sX, sY, tX, flag)

noise = 1e-10;

Ns = size(sX,1);
Nt = size(tX,1);
dim = size(sX,2);

Dist = L2_distance(L'*sX', L'*tX');
expD = exp(-Dist);

P = expD ./ repmat( sum(expD), Ns, 1);

if flag == 1    % if on self
    P = P - diag( diag(P) );
end

C = length(unique(sY));
P_c = zeros(C, Nt);

Idx = zeros(Ns,C);
for i = 1:C
    id = (sY == i);
    Idx(id, i) = 1;
    R = sum( expD(id,:) );
    
    P_c(i,:) = sum( P(id,:) );
end

val1 = sum(P_c,2)/Nt;

f1 = entropy( val1 );

f1 = f1 - entropy( P_c(:) ) / Nt;

mi = f1;

%% compute gradient
% alpha
alpha_ct = ( log( P_c + noise) - repmat(log( val1+noise ), 1, Nt) )/Nt;
alpha = zeros(Ns, Nt);

for i = 1:C
    id = (sY == i);
    alpha(id,:) = repmat( alpha_ct(i,:), sum(id), 1);
end

% gamma
gamma = ( repmat( sum( alpha .* P ), Ns, 1) - alpha ).* P;

g = -sX'*gamma*tX - tX'*gamma'*sX;

g = g + sX'* diag(sum(gamma,2)) *sX + tX'* diag(sum(gamma))* tX;

grad = 2*g*L;

function etp = entropy(val)

noise = 1e-10;
etp = -sum( val .* log(val+noise) );