function infometricL(source, target, low_dim, lambda)


addpath('/share/software/libs/libsvm/matlab');
addpath('libknn');

sta = tic;

T = 20;

accu_NN = zeros(1,T);
accu_semi_NN = zeros(1,T);
accu_metric = zeros(1,T);
accu_metric_semi_NN = zeros(1,T);

P_cell = cell(1,T);

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
    lX = lX'*0.1; vaX = vaX'*0.1; teX = teX'*0.1;
    lY = lY'; vaY = vaY'; teY = teY';
    
    if low_dim == 0
        low_dim = 800;
    end
    
    % target PCA
    P_target = myPCA([vaX; teX], low_dim);

    accu_NN(tt) = fastknn(P_target, lX, lY, teX, teY, 1);
    accu_semi_NN(tt) = fastknn(P_target, [lX;vaX], [lY;vaY], teX, teY, 1);
    
    MAXITER = 300;
    
    fhandler = @(L)loss_info_metricL(L, lX, lY, [vaX;teX], lambda);

    L = P_target';      % D*low_dim
    
    [L E_try] = gdStiefel(fhandler, L, 1e-4, MAXITER);

    L = L'; 
    
    L_cell{tt} = L;
    
    accu_metric_NN(tt) = fastknn(L, lX, lY, teX, teY, 1);
    accu_metric_semi_NN(tt) = fastknn(L, [lX; vaX], [lY; vaY], teX, teY, 1);
end

dur = toc(sta);

fname = ['result_infometricL/', source, '_', target, '_D_', num2str(low_dim), '_L_', num2str(lambda), '_infometricL.mat'];
save(fname, 'accu_NN', 'accu_semi_NN', 'accu_metric', 'accu_metric_semi_NN', 'L_cell', 'dur');