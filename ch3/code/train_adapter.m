function adapt_model = train_adapter(sensor_data, target_index)

MAX_TRAIN = 5000;
N_sensor = size(sensor_data,2);
N_sample = size(sensor_data,1);

if N_sample > MAX_TRAIN
    rdp = randperm(N_sample);
    sel = rdp(1:MAX_TRAIN);
    sel = sort(sel);
    Y = sensor_data(sel,target_index);
    X = sensor_data(sel,[1:target_index-1, target_index+1:N_sensor]);    
else
    Y = sensor_data(:,target_index);
    X = sensor_data(:,[1:target_index-1, target_index+1:N_sensor]);
end

% apply cross validation
[d, lambda, cv_err] = cross_validation(X, Y);

[weight, min_val, max_val] = train_ridge_reg(X', Y', d, lambda);


fprintf('idx %d \t min %.3f\t max %.3f\t std %.3f\t err %.3f d %d lambda %.3f\n', target_index, min(Y), max(Y), std(Y), cv_err, d, lambda);

adapt_model = [N_sensor; target_index; min_val; max_val; d; cv_err; weight];