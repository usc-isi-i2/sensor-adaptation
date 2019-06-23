function infometric_semi(source, target, low_dim, part)


addpath('/share/software/libs/libsvm/matlab');
addpath('libknn');

sta = tic;

T = 20;

accu_metric_semi_NN = zeros(1,T);
record_lamdab = zeros(1,T);

metric_cell = cell(1,T);

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
    lX = lX'; vaX = vaX'; teX = teX';
    lY = lY'; vaY = vaY'; teY = teY';
    
    if low_dim == 0
        low_dim = 800;
    end
    
    % target PCA
    if low_dim < 800
        P_target = myPCA([vaX; teX], low_dim);
        lX = lX * P_target';
        vaX = vaX * P_target';
        teX = teX * P_target';
    end
    
    MAXITER = 200;
    
    best_lambda = 0;
    best_accu = 0;
    
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
                    
            M = eye(low_dim);
            M = M/trace(M);
            
            source_X = [lX; vaX(v_sel_train,:)];
            source_Y = [lY; vaY(v_sel_train,:)];
            target_X = [vaX(v_sel_test,:); teX];
            target_Y = [vaY(v_sel_test,:); teY];
            

            mu = 0.002;
            
            [pre_f,g] = loss_info_metric(M, source_X, source_Y, target_X, lambda);
            for iter = 1:MAXITER
                iter
                
                dM = reshape(g, low_dim, low_dim);
                M = M - mu * dM;
                M = (M+M')/2;
                    
                    M = real(M);

                    if isnan(M)
                        keyboard;
                    end
                
                [Evecs,Evals] = eig(M);
                Evals = max(Evals, 0);
                M = Evecs * Evals * Evecs';
                M = M / trace(M);
                
                [f,g] = loss_info_metric(M, source_X, source_Y, target_X, lambda);
                
                if f < pre_f
                    mu = mu * 1.01;
                    
                    if mu > 1
                        mu = 1;
                    end
                else
                    mu = mu * 0.5;
                end
                
                pre_f = f;
                
                if mu < 1e-5
                    break;
                end
            end
            
            [U,S,V] = svd(M);
            L = U*sqrt(S)*U';
            
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
    
    M = eye(low_dim);
    M = M/trace(M);
    
    mu = 0.005;
    [pre_f,g] = loss_info_metric(M, [lX; vaX], [lY; vaY], teX, best_lambda);
    
    for iter = 1:MAXITER
        iter
        

        dM = reshape(g, low_dim, low_dim);
        M = M - mu * dM;
        M = (M+M')/2;
        
        [Evecs,Evals] = eig(M);
        Evals = max(Evals, 0);
        M = Evecs * Evals * Evecs';
        M = M / trace(M);
        
        [f,g] = loss_info_metric(M, [lX; vaX], [lY; vaY], teX, best_lambda);
        
        if f < pre_f
            mu = mu * 1.01;
            
            if mu > 1
                mu = 1;
            end
        else
            mu = mu * 0.5;
        end
        
        pre_f = f;
        
        if mu < 1e-5
            break;
        end
    end
    
    metric_cell{tt} = M;

    [U,S,V] = svd(M);
    L = U*sqrt(S)*U';

    accu_metric_semi_NN(tt) = fastknn(L, [lX; vaX], [lY; vaY], teX, teY, 1);
end

dur = toc(sta);

fname = ['result_infometric/', source, '_', target, '_D_', num2str(low_dim), '_P_', num2str(part), '_infometric_semi.mat'];
save(fname, 'accu_metric_semi_NN', 'metric_cell', 'record_lamdab', 'dur');