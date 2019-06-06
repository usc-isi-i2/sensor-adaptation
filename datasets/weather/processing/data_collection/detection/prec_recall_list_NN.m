function prec_recall_list_NN(NN_dist, label)

cc = 0;
min_dist = min(NN_dist);
max_dist = max(NN_dist);
gap = (max_dist-min_dist)/100;
for threshold = min_dist:gap:max_dist
    
    cc = cc + 1;
    detect_label = double( NN_dist > threshold);
    
    [precision(cc), recall(cc)] = prec_recall(label, detect_label);
end

plot(recall, precision, '.');