function adapt_info = adapt(sensor_data, target_index, adapt_model)

N_sensor = adapt_model(1);

min_val = adapt_model(3:1+N_sensor);
max_val = adapt_model(2+N_sensor:2*N_sensor);
d = adapt_model(2*N_sensor+1);
cv_err = adapt_model(2*N_sensor+2);
weight = adapt_model(2*N_sensor+3:end);

X_te = sensor_data(:,[1:target_index-1,target_index+1:N_sensor]);

adapt_val = test_ridge_reg(X_te', weight, min_val, max_val, d);

adapt_err = cv_err;

if adapt_val > 1.5 && adapt_val < 4.5
    adapt_info(1) = adapt_val;
    adapt_info(2) = adapt_err;
else
    adapt_info(1) = 2.84;
    adapt_info(2) = adapt_err;
end