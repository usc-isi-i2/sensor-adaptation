function [fail_idx, adapt_val] = detection_adapt(const, data)

N_const = length(const);
N_sensor = size(data,1);

cc = 0;
A = zeros(1,N_sensor);

const_set = zeros(N_const, N_sensor);
target_set = zeros(N_const,1);
pred_set = zeros(N_const,1);
err_set = zeros(N_const,1);

for i = 1:N_const
    const_sub = const{i};
    target_idx = const_sub{1};
    input_idx = const_sub{2};
    weight = const_sub{3};
    temp = const_sub{4};
    min_val = temp(:,1);
    max_val = temp(:,2);
    err = const_sub{5};
    
    y = data(target_idx);
    X = data(input_idx);
    
    if size(X,1) == 1
        X = X';
    end
    
    pred = test_ridge_reg(X, weight, min_val, max_val, 2);
    
    const_set(i,[input_idx,target_idx]) = 1;
    target_set(i) = target_idx;
    pred_set(i) = pred;
    err_set(i) = err;
    

    
    % violated
    if abs(pred - y) > err
        violated_idx = zeros(1, N_sensor);
        violated_idx(input_idx) = 1;
        violated_idx(target_idx) = 1;
        
        cc = cc + 1;
        
        A(cc,:) = violated_idx;
    end
end



if cc == 0 
    % no failure
    fail_idx = [];
    adapt_val = data;
else
    adapt_val = data;
    
    % failure, solving Integer Linear Program
    [fail_state,fval,exitflag,output] = intlinprog(ones(N_sensor,1), 1:N_sensor, -A, -ones(size(A,1),1), [], [], zeros(N_sensor,1), ones(N_sensor,1));
    fail_idx = find( fail_state == 1);
    
    % adaptation
    for k = 1:length(fail_idx)
        
        target_idx = fail_idx(k);
        % find all constraints that only with one failed sensor
        copy_const_set = const_set;
        copy_pred_set = pred_set;
        copy_err_set = err_set;
        
        sel_const_idx = find( target_set == target_idx );
        copy_const_set = copy_const_set(sel_const_idx,:);
        copy_pred_set = copy_pred_set(sel_const_idx);
        copy_err_set = copy_err_set(sel_const_idx);
        
        for v = 1:length(fail_idx)
            
            rmv_sensor_idx = fail_idx(v);
            if rmv_sensor_idx ~= target_idx
                rmv_const_idx = find( copy_const_set(:,rmv_sensor_idx) == 1 );
                
                copy_const_set(rmv_const_idx,:) = [];
                copy_pred_set(rmv_const_idx) = [];
                copy_err_set(rmv_const_idx) = [];
            end
        end
        
        
        [best_const_val, best_const_idx] = min(copy_err_set);
      
        adapt_val(target_idx) = copy_pred_set( best_const_idx );
    end
end