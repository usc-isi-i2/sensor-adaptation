uuv_data = cell(1,10);
for i = 1:10
    fname = [num2str(i), '_mod_out'];
    
    uuv_data{i} = dlmread(fname);
end

save('processed_UUV/UUV_data', 'uuv_data');