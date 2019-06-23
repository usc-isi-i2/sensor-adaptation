function classify_all(source, target, type)

addpath('libknn');

if type == 1
   dim_set = [20,40,70];
else
   dim_set = [100,200];
end

for dim = dim_set
     for lambda = [0, 1]
        classify_metric(source, target, dim, lambda, 1);  
        classify_metric(source, target, dim, lambda, 2);  

        classify_metricL(source, target, dim, lambda, 1);
        classify_metricL(source, target, dim, lambda, 2);
    end
end