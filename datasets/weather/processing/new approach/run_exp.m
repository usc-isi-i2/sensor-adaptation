load('3var.mat');

train_idx = 1:15000;
test_idx = 15001:27795;

scale_val = 10;
train_x = data(1:2, train_idx)/scale_val;
train_y = data(3, train_idx)/scale_val;

test_x = data(1:2, test_idx)/scale_val;
test_y = data(3, test_idx)/scale_val;

%test_x = train_x; test_y = train_y;

pred = kernel_ridge_reg(train_x, train_y, test_x, 2, 1e-3);
err = sqrt( mean( ( test_y - pred ).^2 ) ) * scale_val