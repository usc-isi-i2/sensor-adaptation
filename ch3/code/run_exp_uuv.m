clear;
% loading processed data
load('../../datasets/UUV/processed_UUV/UUV_data.mat');

% reconstrucing surge, heave and sway
sensor_set = [8,9,10];

bias = 2.0;

for idx_test = 1:10
    
    data_test = uuv_data{idx_test}';
    
    data_train = [];
    for j = 1:10
        if j ~= idx_test
            data_train = [data_train, uuv_data{j}'];
        end
    end
    
    %% individual sensor failures
    for i = 1:length(sensor_set)
        
        idx_sensor = sensor_set(i);
        
        ref_sensor = [data_train([1:idx_sensor-1,idx_sensor+1:end],:), data_test([1:idx_sensor-1,idx_sensor+1:end], :)];
        rep_sensor = data_train(idx_sensor,:);
        
        
        ground_truth = data_test(idx_sensor,:);
        new_sensor = ground_truth - bias;

        
        % Replace
        err_replace{i, idx_test} = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        % Ref-Neu
        err_refneu{i, idx_test} = adapt_refneu(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        % Ref-FFX
        err_refffx{i, idx_test} = adapt_refffx(ref_sensor, rep_sensor, new_sensor, ground_truth);
    end
    
    %% compuond sensor failures
    ref_sensor = [data_train([1:7,11:12],:), data_test([1:7,11:12], :)];
    rep_sensor = data_train(sensor_set,:);
    
    ground_truth = data_test(sensor_set,:);
    new_sensor = ground_truth - bias;
    
    % Replace
    tmp_res = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth);
    
    for i = 1:length(sensor_set)
        err_replace_cmp{i, idx_test} = tmp_res(i);
    end
    
    % Ref-Neu
    tmp_res = adapt_refneu(ref_sensor, rep_sensor, new_sensor, ground_truth);
    
    for i = 1:length(sensor_set)
        err_refneu_cmp{i, idx_test} = tmp_res(i);
    end
    
    
    % Ref-FFX
    tmp_res = adapt_refffx(ref_sensor, rep_sensor, new_sensor, ground_truth);
   
    for i = 1:length(sensor_set)
        err_refffx_cmp{i, idx_test} = tmp_res(i);
    end
end

fprintf('Individual sensor failures\n');
gen_results(err_replace, err_refneu, err_refffx, 'ind_uuv');

fprintf('\nCompound sensor failures\n');
gen_results(err_replace_cmp, err_refneu_cmp, err_refffx_cmp, 'cmp_uuv');