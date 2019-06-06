load('sub_data_wsp.mat');

N_TRAIN = 3279;

train_data = sub_data(1:N_TRAIN,2);
train_label = sub_data(1:N_TRAIN,1);

PP = [train_data,train_label];
PP = sum(PP,2);
idx = find(PP < -5);

train_data(idx,:) = [];
train_label(idx) = [];

test_data = sub_data(N_TRAIN+1:end,2);
test_label = sub_data(N_TRAIN+1:end,1);

ground_truth = label(N_TRAIN+1:end);

PP = [test_data,test_label];
PP = sum(PP,2);
idx = find(PP < -5);
test_data(idx,:) = [];
test_label(idx,:) = [];

ground_truth(idx) = [];

pred = kernel_ridge_reg(train_data', train_label', test_data', 2, 1e-3);
pred = pred';

detect_label = zeros(length(pred),1);

threshold = 0.2;
for i = 1:length(pred)
    if abs( pred(i) - test_label(i) ) / abs( test_label(i) ) > threshold
        detect_label(i) = 1;
    end
end

% precision recall
tp = 0;
fp = 0;
tn = 0;
fn = 0;

for i = 1:length(pred)
   if  ground_truth(i) == 1 && detect_label(i) == 1
       tp = tp + 1;
   elseif ground_truth(i) == 0 && detect_label(i) == 0
       tn = tn + 1;
   elseif ground_truth(i) == 1 && detect_label(i) == 0
       fn = fn + 1;
   else
       fp = fp +1;
   end
end

precision = tp/(tp+fp)
recall = tp/(tp+fn)