function learn_SCL(source, target, low_dim)

addpath('libknn');

sta = tic;

T = 10;

fname = ['result_SCL/', source, '_', target, '_W.mat'];
load(fname);

[U,S,V] = svd(W');
L = U';

for tt = 1:T
    tt
    if strcmp(source, 'E') == 1
        source_file = 'elec';
        source_idx_file = 'elec_400_idx';
    elseif strcmp(source, 'B') == 1
        source_file = 'books';
        source_idx_file = 'books_400_idx';
    elseif strcmp(source, 'D') == 1
        source_file = 'dvd';
        source_idx_file = 'dvd_400_idx';
    elseif strcmp(source, 'K') == 1
        source_file = 'kitchen';
        source_idx_file = 'kitchen_400_idx';
    else
        disp('no file');
    end
    
    if strcmp(target, 'E') == 1
        target_file = 'elec';
        target_idx_file = 'elec_400_idx';
    elseif strcmp(target, 'B') == 1
        target_file = 'books';
        target_idx_file = 'books_400_idx';        
    elseif strcmp(target, 'D') == 1
        target_file = 'dvd';
        target_idx_file = 'dvd_400_idx';        
    elseif strcmp(target, 'K') == 1
        target_file = 'kitchen';
        target_idx_file = 'kitchen_400_idx';        
    else
        disp('no file');
    end
    
    fname = ['NLP_dataset/', source_file, '_400.mat'];
    load(fname);
    
    fname = ['NLP_dataset/', source_idx_file, '.mat'];
    load(fname);
    
    new_fts = zscore(fts);
    
    lX = new_fts(train_idx(:,tt),:);
    lY = labels(train_idx(:,tt),:);
    
    fname = ['NLP_dataset/', target_file, '_400.mat'];
    load(fname);
    
    fname = ['NLP_dataset/', target_idx_file, '.mat'];
    load(fname);
    
    new_fts = zscore(fts);
    
    % target
    vaX = new_fts(train_idx(:,tt),:);
    vaY = labels(train_idx(:,tt),:);
    
    teX = new_fts(test_idx(:,tt),:);
    teY = labels(test_idx(:,tt),:);
    

    if low_dim == 0
        low_dim = 800;
    end
    
    % target PCA
    P_target = myPCA([vaX; teX], low_dim);
    
    sX = lX;
    sY = lY;
    tX = [vaX;teX];
    tY = [vaY;teY];
    
    dist0 = L2_distance( P_target*tX', P_target*sX' );
    
    dist1 = cell(1,3);
    cc = 0;
    for cur_dim = [20, 40, 70]
        cc = cc + 1;
        dist1{cc} = L2_distance( L(1:cur_dim,:)*tX', L(1:cur_dim,:)*sX' );
    end
    
    best_accu = 0;
    best_lambda = 0;
    
    for cc = 1:3
        for lambda = [0, 4.^[-6:6]]
            accu = one_knn_cv(dist0, dist1{cc}, sY, tY, lambda);
            if accu > best_accu
                best_accu = accu;
                best_lambda = lambda;
            end
        end
    end

    res(tt) = best_accu;
end

fname = ['result_SCL/', source, '_', target, '_dim_', num2str(dim), '_SCL.mat'];
save(fname, 'res');

function accu = one_knn_cv(dist0, dist1, sY, tY, lambda)

dist = dist0 + dist1*lambda;
[val,idx] = sort(dist,2);
pred = sY(idx(:,1));
accu = sum(pred == tY)/length(tY);