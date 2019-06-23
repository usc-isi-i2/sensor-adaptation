function summarize_SCL(source, target)

best_accu = 0;
best_stde = 0;
for dim = [20,40,70]
    fname = [source, '_', target, '_dim_', num2str(dim), '_SCL.mat'];
    load(fname);
    
    if mean(res) > best_accu
        best_accu = mean(res);
        best_stde = std(res)/sqrt(10);
    end
end

best_accu
best_stde