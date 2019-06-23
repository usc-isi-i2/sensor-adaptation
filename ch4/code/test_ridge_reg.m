function pred = test_ridge_reg(X_te, weight, min_val, max_val, d)

D = size(X_te,1);
%% scaling data
X_te = (X_te - repmat(min_val,1,size(X_te,2)) ) ./ repmat( max_val-min_val+0.5, 1, size(X_te,2) );

if d == 1
    new_X_te = X_te;
end

if d >= 2
    
    new_X_te = X_te;
    
    for i = 1:D
        for j = i:D
            new_X_te = [new_X_te; X_te(i,:).*X_te(j,:)];
        end
    end
end

new_X_te = [new_X_te; ones(1,size(new_X_te,2))];
pred = weight'*new_X_te;