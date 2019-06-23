function run_M_sentiment(source, target)


for dim = [50, 100, 200, 400]
     for lambda = [0, 1]
        learn_metric(source, target, dim, lambda, 1);
        learn_metric(source, target, dim, lambda, 2);
    end
end