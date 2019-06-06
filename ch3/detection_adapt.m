function [fail_conf, fail_type, adapt_val, adapt_err, failure_status] = detection_adapt(sensor_data, target_index, adapt_model, failure_status)

%% do actual detection
[adapt_val, adapt_err] = adapt(sensor_data, target_index, adapt_model);

orig_dev = sensor_data(target_index) - adapt_val;

FF = 5;
for i = 1:FF-1
    failure_status(i) = failure_status(i+1);
end
failure_status(FF) = orig_dev;

for i = FF+1:2*FF-1
    failure_status(i) = failure_status(i+1);
end
failure_status(2*FF) = sensor_data(target_index);

dev = abs(orig_dev);

fail_conf = normcdf(dev, 0, adapt_err)*2-1;


if fail_conf > 1
    
    zero_id = (failure_status == 0);   %% if not enough samples
    if sum(zero_id) > 0
        fail_type = -1;
    else
        
        if std(failure_status(FF+1:2*FF)) < 0.001 % sensor value no change
            fail_type = 1; % stuck-at
        elseif std(failure_status(1:FF)) < 0.1  % gap no change
            fail_type = 3; % mis-calibration
        else
            fail_type = 2; % high-noise
        end
    end
end
