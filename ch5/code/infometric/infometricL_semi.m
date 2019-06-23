function infometricL_semi(source, target, low_dim, part)


addpath('/share/software/libs/libsvm/matlab');
addpath('libknn');

sta = tic;

T = 20;

accu_NN = zeros(1,T);
accu_semi_NN = zeros(1,T);
accu_metric = zeros(1,T);
accu_metric_semi_NN = zeros(1,T);
record_lamdab = zeros(1,T);

P_cell = cell(1,T);

if part == 0
    split = 1:T;
else
    split = 5*(part-1)+1:5*part;
end

for tt = split
    
    if strcmp(source, 'amazon') == 1
        source_idx = ['amazon_webcam_ICCV_run', num2str(tt), '.mat'];
          lambda_set = [1, 0.25, 4];
    elseif strcmp(source, 'dslr') == 1
        source_idx = ['dslr_webcam_ICCV_run', num2str(tt), '.mat'];
          lambda_set = [1, 4, 8];
    else
        source_idx = ['webcam_dslr_ICCV_run', num2str(tt), '.mat'];
          lambda_set = [1, 4, 8];
    end
    
    target_valid_idx = [target, '_validation3_ICCV_run', num2str(tt), '.mat'];
    
    fname = ['dataset/', source, '.mat'];
    load(fname);
    
    fname = ['ExpSetting/', source_idx];
    load(fname);
    
    fts = fts ./ repmat( sum(fts,2), 1, size(fts,2) );
    fts = zscore(fts);
    lX = fts(trIDX,:)';
    lY = labels(trIDX,:)';
    
    fname = ['dataset/', target, '.mat'];
    load(fname);
    
    fname = ['ExpSetting/', target_valid_idx];
    load(fname);
    
    fts = fts ./ repmat( sum(fts,2), 1, size(fts,2) );
    fts = zscore(fts);
    vaX = fts(vaIDX,:)';
    vaY = labels(vaIDX,:)';
    
    teX = fts(teIDX,:)';
    teY = labels(teIDX,:)';
    
    %convert to n*d form
    lX = lX'*0.1; vaX = vaX'*0.1; teX = teX'*0.1;
    lY = lY'; vaY = vaY'; teY = teY';
    
    if low_dim == 0
        low_dim = 800;
    end
    
    % target PCA
    P_target = myPCA([vaX; teX], low_dim);
    
    MAXITER = 200;
    
    best_accu = 0;
    best_lambda = 0;

    for lambda = lambda_set
       
        accu = 0;
        for valid_idx = 1:3
            
            v_sel_test = [0:30]*3+valid_idx;
            
            v_sel_train = [];
            for kk = 1:3
                if kk ~= valid_idx
                    v_sel_train = [v_sel_train, [0:30]*3+kk];
                end
            end
            
            source_X = [lX; vaX(v_sel_train,:)];
            source_Y = [lY; vaY(v_sel_train,:)];
            target_X = [vaX(v_sel_test,:); teX];
            target_Y = [vaY(v_sel_test,:); teY];
            
            fhandler = @(L)loss_info_metricL(L, source_X, source_Y, target_X, lambda);
            
            L = P_target';      % D*low_dim
            
            [L E_try] = gdStiefel(fhandler, L, 1e-4, MAXITER);
            
            L = L';
            
            accu = accu + fastknn(L, source_X, source_Y, vaX(v_sel_test,:), vaY(v_sel_test,:), 1);
        end
        
        accu = accu/3;
        
        if accu > best_accu
            best_accu = accu;
            best_lambda = lambda;
        end
    end
    
    MAXITER = 300;

    record_lamdab(tt) = best_lambda;
    
    fhandler = @(L)loss_info_metricL(L, [lX;vaX], [lY;vaY], teX, best_lambda);
    L = P_target';
    [L E_try] = gdStiefel(fhandler, L, 1e-4, MAXITER);
    L = L';
    
    L_cell{tt} = L;
    
    accu_metric_semi_NN(tt) = fastknn(L, [lX; vaX], [lY; vaY], teX, teY, 1);
end

dur = toc(sta);

fname = ['result_infometricL/', source, '_', target, '_D_', num2str(low_dim), '_P_', num2str(part), '_infometricL_semi.mat'];
save(fname,'accu_metric_semi_NN', 'L_cell', 'record_lamdab', 'dur');