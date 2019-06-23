function run_M_weather(source, target)


for dim = [4,5,6]
     for lambda = [0, 0.25,1,4,16,64]
        learn_metric(source, target, dim, lambda, 1);
        learn_metric(source, target, dim, lambda, 2);
    end
end