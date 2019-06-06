sensor_order = [2,3,7,8,9,10,1,4,5,6,11,12,13];

% vE, vN, vU, surge, heave, sway, altitude, pitch, roll, depth, heading, rpm, waterspeed

M = dlmread('simulator_data_with_pert_forTesting45.txt');

data = M(:,sensor_order);

%% computing reconstruction error
N = size(data,1);
rdp = randperm(N-1)+1;  % starting from 1
train_idx = rdp(1:5000);
test_idx = rdp(5001:10000);

for i = 1:11
    
    if i > 7
        sensor_id = [7:i-1,i+1:13];
    else
        sensor_id = 7:13;
    end
    
    trainX = [data(train_idx, sensor_id), data(train_idx-1, [i,sensor_id])];
    testX = [data(test_idx, sensor_id), data(test_idx-1, [i,sensor_id])];
   
    
    % label
    trainY = data(train_idx, i);
    testY = data(test_idx, i);
    
    pred = poly_ridge_reg(trainX', trainY', testX', 2, 1e-3);
    
    err_ours(i) = sqrt( mean(( testY' - pred).^2 ) );
    
    %% two baselines
    err_mean(i) = sqrt( mean(( testY' - repmat(mean(trainY), 1, length(testY))).^2 ) );
    
    err_prev(i) = sqrt( mean(( testY' - data(test_idx-1,i)' ).^2 ) );
end

keyboard