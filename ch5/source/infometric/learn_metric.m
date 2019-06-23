function learn_metric(source, target, low_dim, lambda, type)

sta = tic;

T = 20;

metric_cell = cell(1,T);

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
    lX = lX'; vaX = vaX'; teX = teX';
    lY = lY'; vaY = vaY'; teY = teY';
    
    if low_dim == 0
        low_dim = 800;
    end
    
    % target PCA
    if low_dim <= 800
        P_target = myPCA([vaX; teX], low_dim);
        lX = lX * P_target';
        vaX = vaX * P_target';
        teX = teX * P_target';
    end
    
    MAXITER = 300;
    
    M = eye(low_dim);
    M = M/trace(M);
    
    mu = 0.005;
    
    f_record = [];
    
    if type == 1
        [pre_f,g] = loss_info_metric(M, lX, lY, teX, lambda);
    else
        [pre_f,g] = loss_info_metric_v2(M, lX, lY, teX, lambda);
    end
    
    for iter = 1:MAXITER    
        iter

        dM = reshape(g, low_dim, low_dim);
        M = M - mu * dM;
        M = (M+M')/2;
        
        [Evecs,Evals] = eig(M);
        Evals = max(Evals, 0);
        M = Evecs * Evals * Evecs';
        M = M / trace(M);
        
        if type == 1
            [f,g] = loss_info_metric(M, lX, lY, teX, lambda);
        else
            [f,g] = loss_info_metric_v2(M, lX, lY, teX, lambda);
        end
        
        if f < pre_f
            mu = mu * 1.01;
            
            if mu > 1
                mu = 1;
            end
        else
            mu = mu * 0.5;
        end
        
        pre_f = f;
        
        f_record = [f_record, pre_f];
        
        if mu < 1e-5
            break;
        end
    end
    
    metric_cell{tt} = M;
end

dur = toc(sta);

if type == 1
    fname = ['result1/', source, '_', target, '_dim_', num2str(low_dim), '_reg_', num2str(lambda), '_type_', num2str(type), '_M.mat'];
else
    fname = ['result2/', source, '_', target, '_dim_', num2str(low_dim), '_reg_', num2str(lambda), '_type_', num2str(type), '_M.mat'];
end

save(fname, 'metric_cell', 'dur');