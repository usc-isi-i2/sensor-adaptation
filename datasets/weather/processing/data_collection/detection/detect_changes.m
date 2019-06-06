function detect_changes(input_data, col_id, row_id)

% input_data is a matrix
% col_id is the target sensor
% 1:row_id-1 is the training period

BAD_VALUE = -99;

data = input_data(:,1:end-1);
label = input_data(row_id:end,end);

N_sensor = size(data,2);
N_sample = size(data,1);

%% build a model on the training period
train_idx = 1:row_id-1;

rest_id = [1:col_id-1,col_id+1:N_sensor];

% fixing bad values in other sensors
for j = rest_id
    
    good_idx = find( data(:,j) > BAD_VALUE );
    good_value = mean( data(good_idx,j) );
    
    for i = 1:N_sample
        if data(i,j) < BAD_VALUE
            data(i,j) = good_value;
        else  % a good point
            good_value = data(i,j);
        end
    end
end

train_y = data(train_idx, col_id);
train_x = data(train_idx, rest_id);

% remove bad rows on the target sensor
rmv_idx = find( train_y < BAD_VALUE );
train_y(rmv_idx) = [];
train_x(rmv_idx,:) = [];

test_x = data( row_id:end, rest_id);
test_y = data( row_id:end, col_id);

% remove bad rows on the target sensor on the testing data
rmv_idx2 = find( test_y < BAD_VALUE );
test_x(rmv_idx2,:) = [];
test_y(rmv_idx2) = [];
label(rmv_idx2) = [];

pred = kernel_ridge_reg( train_x', train_y', test_x', 2, 1e-3);
pred = pred';

prec_recall_list_file(pred, test_y, label);
