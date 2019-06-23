function err = adapt_replace(ref_sensor, rep_sensor, new_sensor, ground_truth)

% Replace
N_train = size(rep_sensor,2);
N_rep_sensor = size(rep_sensor,1);
N_total = size(ref_sensor,2);

% replacing by a new sensor
for i = 1:N_rep_sensor
    err(i) = sqrt( mean( (new_sensor(i,:)-ground_truth(i,:)).^2 ) );
end