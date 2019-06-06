function DA_exp

rand('seed',2016);
load('aligned_data');

hist_month = [1,2,3,4,5,7];
overlap_month = [9]; 
test_month = [10,11];

Z = [];
X1 = [];
X2 = [];

sel_id = [1,3,5,6,8];

SEL_NUM = 3000;

for i = overlap_month
    Z = [Z, data1{i}(sel_id,1:SEL_NUM)];
    X1 = [X1, data2{i}(sel_id,1:SEL_NUM)];
    X2 = [X2, data3{i}(sel_id,1:SEL_NUM)];
end

Xh1 = [];
Xh2 = [];
for i = hist_month
    num = size( data2{i}, 2);
    rdp = randperm(num);
    sel_idx = rdp(1:2000);
    
    Xh1 = [Xh1, data2{i}(sel_id,sel_idx)];
    Xh2 = [Xh2, data3{i}(sel_id,sel_idx)];
end

Z_test = [];
for i = test_month
    Z_test = [Z_test, data1{i}(sel_id,:)];
end

%% scaling
max_val = max(Xh1,[],2);
min_val = min(Xh2,[],2);

range = max_val - min_val;

Z = ( Z - repmat( min_val, 1, size(Z,2) ) )./ repmat( max_val-min_val, 1, size(Z,2) );
X1 = ( X1 - repmat( min_val, 1, size(X1,2) ) )./ repmat( max_val-min_val, 1, size(X1,2) );
X2 = ( X2 - repmat( min_val, 1, size(X2,2) ) )./ repmat( max_val-min_val, 1, size(X2,2) );
Xh1 = ( Xh1 - repmat( min_val, 1, size(Xh1,2) ) )./ repmat( max_val-min_val, 1, size(Xh1,2) );
Xh2 = ( Xh2 - repmat( min_val, 1, size(Xh2,2) ) )./ repmat( max_val-min_val, 1, size(Xh2,2) );
Z_test = ( Z_test - repmat( min_val, 1, size(Z_test,2) ) )./ repmat( max_val-min_val, 1, size(Z_test,2) );

X1 = get_squre_fea(X1);
Xh1 = get_squre_fea(Xh1);
X2 = get_squre_fea(X2);
Xh2 = get_squre_fea(Xh2);

lambda = 0.1;
[W1, W2] = DA_two_domains(Z, X1, X2, Xh1, Xh2, lambda);

p1 = W1*Xh1;
p2 = W2*Xh2;
Z_ext = Z;

diff = sum( (p1 - p2).^2 );
id = find(diff < 0.002);
p_avg = (p1+p2)/2;
Z_ext = [Z_ext, p_avg(:,id)];

dim = 5;
for MISS_ID = 1:5
    train_data = Z([1:MISS_ID-1,MISS_ID+1:dim],:);
    train_label = Z(MISS_ID,:);
    
    test_data = Z_test([1:MISS_ID-1,MISS_ID+1:dim],:);
    test_label = Z_test(MISS_ID,:);
    
    prediction = kernel_ridge_reg(train_data, train_label, test_data, 2, 1e-3); 
    err(MISS_ID) = mean( abs( test_label - prediction ) ) * range(1);
end


for MISS_ID = 1:5
    train_data = Z_ext([1:MISS_ID-1,MISS_ID+1:dim],:);
    train_label = Z_ext(MISS_ID,:);
    
    test_data = Z_test([1:MISS_ID-1,MISS_ID+1:dim],:);
    test_label = Z_test(MISS_ID,:);
    
    prediction = kernel_ridge_reg(train_data, train_label, test_data, 2, 1e-3); 
    err_ext(MISS_ID) = mean( abs( test_label - prediction ) ) * range(1);
end

err
err_ext