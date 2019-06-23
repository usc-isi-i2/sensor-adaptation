function err = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth)


N_train = size(rep_sensor,2);
N_rep_sensor = size(rep_sensor,1);
N_total = size(ref_sensor,2);


for idx_rep_sensor = 1:N_rep_sensor
    train_X = ref_sensor(:,1:N_train);
    train_Y = rep_sensor(idx_rep_sensor,:);
    
    test_data = [new_sensor(idx_rep_sensor,:); ref_sensor(:,N_train+1:N_total)];
    
    
    dim = 2;
    lambda = 1e2;
    
    [weight, min_val, max_val] = train_ridge_reg(train_X, train_Y, dim, lambda);
    
    test_X = ref_sensor(:,N_train+1:end);
    test_Y = ground_truth(idx_rep_sensor,:);
    
    pred = test_ridge_reg(test_X, weight, min_val, max_val, dim);
    
    
    err(idx_rep_sensor) = sqrt( mean( (pred-test_Y).^2 ) );
end

