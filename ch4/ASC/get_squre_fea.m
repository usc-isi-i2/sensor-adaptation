function Z = get_squre_fea(X)

Z = X;
d = size(X,1);

for i = 1:d
    for j = 1:d
        Z = [Z; X(i,:).*X(j,:)];
    end
end