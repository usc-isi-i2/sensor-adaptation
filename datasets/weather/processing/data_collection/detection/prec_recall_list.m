function prec_recall_list(pred, test_y, label)

cc = 0;
for threshold = 0:0.01:1
    
    detect_label = zeros(length(pred),1);
    for i = 1:length(pred)
        if abs( pred(i) - test_y(i) ) / abs( test_y(i) ) > threshold
            detect_label(i) = 1;
        end
    end
    
    cc = cc + 1;
    [precision(cc), recall(cc)] = prec_recall(label, detect_label);
end

figure;
plot(precision, recall, '.');