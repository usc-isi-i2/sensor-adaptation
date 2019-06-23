function output_info = detection(sensor_data, target_index, adapt_model,failure_status)

%% do actual detection
threshold = 0.8;

adapt_info = adapt(sensor_data, target_index, adapt_model);

adapt_val = adapt_info(1);

adapt_err = adapt_info(2);

dev = abs( sensor_data(target_index) - adapt_val );

FF = 10;
for i = 1:FF-1
    failure_status(i) = failure_status(i+1);
end
failure_status(FF) = dev;


for i = FF+1:2*FF-1
   
    failure_status(i) = failure_status(i+1);

end
failure_status(2*FF) = sensor_data(target_index);


fail_type = 0;
fail_conf = 0;

WINDOW = 3;

num_fail = sum( failure_status(1:FF) > threshold );

if adapt_val > 5 || adapt_val < 2.3
    
    if std(failure_status(2*FF-WINDOW:2*FF)) < 0.001 && num_fail > WINDOW*0.8     % sensor value no change
        fail_conf = 1;
        fail_type = 1; 
    elseif std(failure_status(2*FF-WINDOW:2*FF)) < 0.3 && num_fail > WINDOW*0.9   % mis-calibration
        fail_conf = 1;
        fail_type = 3;
    end
    
else
    if std(failure_status(2*FF-WINDOW:2*FF)) < 0.001 && num_fail > WINDOW*0.8 % sensor value no change
        fail_type = 1; % stuck-at
    elseif ( std(failure_status(2*FF-WINDOW:2*FF)) < 0.3 || std(failure_status(FF-WINDOW:FF)) < 0.3 ) && num_fail > WINDOW*0.9 % gap no change
        fail_type = 3; % mis-calibration
    elseif std(failure_status(2*FF-WINDOW:2*FF)) > 0.5 && num_fail >= WINDOW*0.4
        fail_type = 2; % high-noise
    end
        
    mean_dev = mean( failure_status(1:FF) );
    
    if mean_dev < threshold
        fail_conf = 0;
    else
        fail_conf = normcdf(mean_dev-threshold, 0, adapt_err)*2-1;
    end
end

output_info = [fail_conf, fail_type, failure_status];
