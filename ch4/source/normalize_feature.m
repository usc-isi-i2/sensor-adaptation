function data = normalize_feature(data)


min_data = min(data,[],2);
max_data = max(data,[],2);

data = ( data - repmat(min_data,1,size(data,2) ) )./repmat( max_data-min_data, 1, size(data,2) );