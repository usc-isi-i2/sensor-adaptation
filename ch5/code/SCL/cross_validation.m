function [best_c,  best_accu] = cross_validation(data, label,valid_data,valid_label, type)

best_c = 0;
best_accu = 0;

for cur_c = [0.25 1 2 4  8 16 32 64]
    cmd = sprintf('-s %d -c %g', type, cur_c);
    model = train(label, data, cmd);
    [predicted_label, accu, decision_values] = predict(valid_label, valid_data, model);    
    
    if accu > best_accu
        best_accu = accu;
        best_c = cur_c;
    end
end
