function detect_changes_NN(input_data, col_id, row_id)

% col_id is the target sensor
% 1:row_id-1 is the training period

BAD_VALUE = -99;

data = input_data(:,1:end-1);
label = input_data(row_id:end,end);


%% build a model on the training period
train_idx = 1:row_id-1;
train_x = data(train_idx, col_id);

% remove bad rows on the target sensor
rmv_idx = find( train_x < BAD_VALUE );
train_x(rmv_idx) = [];

test_x = data( row_id:end, col_id);

% remove bad rows on the target sensor on the testing data
rmv_idx2 = find( test_x < BAD_VALUE );
test_x(rmv_idx2) = [];
label(rmv_idx2) = [];

%% nearest neighbor with length T
T = 5;
N_train = size(train_x,1);
train_X = zeros( N_train-T+1, T );
for t = 1:T
    train_X(:,t) = train_x(t:N_train-T+t);
end

rdp = randperm( size(train_X,1) );
train_X = train_X( rdp(1:1000), :);

tmp = [];
for t = 1:T-1
    tmp = [tmp; test_x(1)]; 
end
test_x0 = [tmp; test_x];

N_test = size(test_x,1);
N_test0 = size(test_x0,1);
test_X = zeros( N_test0-T+1, T );
for t = 1:T
    test_X(:,t) = test_x0(t:N_test0-T+t);
end

BLOCK = 1000;
N_BLOCK = floor(N_test / BLOCK);
NN_dist = [];
for i = 1:N_BLOCK+1
    if i <= N_BLOCK
        block_idx = BLOCK*(i-1)+1:BLOCK*i;
    else
        block_idx = BLOCK*(i-1)+1:N_test;
    end
    dist = L2_distance(test_X(block_idx,:)', train_X');
    dist = sort(dist,2);
    
    NN_dist = [NN_dist;sum(dist(:,1:3),2)];
end

prec_recall_list_NN(NN_dist, label);