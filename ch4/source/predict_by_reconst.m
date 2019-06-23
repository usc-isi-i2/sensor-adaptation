function img = predict_by_reconst(z, X)


lambda = 1e-2;

dim = length(z);
num = size(X,2);

H = X'*X + lambda * eye(num); 
f = X'*z;
Aeq = ones(1,num);

w = quadprog(H,f,[],[],Aeq,1,zeros(num,1),ones(num,1));
img = X(end,:)*w;
