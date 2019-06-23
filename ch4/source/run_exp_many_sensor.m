clear;
% loading processed data
load('../../datasets/weather/dataset/processed_weather/weather_data.mat');

N_pair = 30;
for idx_pair = 1:N_pair
    idx_A = randi(10);
    
    data_A = station_data{idx_A, 1};
    
    data_B = [];
    for j = [1:idx_A-1, idx_A+1:10]
        data_B = [data_B; station_data{j, 1}; station_data{j, 2}];
    end
    
    train_idx = 1:3000;
    test_idx = 5001:8000;
    
    %% individual sensor failures
    for idx_sensor = 1:6
        ref_sensor = [data_A([1:idx_sensor-1,idx_sensor+1:end], [train_idx,test_idx]); ...
            data_B([1:idx_sensor-1,idx_sensor+1:end], [train_idx,test_idx])];
        rep_sensor = data_A(idx_sensor, train_idx);
        new_sensor = data_B(idx_sensor, test_idx);
        ground_truth = data_A(idx_sensor, test_idx);
        
        err_asc{idx_sensor, idx_pair} = adapt_asc(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        err_asc_sel{idx_sensor, idx_pair} = adapt_asc_sel(ref_sensor, rep_sensor, new_sensor, ground_truth);
    end
end

fprintf('Dealing with many sensors...\n');

for idx_sensor = 1:6
    for idx_pair = 1:N_pair
        res_asc(idx_pair) = err_asc{idx_sensor, idx_pair};
        res_asc_sel(idx_pair) = err_asc_sel{idx_sensor, idx_pair};
    end
    fprintf('Sensor %g\t ASC: %.2f\t ASC-SEL: %.2f\n', idx_sensor, mean(res_asc), mean(res_asc_sel));
end