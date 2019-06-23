function run_M_object(source, target)


for dim = [20, 40, 70, 100, 200]
     for lambda = [0, 1]
        learn_metric(source, target, dim, lambda, 1);
        learn_metric(source, target, dim, lambda, 2);
    end
end