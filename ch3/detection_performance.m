function [detect_rate, false_rate] = detection_performance(test_data, adapt_model, ground_truth, threshold)

failure_status = zeros(1,20);

N_test = size(test_data,1);
for i = 1:N_test
    
    [output_info pred(i)] = detection(test_data(i,:), 4, adapt_model, failure_status, threshold, i);
    
    fail_conf(i) = output_info(1);
    fail_type(i) = output_info(2);
    failure_status = output_info(3:end);
end

[detect_rate, false_rate] = compute_rate(ground_truth, fail_type);