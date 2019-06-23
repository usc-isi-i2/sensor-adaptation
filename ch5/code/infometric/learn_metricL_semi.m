function learn_metricL_semi(source, target, low_dim, type)

sta = tic;

T = 20;

L_cell = cell(1,T);

for tt = 1:T
    if strcmp(source, 'C') == 1
        source_idx = ['Caltech10_Kate_ICCV_run', num2str(tt), '.mat'];
    elseif strcmp(source, 'A') == 1
        source_idx = ['amazon_Caltech10_ICCV_run', num2str(tt), '.mat'];
    elseif strcmp(source, 'W') == 1
        source_idx = ['webcam_Caltech10_ICCV_run', num2str(tt), '.mat'];
    else   % DSLR
        source_idx = ['dslr_Caltech10_ICCV_run', num2str(tt), '.mat'];
    end
    
    if strcmp(target, 'C') == 1
        target_valid_idx = ['Caltech10_validation3_ICCV_run', num2str(tt), '.mat'];
    elseif strcmp(target, 'A') == 1
        target_valid_idx = ['amazon_validation3_Caltech10_ICCV_run', num2str(tt), '.mat'];
    elseif strcmp(target, 'W') == 1
        target_valid_idx = ['webcam_validation3_Caltech10_ICCV_run', num2str(tt), '.mat'];
    else   % DSLR
        target_valid_idx = ['dslr_validation3_Caltech10_ICCV_run', num2str(tt), '.mat'];
    end
    
    if strcmp(source, 'C') == 1
        source_file = 'Caltech10_SURF_L10';
    elseif strcmp(source, 'A') == 1
        source_file = 'amazon_SURF_L10';
    elseif strcmp(source, 'W') == 1
        source_file = 'webcam_SURF_L10';
    else   % DSLR
        source_file = 'dslr_SURF_L10';
    end
    
    if strcmp(target, 'C') == 1
        target_file = 'Caltech10_SURF_L10';
    elseif strcmp(target, 'A') == 1
        target_file = 'amazon_SURF_L10';
    elseif strcmp(target, 'W') == 1
        target_file = 'webcam_SURF_L10';
    else   % DSLR
        target_file = 'dslr_SURF_L10';
    end
    
    fname = ['dataset/', source_file, '.mat'];
    load(fname);
    
    fname = ['ExpSetting/', source_idx];
    load(fname);
    
    fts = fts ./ repmat( sum(fts,2), 1, size(fts,2) );
    fts = zscore(fts);
    lX = fts(trIDX,:)';
    lY = labels(trIDX,:)';
    
    fname = ['dataset/', target_file, '.mat'];
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
    
    best_lambda = 0;
    best_accu = 0;

    lambda_set = [0, 0.25, 1, 4];
    
    for lambda = lambda_set
        
        MAXITER = 250;
        
        M = eye(low_dim);
        M = M/trace(M);
    
        accu = 0;
        for valid_idx = 1:3
            
            v_sel_test = [0:9]*3+valid_idx;
            
            v_sel_train = [];
            for kk = 1:3
                if kk ~= valid_idx
                    v_sel_train = [v_sel_train, [0:9]*3+kk];
                end
            end
            
            source_X = [lX; vaX(v_sel_train,:)];
            source_Y = [lY; vaY(v_sel_train,:)];
            target_X = [vaX(v_sel_test,:); teX];
            target_Y = [vaY(v_sel_test,:); teY];
            
            if type == 1
                fhandler = @(L)loss_info_metricL(L, source_X, source_Y, target_X, lambda);
            else
                fhandler = @(L)loss_info_metricL_v2(L, source_X, source_Y, target_X, lambda);
            end
            
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
    
    if type == 1
        fhandler = @(L)loss_info_metricL(L, [lX;vaX], [lY;vaY], teX, best_lambda);
    else
        fhandler = @(L)loss_info_metricL_v2(L, [lX;vaX], [lY;vaY], teX, best_lambda);
    end
    
    L = P_target';      % D*low_dim
    
    [L E_try] = gdStiefel(fhandler, L, 1e-4, MAXITER);
    
    L = L';
    L_cell{tt} = L;
end

dur = toc(sta);

if type == 1
    fname = ['result1_semi/', source, '_', target, '_dim_', num2str(low_dim), '_reg_', num2str(lambda), '_type_', num2str(type), '_L.mat'];
else
    fname = ['result2_semi/', source, '_', target, '_dim_', num2str(low_dim), '_reg_', num2str(lambda), '_type_', num2str(type), '_L.mat'];
end

save(fname, 'L_cell', 'record_lamdab', 'dur');