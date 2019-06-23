function [opt_d, opt_lambda, min_err] = cross_validation(X, Y)

N = size(X,1);
T = 10;

gap = floor(N/T);
rand('seed', 2018);

for i = 1:T
    sel = ones(1,N);
    test_idx = [ gap*(i-1)+1: gap*i ];
    
    if i == T
        test_idx = [ gap*(i-1)+1: N ];
    end
    
    sel( test_idx ) = 0;
    
    train_idx = find(sel == 1);
    
    trainX{i} = X(train_idx,:);
    trainY{i} = Y(train_idx,:);
    testX{i} = X(test_idx,:);
    testY{i} = Y(test_idx,:);
end

min_err = 1e8;
for d = 1:2
    for lambda = [1,1e-1,1e-2,1e-3]
        
        err = 0;
        for i = 1:T
            [weight, min_val, max_val] = train_ridge_reg(trainX{i}', trainY{i}', d, lambda);
            pred = test_ridge_reg(testX{i}', weight, min_val, max_val, d);
            err = err + sum( (pred-testY{i}').^2 );
        end
        err = sqrt( err/N );
       
        if err < min_err
            min_err = err;
            opt_d = d;
            opt_lambda = lambda;
        end
    end
end

