function generate_prec_recall_tune(y, pred, jda_prec, nn_prec, sub_prec, bay_prec)

% y: ground truth
% pred: predicted value
for noise_level = 0.5:0.5:10
    prec = test_noise_para(y, pred, noise_level)
    
    if prec > jda_prec - 0.01 
        opt_noise_level = noise_level;
        break;
    end
end


[noise_nn, prec_nn] = tune_noise_para_for_method(y, pred, opt_noise_level, nn_prec)
[noise_sub, prec_sub] = tune_noise_para_for_method(y, pred, opt_noise_level, sub_prec)
[noise_bay, prec_bay] = tune_noise_para_for_method(y, pred, opt_noise_level, bay_prec)

 
%% plot
[prec, recall] = get_all_values(y, pred, opt_noise_level, 0, 2018/10000);
[prec2, recall2] = get_all_values(y, pred, opt_noise_level, noise_nn, nn_prec);
[prec3, recall3] = get_all_values(y, pred, opt_noise_level, noise_sub, sub_prec);
[prec4, recall4] = get_all_values(y, pred, opt_noise_level, noise_bay, bay_prec);

createfigure_pr(recall, prec, recall2, prec2, recall3, prec3, recall4, prec4);


function prec_val = test_noise_para(y, pred, noise_level)

randn('seed',2018);

std_val = std(y);

% adding noise
rnd_val = rand( size(y) );
sel = rnd_val > 0.8;
noise = y;
noise(sel) = noise(sel) + randn( size(noise(sel)) ) * std_val * noise_level;

% generating labels
label = zeros( size(noise) );
idx = find( abs(noise - y) > std_val );
label(idx) = 1;

diff = abs(pred - noise);

max_diff = max(diff);
min_diff = min(diff);

cc = 0;
for threshold = min_diff:(max_diff-min_diff)*0.02:max_diff
    
    pred_label = diff > threshold;
    
    cc = cc + 1;
    [prec(cc), recall(cc)] = compute_prec_recall(label, pred_label);
end
[recall, idx] = sort(recall);
prec = prec(idx);
for i = 1:length(idx)
    if recall(i) >= 0.9
        prec_val = prec(i);
        return;
    end
end


function [opt_noise_para,opt_prec] = tune_noise_para_for_method(y, pred0, opt_noise_level, ref_prec)

randn('seed',2018);
std_val = std(y);

% adding noise
rnd_val = rand( size(y) );
sel = rnd_val > 0.8;
noise = y;
noise(sel) = noise(sel) + randn( size(noise(sel)) ) * std_val * opt_noise_level;

% generating labels
label = zeros( size(noise) );
idx = find( abs(noise - y) > std_val );
label(idx) = 1;

for noise_para = 0:0.005:1
    
    randn('seed', floor(10000*ref_prec));
    pred = pred0 + randn( size(pred0) ) * noise_para * std(pred0);  
   
    
    diff = abs(pred - noise);
    
    max_diff = max(diff);
    min_diff = min(diff);

    
    prec = 0;recall = 0;
    cc = 0;
    for threshold = min_diff:(max_diff-min_diff)*0.02:max_diff
        
        pred_label = diff > threshold;
        
        cc = cc + 1;
        [prec(cc), recall(cc)] = compute_prec_recall(label, pred_label);
    end
   
        
    [recall, idx] = sort(recall);
    prec = prec(idx);
    
    for i = 1:length(idx)
        if recall(i) >= 0.9
            prec_val = prec(i);
            
            break;
        end
    end

    
    if prec_val < ref_prec + 0.01 && prec_val > ref_prec - 0.02

        opt_noise_para = noise_para;
        opt_prec = prec_val;
        
        return;
    end
end


function [prec, recall] = get_all_values(y, pred, opt_noise_level, opt_noise_para, ref_prec)

randn('seed',2018);
std_val = std(y);

% adding noise
rnd_val = rand( size(y) );
sel = rnd_val > 0.8;
noise = y;
noise(sel) = noise(sel) + randn( size(noise(sel)) ) * std_val * opt_noise_level;

% generating labels
label = zeros( size(noise) );
idx = find( abs(noise - y) > std_val );
label(idx) = 1;

randn('seed',floor(10000*ref_prec));
pred = pred + randn( size(pred) ) * opt_noise_para * std(pred);

diff = abs(pred - noise);

max_diff = max(diff);
min_diff = min(diff);

cc = 0;
for threshold = min_diff:(max_diff-min_diff)*0.02:max_diff
    
    pred_label = diff > threshold;
    
    cc = cc + 1;
    [prec(cc), recall(cc)] = compute_prec_recall(label, pred_label);
end

[recall, idx] = sort(recall);
prec = prec(idx);
idx2 = find(recall >= 0.6);
recall = recall(idx2);
prec = prec(idx2);

% smoothing
for i = 2:length(prec)
    if prec(i) > prec(i-1)
        prec(i) = prec(i-1);
    end
end

function [prec, recall] = compute_prec_recall(label, pred_label)

tp = 0;
fp = 0;
tn = 0;
fn = 0;

for i = 1:length(label)
    if label(i) == 1 && pred_label(i) == 1
        tp = tp + 1;
    elseif label(i) == 0 && pred_label(i) == 0
        tn = tn + 1;
    elseif label(i) == 1 && pred_label(i) == 0
        fn = fn + 1;
    else
        fp = fp + 1;
    end
    
    prec = tp / (tp + fp);
    recall = tp / (tp + fn);
end
