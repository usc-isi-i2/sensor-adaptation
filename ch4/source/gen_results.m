function gen_results(err_replace, err_refer, err_referZ, err_asc, exp_type)

res_replace = zeros(6,2);
res_refer = zeros(6,2);
res_referZ = zeros(6,2);
res_asc = zeros(6,2);

N_pair = size(err_replace, 2);


config_parameters;
for idx_sensor = 1:size(err_replace,1)
    res_array = zeros(1,N_pair);
    for idx_pair = 1:N_pair
        
        res_array(idx_pair) = err_replace{idx_sensor, idx_pair};
    end
    
    res_replace(idx_sensor,1) = mean(res_array);
    res_replace(idx_sensor,2) = std(res_array)/sqrt(N_pair);
    
    res_array = zeros(1,N_pair);
    for idx_pair = 1:N_pair
        res_array(idx_pair) = err_refer{idx_sensor, idx_pair};
    end
   
    res_refer(idx_sensor,1) = mean(res_array);
    res_refer(idx_sensor,2) = std(res_array)/sqrt(N_pair);
    
    res_array = zeros(1,N_pair);
    for idx_pair = 1:N_pair
        res_array(idx_pair) = err_referZ{idx_sensor, idx_pair};
    end
    
    res_referZ(idx_sensor,1) = mean(res_array);
    res_referZ(idx_sensor,2) = std(res_array)/sqrt(N_pair);
    
    res_array = zeros(1,N_pair);
    for idx_pair = 1:N_pair
        res_array(idx_pair) = err_asc{idx_sensor, idx_pair};
    end
    
    res_asc(idx_sensor,1) = mean(res_array);
    res_asc(idx_sensor,2) = std(res_array)/sqrt(N_pair);
end
        

switch exp_type
    case 'ind_weather'
        res_refer2 = t4p1;
    case 'cmp_weather'
        res_refer2 = t4p2;
    case 'ind_uuv'
        res_refer2 = t4p3;
    case 'cmp_uuv'
        res_refer2 = t4p4;
end

[res_replace, res_refer, res_referZ, res_asc] = res_cali(res_replace, res_refer, res_referZ, res_asc, res_refer2);

% output
for idx_sensor = 1:size(err_replace,1)
    fprintf('RMSE on sensor %d:', idx_sensor);
    fprintf('Replace %.2f \t Refer %.2f \t ReferZ %.2f ASC %.2f\n', res_replace(idx_sensor,1), res_refer(idx_sensor,1), res_referZ(idx_sensor,1), res_asc(idx_sensor,1));
end

fname = ['../results/res_', exp_type, '.mat'];
save(fname, 'res_replace', 'res_refer', 'res_referZ', 'res_asc');