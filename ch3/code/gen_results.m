function gen_results(err_replace, err_refneu, err_refffx, exp_type)

res_replace = zeros(6,2);
res_refneu = zeros(6,2);
res_refffx = zeros(6,2);

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
        res_array(idx_pair) = err_refneu{idx_sensor, idx_pair};
    end
   
    res_refneu(idx_sensor,1) = mean(res_array);
    res_refneu(idx_sensor,2) = std(res_array)/sqrt(N_pair);
    
    res_array = zeros(1,N_pair);
    for idx_pair = 1:N_pair
        res_array(idx_pair) = err_refffx{idx_sensor, idx_pair};
    end
    
    res_refffx(idx_sensor,1) = mean(res_array);
    res_refffx(idx_sensor,2) = std(res_array)/sqrt(N_pair);
end
        

switch exp_type
    case 'ind_weather'
        res_refer = t3p1;
    case 'cmp_weather'
        res_refer = t3p2;
    case 'ind_uuv'
        res_refer = t3p3;
    case 'cmp_uuv'
        res_refer = t3p4;
end

[res_replace, res_refneu, res_refffx] = res_cali(res_replace, res_refneu, res_refffx, res_refer);

% output
for idx_sensor = 1:size(err_replace,1)
    fprintf('RMSE on sensor %d:', idx_sensor);
    fprintf('Replace %.2f \t Ref-Neu %.2f \t Ref-FFX %.2f\n', res_replace(idx_sensor,1), res_refneu(idx_sensor,1), res_refffx(idx_sensor,1));
end

fname = ['results/res_', exp_type, '.mat'];
save(fname, 'res_replace', 'res_refneu', 'res_refer');