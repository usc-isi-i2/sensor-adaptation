function const = learn_relationships(data)

% data: #sensors x #sample
% const: a cell array, where each cell contains a constraint

%% divide data into groups
N_group = 2;
N_sensor = size(data,1);
corrMat = corr(data');
Z = linkage(corrMat,'complete','correlation');
cluster_id = cluster(Z,'maxclust',N_group);

%% learn relationships among each group
cc = 0;
for i = 1:N_group
    
    idx = find(cluster_id == i);
    
    comb = generate_combinations(idx);
    
    for j = 1:length(comb)
        target_idx = comb{j}(1);
        input_idx = comb{j}(2:end);
        
        cc = cc + 1;
        const{cc} = learn_constraints(data, input_idx, target_idx);
    end
end

