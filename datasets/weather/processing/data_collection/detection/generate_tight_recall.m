function generate_tight_recall

load('3var_sub.mat');

train_data = data(:,1:2000);
test_data = data(:,2001:10000);

reconst = kernel_ridge_reg(train_data(2:3,:), train_data(1,:), test_data(2:3,:), 2, 1e-3);
ground_truth = test_data(1,:);

% constant bound
abs_diff = abs( reconst - ground_truth);
max_diff = max( abs_diff )*1.5;
gap = max_diff / 500;

gg = 0;
N_test = length(abs_diff);

for bound = 0:gap:max_diff
    
    recall = 0;
    tight = 0;
    
    for i = 1:N_test
        if bound >= abs_diff(i)  % correct
            recall = recall + 1;
            
            tight = tight + ( bound-abs_diff(i) );
        end
    end
    
    if recall > 0
        gg = gg + 1;
        tight_list(gg) = tight / recall;
        recall_list(gg) = recall / N_test;
    end
end

keyboard