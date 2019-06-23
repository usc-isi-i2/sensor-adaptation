load('../energy_data/enery_data_processed.mat');


%% data is #sensor x #sample

train_data = train_data';
test_data = test_data';

N_sensor = size(train_data,1);
N_test = size(test_data,2);

std_val = std(train_data');


%% learn relationships into constraints
const = learn_relationships(train_data);


%% generating noisy data
rand('seed',1);
failed_truth = zeros(N_sensor, N_test);
detect_label = zeros(N_sensor, N_test);

noisy_test_data = test_data;
adapted_data = zeros(size(test_data));

for i = 1:N_test
    for j = 1:N_sensor
        if rand < 0.1
            noisy_test_data(j,i) = test_data(j,i) + 3*std_val(j);
            failed_truth(j,i) = 1;
        end
    end
end

%% detection & adaptation
fail_time = 0;
for i = 1:size(test_data,2)
    [fail_idx, adapt_val] = detection_adapt(const, noisy_test_data(:,i));
    
    adapted_data(:,i) = adapt_val;
    
    for j = 1:length(fail_idx)
        detect_label(fail_idx(j),i) = 1;
    end
end

for j = 1:N_sensor
    [precision(j), recall(j)] = prec_recall(failed_truth(j,:), detect_label(j,:));
    
    err_noise(j) = sqrt( mean( ( noisy_test_data(j,:) - test_data(j,:) ).^2 ) );
    err_adapt(j) = sqrt( mean( ( adapted_data(j,:) - test_data(j,:) ).^2 ) );
    
    fprintf('Sensor %g:\t non-adapt error %.2f\t adapt error %.2f\t precision %.2f\t recall %.2f\n', j, err_noise(j), err_adapt(j), precision(j)*100, recall(j)*100);
end
