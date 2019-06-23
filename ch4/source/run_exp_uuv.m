% loading processed data
clear;

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
        
        % Refer
        err_refer{i, idx_test} = adapt_refer(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
        % ReferZ
        err_referZ{i, idx_test} = adapt_referZ(ref_sensor, rep_sensor, new_sensor, ground_truth);
        
         % ASC
        err_asc{i, idx_test} = adapt_asc(ref_sensor, rep_sensor, new_sensor, ground_truth);
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
    
    % Refer
    tmp_res = adapt_refer(ref_sensor, rep_sensor, new_sensor, ground_truth);
    
    for i = 1:length(sensor_set)
        err_refer_cmp{i, idx_test} = tmp_res(i);
    end
    
    
    % ReferZ
    tmp_res = adapt_referZ(ref_sensor, rep_sensor, new_sensor, ground_truth);
   
    for i = 1:length(sensor_set)
        err_referZ_cmp{i, idx_test} = tmp_res(i);
    end
    
    % ReferZ
    tmp_res = adapt_asc(ref_sensor, rep_sensor, new_sensor, ground_truth);
   
    for i = 1:length(sensor_set)
        err_asc_cmp{i, idx_test} = tmp_res(i);
    end
end


fprintf('Individual sensor changes\n');
gen_results(err_replace, err_refer, err_referZ, err_asc, 'ind_uuv');

fprintf('\nCompound sensor changes\n');
gen_results(err_replace_cmp, err_refer_cmp, err_referZ_cmp, err_asc_cmp, 'cmp_uuv');