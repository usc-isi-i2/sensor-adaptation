function run_s1_new2

load('3var.mat');

GAP = 15000;
train_idx = 1:GAP;
test_idx = GAP+1:27795;

GAP2 = 27795-GAP;

scale_val = 10;
train_x = data(1, train_idx)/scale_val;
train_y = data(3, train_idx)/scale_val;

test_x = data(1, test_idx)/scale_val;
test_z = data(2, test_idx)/scale_val;
test_y = data(3, test_idx)/scale_val;

% learn a relationship on the training data
Y = train_y(3:GAP-2);
X = [train_y(2:GAP-3);train_y(4:GAP-1)];
X2 = [train_x(1:GAP-4);train_x(2:GAP-3);train_x(3:GAP-2);train_x(4:GAP-1);train_x(5:GAP)];

X3 = [];
for i = 1:size(X2,1)
    for j = 1:size(X2,1)
        X3 = [X3; X2(i,:).*X2(j,:)];
    end
end
X3 = [X; X2; X3; ones(size(Y))];

w = inv(X3*X3'+1e-3*eye(size(X3,1)))*X3*Y';
pred = w'*X3;
err = sqrt( mean( ( Y - pred ).^2 ) ) * scale_val

%% computing X3 on the test data
% w corresponding to theta
X2 = [test_x(1:GAP2-4);test_x(2:GAP2-3);test_x(3:GAP2-2);test_x(4:GAP2-1);test_x(5:GAP2)];
X3 = [];
for i = 1:size(X2,1)
    for j = 1:size(X2,1)
        X3 = [X3; X2(i,:).*X2(j,:)];
    end
end
X3 = [X2; X3; ones(1, size(X2,2))];
label_val = w(3:end)'*X3;

Z3 = sq_feat([test_x(3:GAP2-2);test_z(3:GAP2-2)]);
Z2 = sq_feat([test_x(2:GAP2-3);test_z(2:GAP2-3)]);
Z4 = sq_feat([test_x(4:GAP2-1);test_z(4:GAP2-1)]);


new_X = Z3 - w(1)*Z2 - w(2)*Z4;
new_w = inv(new_X*new_X'+1e-3*eye(size(new_X,1)))*new_X*label_val';

Z = sq_feat([test_x;test_z]);
pred = new_w'*Z;
err = sqrt( mean( ( test_y - pred ).^2 ) ) * scale_val


function A = sq_feat(B)

A = [];
for i = 1:size(B,1)
    for j = 1:size(B,1)
        A = [A; B(i,:).*B(j,:)];
    end
end
A = [A; ones(1, size(B,2))];