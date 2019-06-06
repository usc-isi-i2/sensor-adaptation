function process_data(fname)

load(['dataset/',fname]);

n_data = length(data);
n_observ = length( data{1}.history.observations );

fea = zeros(25, n_data*n_observ);
dates = [];
cc = 0;
for i = 1:n_data
    fprintf('%s - %g\n', fname, i);
    for j = 1:length(data{i}.history.observations)
       cc = cc + 1;
       fea(1:23,cc) = get_data_field(data{i}.history.observations{j});
       
       fea(24,cc) = i;  % date
       fea(25,cc) = get_time_index(data{i}.history.observations{j}.date);   % time
       
       dates{cc} = data{i}.history.observations{j}.date;
    end
end

fea(:,cc+1:end) = [];


new_fname = ['compress/',fname, '_comp.mat'];

if isempty(dates)
    save(new_fname, 'fea');
else
    save(new_fname, 'fea', 'dates');
end