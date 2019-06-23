function const = learn_constraints(data, input_idx, target_idx)

% input_idx: input sensors
% target_idx: target sensors

const = cell(1,4);
const{1} = target_idx;
const{2} = input_idx;

y = data(const{1},:);
X = data(const{2},:);

d = 2;
lambda = 0.001;

[weight, min_val, max_val] = train_ridge_reg(X, y, d, lambda);
pred = test_ridge_reg(X, weight, min_val, max_val, d);
err = abs(pred-y);
err = sort(err);

const{3} = weight;                  % weight vector
const{4} = [min_val, max_val];
const{5} = err( floor(length(y))*0.98 );