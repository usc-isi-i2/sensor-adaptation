function process_data2(fname)

load(['dataset/',fname]);

n_data = length(data);
n_observ = length( data{1}.history.observations );

for i = 1:n_data
    n_observ = n_observ + length(data{i}.history.observations);
end

fprintf('%g\n', n_observ);