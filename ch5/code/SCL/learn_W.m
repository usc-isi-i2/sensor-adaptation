function learn_W(source, target)

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

new_fts = zscore(fts);

sX = new_fts;

fname = ['NLP_dataset/', target_file, '_400.mat'];
load(fname);

new_fts = zscore(fts);

% target
tX = new_fts;

X = [sX; tX];

n_feat = size(X,2);
n_inst = size(X,1);
gap = ceil(n_inst/2);

for i = 1:n_feat
    label = double( X(:,i) > 0 );
    Z = X;
    Z(:,i) = 0;
    
    rdp = randperm(n_inst);
    train_idx = rdp(1:gap);
    valid_idx = rdp(gap+1:end);
    
    train_data = sparse( Z(train_idx,:) );
    train_label = label( train_idx,:);
    valid_data = sparse( Z(valid_idx,:) );
    valid_label = label( valid_idx,:);
    
    best_accu = 0;
    best_model = [];
    for cur_c = [0.25 1 2 4  8 16 32 64]
        cmd = sprintf('-s 2 -c %g', cur_c);
        model = train(train_label, train_data, cmd);
        [predicted_label, accu, decision_values] = predict(valid_label, valid_data, model);
        
        if accu > best_accu
            best_accu = accu;
            best_model = model;
        end
    end
    
    keyboard
end

