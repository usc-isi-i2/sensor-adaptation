function infometric_target(source, target, low_dim, lambda)

% using target domain information
addpath('/share/software/libs/libsvm/matlab');
addpath('libknn');

sta = tic;

T = 20;

accu_NN = zeros(1,T);
accu_metric = zeros(1,T);

for tt = 1:T
    
    if strcmp(source, 'amazon') == 1
        source_idx = ['amazon_webcam_ICCV_run', num2str(tt), '.mat'];
    elseif strcmp(source, 'dslr') == 1
        source_idx = ['dslr_webcam_ICCV_run', num2str(tt), '.mat'];
    else
        source_idx = ['webcam_dslr_ICCV_run', num2str(tt), '.mat'];
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
    
    accu_NN(tt) = fastknn(eye(low_dim), vaX, vaY, teX, teY, 1);
    
    MAXITER = 300;
    
    M = eye(low_dim);
    M = M/trace(M);
    
    mu = 0.005;
    
    f_record = [];
    
    [pre_f,g] = loss_info_metric(M, vaX, vaY, teX, lambda);
    for iter = 1:MAXITER    
        iter

        dM = reshape(g, low_dim, low_dim);
        M = M - mu * dM;
        M = (M+M')/2;
        
        [Evecs,Evals] = eig(M);
        Evals = max(Evals, 0);
        M = Evecs * Evals * Evecs';
        M = M / trace(M);
        
        [f,g] = loss_info_metric(M, vaX, vaY, teX, lambda);
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
    
    [U,S,V] = svd(M);
    L = U*sqrt(S)*U';
    
    accu_metric_NN(tt) = fastknn(L, vaX, vaY, teX, teY, 1);
end

dur = toc(sta);

fname = ['result_infometric_target/', source, '_', target, '_D_', num2str(low_dim), '_L_', num2str(lambda), '_infometric.mat'];
save(fname, 'accu_NN', 'accu_metric_NN','dur');