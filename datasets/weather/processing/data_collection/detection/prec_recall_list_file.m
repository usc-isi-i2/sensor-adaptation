function prec_recall_list_file(pred, test_y, label)

cc = 0;
for threshold = 0:0.001:0.5
    
    detect_label = zeros(length(pred),1);
    for i = 1:length(pred)
        if abs( pred(i) - test_y(i) ) / abs( test_y(i) ) > threshold
            detect_label(i) = 1;
        end
    end
    
    cc = cc + 1;
    [precision(cc), recall(cc)] = prec_recall(label, detect_label);
end

% AA = [precision', recall'];
% dlmwrite('prec_recall.txt',AA);
plot(recall, precision, '.');