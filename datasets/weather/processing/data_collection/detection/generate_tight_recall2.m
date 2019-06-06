function generate_tight_recall2

load('3var_sub.mat');

train_data = data(:,1:2000);
test_data = data(:,2001:10000);

reconst = kernel_ridge_reg(train_data(2:3,:), train_data(1,:), test_data(2:3,:), 2, 1e-3);
ground_truth = test_data(1,:);

abs_diff = abs( reconst - ground_truth);

bound_train = abs_diff + 1.5*rand(1, length(abs_diff)) *mean(abs_diff);


gg = 0;
N_test = length(abs_diff);

for scale = 0:0.05:2
    
    bound = scale * bound_train;
    
    recall = 0;
    tight = 0;
    
    for i = 1:N_test
        if bound(i) >= abs_diff(i)  % correct
            recall = recall + 1;
            
            tight = tight + ( bound(i)-abs_diff(i) );
        end
    end
    
    if recall > 0
        gg = gg + 1;
        tight_list(gg) = tight / recall;
        recall_list(gg) = recall / N_test;
    end
end

keyboard