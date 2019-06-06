function pred = kernel_ridge_reg(X, Y, X_te, d, lambda)

% K = (X'*X+1).^d;
% K_te = (X'*X_te+1).^d;
% N = size(Y,1);
% pred = Y / (K+lambda*eye(N)) * K_te;
X = X/10; Y=Y/10; X_te=X_te/10;

D = size(X,1);

if d == 1
    new_X = X;
    new_X_te = X_te;   
end

for r = 1:D
    term_set{r} = num2str(r);
end
cc = D;

if d >= 2
    new_X = X;
    
    for i = 1:D
        for j = 1:D
            new_X = [new_X; X(i,:).*X(j,:)];
            cc = cc + 1;
            term_set{cc} = [num2str(i),'_',num2str(j)];
        end
    end
    
    new_X_te = X_te;
    
    for i = 1:D
        for j = 1:D
            new_X_te = [new_X_te; X_te(i,:).*X_te(j,:)];
        end
    end
end

if d == 3
    
    for i = 1:D
        for j = 1:D
            for p = 1:D
                new_X = [new_X; X(i,:).*X(j,:).*X(p,:)];
                
                cc = cc + 1;
                term_set{cc} = [num2str(i),'_',num2str(j),'_',num2str(p)];
            end
        end
    end
    
    for i = 1:D
        for j = 1:D
            for p = 1:D
                new_X_te = [new_X_te; X_te(i,:).*X_te(j,:).*X_te(p,:)];
            end
        end
    end
end

new_X = [new_X; ones(1,size(new_X,2))];
new_X_te = [new_X_te; ones(1,size(new_X_te,2))];
w = inv(new_X*new_X'+lambda*eye(size(new_X,1)))*new_X*Y';
pred = w'*new_X_te;

pred=pred*10;