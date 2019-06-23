function metric_LR_L_ICML(source, target, dim)


% using the metric to transform data
% learn source-LR and Infomax
% apply to target domain

addpath('../minFunc');

T = 20;

sta = tic;

lambda_set = 4.^[0, -5,-4,-3,-2,-1,1,2];
tau_set = 4.^[-2:6];

% record final results
source_cell = cell(1,T);
infomax_cell = cell(1,T);

% record parameter tuning information
record_source_cell = cell(1,T);
record_infomax_cell = cell(1,T);

% if don't cheat
fname = ['/home/yuanshi/ICML12/infometric/result1/', source, '_', target, '_dim_', num2str(dim), '_reg_1_type_1_L.mat'];
load(fname);

for tt = 1:T
    params.sup_init = 1;
    params.algo = 'linear';
    params.max_class = 31;
    
    %% load data
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
    
    L = L_cell{tt};
    L = L * dim / trace(L*L');
    
    % transform the data
    lX = L*lX;
    vaX = L*vaX;
    teX = L*teX;
    
    sta = tic;
    
    %% source model, using 3-fold cross validation to tune lambda
    count = 0;
    
    best_source_model = [];
    source_struct.best_accu = 0;
    
    % generate indexes
    cv_train_idx = cell(1,3);
    cv_valid_idx = cell(1,3);
    
    for j = 1:3
        cv_train_idx{j} = [];
        cv_valid_idx{j} = [];
    end
    
    for i = 1:31
        index = find(lY == i);
        
        gap = floor(length(index)/3);
        for j = 1:3
               
            if j < 3
                cv_train_idx{j} = [cv_train_idx{j}, index( gap*(j-1)+1:gap*j )];
            else
                cv_train_idx{j} = [cv_train_idx{j}, index( gap*2+1:end )];
            end

            cv_valid_idx{j} = [cv_valid_idx{j}, setdiff( index,cv_train_idx{j} )];
        end
    end
    
    for cur_lambda = lambda_set
        count = count + 1;
        
        params.lambda = cur_lambda;
        params.tau = 0;
        params.normalize_info = true;
        
        accu = 0;
        for valid_idx = 1:3
            
            if isempty(best_source_model)
                [model, final_loss] = label_RIM(vaX,lX(:,cv_train_idx{valid_idx}),lY(:,cv_train_idx{valid_idx}),params);
            else
                [model, final_loss] = label_RIM(vaX,lX(:,cv_train_idx{valid_idx}),lY(:,cv_train_idx{valid_idx}),params, best_source_model);
            end
            
            % classify on validation data
            accu = accu + classify_data(lX(:,cv_valid_idx{valid_idx}), lY(:,cv_valid_idx{valid_idx}), model);     
        end
        accu = accu / 3;
        
        record_source(count,1) = cur_lambda;
        record_source(count,2) = 0;
        record_source(count,3) = accu;
        
        if accu > source_struct.best_accu
            source_struct.best_accu = accu;
            source_struct.best_lambda = cur_lambda;
            source_struct.best_tau = 0;
            best_source_model = model;
        end
    end
    
    % testing on test data
    params.lambda = source_struct.best_lambda;
    params.tau = 0;
    params.normalize_info = true;
    [best_source_model, final_loss] = label_RIM(vaX, lX, lY, params);
    
    source_struct.test_accu = classify_data(teX, teY, best_source_model);
    
    %% infomax, initialized with source model
    params.sup_init = 0;
    count = 0;
    infomax_struct.best_accu = 0;
    
    params.lambda = 1e-6;
    params.tau = 1;
    params.normalize_info = true;
    
    [model, final_loss] = RIM([vaX,teX], [], [], params, best_source_model);      % no label
     
    % classify on testing data
    infomax_struct.test_accu = classify_data(teX, teY, model);   
    record_infomax = [];
    
    source_cell{tt} = source_struct;
    infomax_cell{tt} = infomax_struct;
    
    record_source_cell{tt} = record_source;
    record_infomax_cell{tt} = record_infomax;
end
dur = toc(sta);

fname = ['result_metric_LR/', source, '_', target, '_D_', num2str(dim), '_metric_LR_L.mat'];
save(fname, 'source_cell', 'infomax_cell', 'record_source_cell', 'record_infomax_cell','dur');