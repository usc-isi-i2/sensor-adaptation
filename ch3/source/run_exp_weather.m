clear;
% loading processed data
load('../../datasets/weather/dataset/processed_weather/weather_data.mat');

N_pair = 100;
for idx_pair = 1:N_pair
    [idx_A, idx_B] = select_stations(10,3);
    
    data_A = station_data{idx_A.clus, idx_A.sub};
    data_B = station_data{idx_B.clus, idx_B.sub};
    
    train_idx = 1:3000;
    test_idx = 5001:8000;
    
    %% individual sensor failures
    for idx_sensor = 1:6
        ref_sensor = [data_A([1:idx_sensor-1,idx_sensor+1:end], [train_idx,test_idx]); ...
            data_B([1:idx_sensor-1,idx_sensor+1:end], [train_idx,test_idx])];
        rep_sensor = data_A(idx_sensor, train_idx);
        new_sensor = data_B(idx_sensor, test_idx);
        ground_truth = data_A(idx_sensor, test_idx);
        
        
        % Replace
        err_replace{idx_sensor, idx_pair} = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        % Ref-Neu
        err_refneu{idx_sensor, idx_pair} = adapt_refneu(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        % Ref-FFX
        err_refffx{idx_sensor, idx_pair} = adapt_refffx(ref_sensor, rep_sensor, new_sensor, ground_truth);
    end

    %% compuond sensor failures
    ref_sensor = data_B(:, [train_idx,test_idx]);
    rep_sensor = data_A(:, train_idx);
    new_sensor = data_B(:, test_idx);
    ground_truth = data_A(:, test_idx);
    
    
    % Replace
    tmp_res = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth);
    
    for idx_sensor = 1:6
        err_replace_cmp{idx_sensor, idx_pair} = tmp_res(idx_sensor);
    end
    
    % Ref-Neu
    tmp_res = adapt_refneu(ref_sensor, rep_sensor, new_sensor, ground_truth);
    
    for idx_sensor = 1:6
        err_refneu_cmp{idx_sensor, idx_pair} = tmp_res(idx_sensor);
    end
    
    
    % Ref-FFX
    tmp_res = adapt_refffx(ref_sensor, rep_sensor, new_sensor, ground_truth);
   
    for idx_sensor = 1:6
        err_refffx_cmp{idx_sensor, idx_pair} = tmp_res(idx_sensor);
    end
    
end

fprintf('Individual sensor failures\n');
gen_results(err_replace, err_refneu, err_refffx, 'ind_weather');

fprintf('\nCompound sensor failures\n');
gen_results(err_replace_cmp, err_refneu_cmp, err_refffx_cmp, 'cmp_weather');