function run_L(source, target, type)


for dim = [20, 40, 70, 100, 200]
     for lambda = [0, 1]
        learn_metricL(source, target, dim, lambda, type);
    end
end