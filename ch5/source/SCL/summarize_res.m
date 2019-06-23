function summarize_res(source, target)

res = [];
for dim = [20,40,70,100]
    fname = [source, '_', target, '_dim_', num2str(dim), '.mat'];
    load(fname);
    
    res = [res, accu_semi_NN];
end

res = res';

new_res = max(res);

mean(new_res)
std(new_res)/sqrt(10)