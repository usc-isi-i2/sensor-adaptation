sensor_order = [2,3,7,8,9,10,1,4,5,6,11,12,13];

% vE, vN, vU, surge, heave, sway, altitude, pitch, roll, depth, heading, rpm, waterspeed

M1 = dlmread('data1.txt');
M2 = dlmread('data2.txt');
M3 = dlmread('data3.txt');

M = [M1;M2;M3];
data = M(:,sensor_order);

%% computing reconstruction error
N = size(data,1);
rdp = randperm(N-1)+1;  % starting from 1
train_idx = rdp(1:5000);
test_idx = rdp(5001:15000);

for i = 1:11
    
    if i > 7
        sensor_id = [7:i-1,i+1:13];
    else
        sensor_id = 7:13;
    end
    
    trainX = data(train_idx, sensor_id);
    testX = data(test_idx, sensor_id);
   
    
    % label
    trainY = data(train_idx, i);
    testY = data(test_idx, i);
    
    pred = poly_ridge_reg(trainX', trainY', testX', 2, 1e-2);
    
    err_ours(i) = sqrt( mean(( testY' - pred).^2 ) );
    
    %% two baselines
    std_val(i) = std( trainY );
    
    %% average std in 10 seconds
    sub = -ones(1,3000);
    for t = 1:3000
        if train_idx(t) > 600
            sub(t) = std( data( train_idx(t) - 599:train_idx(t),i) );
        end
    end
    std_period(i) = mean(sub(sub>0));
end

keyboard